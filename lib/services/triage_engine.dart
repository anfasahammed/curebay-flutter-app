import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';
import 'schema.dart';
import 'symptom_registry.dart';

/// Real on-device inference using the trained XGBoost ONNX models
class TriageEngine {
  TriageEngine._();
  static final TriageEngine instance = TriageEngine._();

  OrtSession? _diseaseSession;
  OrtSession? _triageSession;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    OrtEnv.instance.init();

    final diseaseBytes = await rootBundle.load('assets/models/disease_model.onnx');
    final triageBytes  = await rootBundle.load('assets/models/triage_model.onnx');

    final opts = OrtSessionOptions();
    _diseaseSession = OrtSession.fromBuffer(
        diseaseBytes.buffer.asUint8List(), opts);
    _triageSession = OrtSession.fromBuffer(
        triageBytes.buffer.asUint8List(), opts);

    _initialized = true;
  }

  /// Build the 85-float feature vector in the exact order the model expects
  Float32List buildFeatureVector({
    required Map<String, dynamic> demographics,
    required Map<String, double> vitals,
    required Set<String> allSymptoms,
  }) {
    final features = <double>[];
    for (final feat in Schema.allFeatures) {
      if (feat == 'age') {
        features.add((demographics['age'] as int).toDouble());
      } else if (feat == 'sex') {
        features.add(demographics['sex'] == 'F' ? 1.0 : 0.0);
      } else if (feat == 'has_diabetes' ||
                 feat == 'has_hypertension' ||
                 feat == 'is_smoker') {
        features.add(((demographics[feat] ?? 0) as num).toDouble());
      } else if (Schema.normalVitals.containsKey(feat)) {
        features.add(vitals[feat] ?? Schema.normalVitals[feat]!);
      } else if (feat.startsWith('sym_')) {
        final sym = feat.substring(4);
        features.add(allSymptoms.contains(sym) ? 1.0 : 0.0);
      } else {
        features.add(0.0);
      }
    }
    return Float32List.fromList(features);
  }

  /// Run inference and return triage + top-3 diseases
  Future<TriageResult> predict({
    required Map<String, dynamic> demographics,
    required Map<String, double> vitals,
    required List<String> symptoms,
    required List<String> redFlags,
  }) async {
    await init();

    final allSymptoms = {...symptoms, ...redFlags};
    final features = buildFeatureVector(
      demographics: demographics,
      vitals: vitals,
      allSymptoms: allSymptoms,
    );

    // Build input tensor [1, 85]
    final input = OrtValueTensor.createTensorWithDataList(
      features,
      [1, features.length],
    );

    // ---- DISEASE prediction ----
    String topDisease;
    List<TopDisease> top3 = [];
    try {
      final dOut = await _diseaseSession!.runAsync(
        OrtRunOptions(),
        {'input': input},
      );
      // ONNX XGBoost outputs: [labels (int64), probabilities (per-class)]
      final probsRaw = dOut?[1]?.value;
      final probs = _parseProbs(probsRaw, Schema.diseaseClasses.length);
      final indexed = List.generate(probs.length, (i) => MapEntry(i, probs[i]));
      indexed.sort((a, b) => b.value.compareTo(a.value));
      top3 = indexed.take(3).map((e) => TopDisease(
        disease: Schema.diseaseClasses[e.key],
        probability: e.value,
      )).toList();
      topDisease = top3.first.disease;

      for (final v in dOut ?? []) {
        v?.release();
      }
    } catch (e) {
      input.release();
      rethrow;
    }

    // Re-create input for triage (tensors get consumed)
    final input2 = OrtValueTensor.createTensorWithDataList(
      features,
      [1, features.length],
    );

    // ---- TRIAGE prediction ----
    String triage;
    try {
      final tOut = await _triageSession!.runAsync(
        OrtRunOptions(),
        {'input': input2},
      );
      final tLabel = tOut?[0]?.value;
      int idx;
      if (tLabel is List && tLabel.isNotEmpty) {
        final v = tLabel.first;
        idx = (v is List && v.isNotEmpty) ? (v.first as int) : (v as int);
      } else {
        idx = 0;
      }
      triage = Schema.triageClasses[idx];

      for (final v in tOut ?? []) {
        v?.release();
      }
    } catch (e) {
      input.release();
      input2.release();
      rethrow;
    }

    input.release();
    input2.release();

    // ---- Apply red-flag override (safety net) ----
    triage = _applyOverride(triage, redFlags);

    return TriageResult(
      triage: triage,
      topDisease: topDisease,
      top3: top3,
      modelTriage: triage,
    );
  }

  String _applyOverride(String modelTriage, List<String> redFlags) {
    final flags = redFlags.toSet();
    if (flags.intersection(SymptomRegistry.forceEmergency).isNotEmpty) {
      return 'emergency';
    }
    if (flags.intersection(SymptomRegistry.forceUrgentMinimum).isNotEmpty) {
      if (modelTriage == 'normal') return 'urgent';
    }
    return modelTriage;
  }

  /// XGBoost ONNX probability outputs come in different shapes. Normalize.
  List<double> _parseProbs(dynamic raw, int numClasses) {
    if (raw is List) {
      // Could be List<List<double>> shape [1, N] or List<Map>
      if (raw.isNotEmpty && raw.first is List) {
        return (raw.first as List).map((e) => (e as num).toDouble()).toList();
      } else if (raw.isNotEmpty && raw.first is Map) {
        final m = raw.first as Map;
        return List.generate(
          numClasses,
          (i) => ((m[i] ?? 0.0) as num).toDouble(),
        );
      }
    }
    // Fallback: uniform
    return List.filled(numClasses, 1.0 / numClasses);
  }

  void dispose() {
    _diseaseSession?.release();
    _triageSession?.release();
    OrtEnv.instance.release();
  }
}

class TriageResult {
  final String triage;          // final triage after override
  final String modelTriage;     // raw model output (before override)
  final String topDisease;
  final List<TopDisease> top3;

  TriageResult({
    required this.triage,
    required this.modelTriage,
    required this.topDisease,
    required this.top3,
  });
}

class TopDisease {
  final String disease;
  final double probability;
  TopDisease({required this.disease, required this.probability});
}
