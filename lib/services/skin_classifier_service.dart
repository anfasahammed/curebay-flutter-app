import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class SkinClassifierService {
  SkinClassifierService._();
  static final SkinClassifierService instance = SkinClassifierService._();

  Interpreter? _interpreter;
  List<String> _classes = [];
  Map<String, String> _symptomMapping = {};
  double _seriousThreshold = 0.30;
  bool _initialized = false;
  String? _initError;

  bool get isAvailable => _initialized && _initError == null;
  String? get initError => _initError;

  Future<bool> init() async {
    if (_initialized) return _initError == null;

    try {
      print('===== TFLite SkinClassifier init =====');

      // Step 1: Load the model bytes from asset bundle
      print('Step 1: Loading model bytes from asset...');
      final modelData = await rootBundle.load('assets/models/skin_classifier.tflite');
      print('  Model bytes loaded: ${modelData.lengthInBytes} bytes');

      final modelBytes = modelData.buffer.asUint8List(
        modelData.offsetInBytes,
        modelData.lengthInBytes,
      );

      // Step 2: Create interpreter from buffer
      print('Step 2: Creating interpreter from buffer...');
      try {
        _interpreter = Interpreter.fromBuffer(modelBytes);
        print('  Interpreter created (no options)');
      } catch (e1) {
        print('  fromBuffer (no options) failed: $e1');
        print('  Trying with InterpreterOptions...');
        final options = InterpreterOptions();
        _interpreter = Interpreter.fromBuffer(modelBytes, options: options);
        print('  Interpreter created (with options)');
      }

      // Step 3: Verify model shape
      final inputs = _interpreter!.getInputTensors();
      final outputs = _interpreter!.getOutputTensors();
      print('Step 3: Model loaded successfully');
      print('  Input tensors:  ${inputs.length}');
      for (var i = 0; i < inputs.length; i++) {
        print('    [$i] shape=${inputs[i].shape} type=${inputs[i].type}');
      }
      print('  Output tensors: ${outputs.length}');
      for (var i = 0; i < outputs.length; i++) {
        print('    [$i] shape=${outputs[i].shape} type=${outputs[i].type}');
      }

      // Step 4: Load labels
      print('Step 4: Loading labels JSON...');
      final labelsJson = await rootBundle.loadString(
        'assets/models/skin_classifier_labels.json',
      );
      final labels = jsonDecode(labelsJson) as Map<String, dynamic>;
      _classes = List<String>.from(labels['classes'] as List);
      _symptomMapping = Map<String, String>.from(labels['symptom_mapping'] as Map);
      _seriousThreshold = (labels['serious_threshold'] as num?)?.toDouble() ?? 0.30;
      print('  Classes: $_classes');

      _initialized = true;
      print('===== INIT SUCCESS =====');
      return true;
    } catch (e, st) {
      print('===== INIT FAILED =====');
      print('Error: $e');
      print('Stack trace: $st');
      _initError = e.toString();
      _initialized = true;
      return false;
    }
  }

  Future<Map<String, dynamic>?> classify(File imageFile) async {
    if (!isAvailable) return null;

    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;
      image = img.copyResize(image, width: 224, height: 224);

      // Build [1, 224, 224, 3] float32 — RAW pixel values (no /255)
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = image!.getPixel(x, y);
              return [
                pixel.r.toDouble(),
                pixel.g.toDouble(),
                pixel.b.toDouble(),
              ];
            },
          ),
        ),
      );

      final output = List.filled(_classes.length, 0.0)
                          .reshape([1, _classes.length]);
      _interpreter!.run(input, output);
      final probs = (output[0] as List).cast<double>();

      final seriousIdx = _classes.indexOf('skin_lesion_serious');
      String detectedClass;
      double confidence;
      if (seriousIdx >= 0 && probs[seriousIdx] >= _seriousThreshold) {
        detectedClass = 'skin_lesion_serious';
        confidence = probs[seriousIdx];
      } else {
        int bestIdx = 0;
        for (int i = 1; i < probs.length; i++) {
          if (probs[i] > probs[bestIdx]) bestIdx = i;
        }
        detectedClass = _classes[bestIdx];
        confidence = probs[bestIdx];
      }

      final symptomId = (_symptomMapping[detectedClass] ?? 'sym_skin_rash')
          .replaceAll('sym_', '');

      final allProbs = <String, double>{};
      for (int i = 0; i < _classes.length; i++) {
        allProbs[_classes[i]] = probs[i];
      }

      return {
        'class': detectedClass,
        'symptom_id': symptomId,
        'confidence': confidence,
        'all_probs': allProbs,
      };
    } catch (e, st) {
      print('SkinClassifier classify failed: $e\n$st');
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}