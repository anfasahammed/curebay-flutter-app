import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vosk_flutter/vosk_flutter.dart';

/// Wraps Vosk Hindi ASR for offline voice-to-text.
/// Designed for graceful degradation — if Vosk fails, the app keeps working.
class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  VoskFlutterPlugin? _vosk;
  Model? _model;
  Recognizer? _recognizer;
  SpeechService? _speechService;
  bool _initialized = false;
  String? _initError;

  bool get isAvailable => _initialized && _initError == null;
  String? get initError => _initError;

  /// Initialize Vosk. Call once before listening.
  Future<bool> init() async {
    if (_initialized) return _initError == null;

    try {
      // Step 1: Mic permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _initError = 'Microphone permission denied';
        _initialized = true;
        return false;
      }

      // Step 2: Copy bundled Vosk model to writable storage on first run
      final modelPath = await _copyModelFromAssets();

      // Step 3: Initialize Vosk
      _vosk = VoskFlutterPlugin.instance();
      _model = await _vosk!.createModel(modelPath);
      _recognizer = await _vosk!.createRecognizer(
        model: _model!,
        sampleRate: 16000,
      );

      // Step 4: Init speech service — handle "already exists" from prior session
      try {
        _speechService = await _vosk!.initSpeechService(_recognizer!);
      } catch (e) {
        if (e.toString().contains('already exist')) {
          // Vosk's native SpeechService survives hot restart — try to reuse
          print('Vosk SpeechService already exists from previous session — attempting to reuse');
          try {
            // Force-stop any leftover session
            try {
              await _speechService?.stop();
            } catch (_) {}
            try {
              await _speechService?.dispose();
            } catch (_) {}
            _speechService = null;
            // Try to init fresh
            _speechService = await _vosk!.initSpeechService(_recognizer!);
          } catch (e2) {
            print('Could not reinitialize SpeechService: $e2');
            // Mark as initialized anyway — the app will show "Voice unavailable"
            // but the rest of the app keeps working
            _initError = 'Voice service requires app restart';
            _initialized = true;
            return false;
          }
        } else {
          rethrow;
        }
      }

      _initialized = true;
      return true;
    } catch (e, st) {
      print('VoiceService init failed: $e\n$st');
      _initError = e.toString();
      _initialized = true;
      return false;
    }
  }

  Future<String> _copyModelFromAssets() async {
    const modelDirName = 'vosk-model-small-hi-0.22';
    final docsDir = await getApplicationDocumentsDirectory();
    final destDir = Directory('${docsDir.path}/$modelDirName');

    final marker = File('${destDir.path}/.copied');
    if (await marker.exists()) {
      return destDir.path;
    }

    const files = [
      'README',
      'am/final.mdl',
      'conf/mfcc.conf', 'conf/model.conf',
      'graph/HCLr.fst', 'graph/Gr.fst',
      'graph/words.txt', 'graph/disambig_tid.int',
      'graph/phones/word_boundary.int',
      'ivector/final.dubm', 'ivector/final.ie', 'ivector/final.mat',
      'ivector/global_cmvn.stats',
      'ivector/online_cmvn.conf', 'ivector/splice.conf',
    ];

    for (final f in files) {
      try {
        final data = await rootBundle.load('assets/vosk/$modelDirName/$f');
        final outFile = File('${destDir.path}/$f');
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      } catch (e) {
        print('Vosk asset $f skipped: $e');
      }
    }

    await marker.writeAsString('done');
    return destDir.path;
  }

  Stream<String>? startListening() {
    if (!isAvailable || _speechService == null) return null;
    _speechService!.start();
    return _speechService!.onPartial().map((event) => _extractPartial(event));
  }

  Future<String> stopListening() async {
    if (!isAvailable || _speechService == null) return '';
    try {
      final resultFuture = _speechService!.onResult().first
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => '');
      await _speechService!.stop();
      final result = await resultFuture;
      return _extractText(result);
    } catch (e) {
      print('stopListening error: $e');
      return '';
    }
  }

  String _extractPartial(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('{')) {
      final idx = raw.indexOf('"partial"');
      if (idx < 0) return '';
      final colon = raw.indexOf(':', idx);
      final start = raw.indexOf('"', colon + 1);
      final end = raw.indexOf('"', start + 1);
      if (start < 0 || end < 0) return '';
      return raw.substring(start + 1, end);
    }
    return raw;
  }

  String _extractText(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('{')) {
      final idx = raw.indexOf('"text"');
      if (idx < 0) return '';
      final colon = raw.indexOf(':', idx);
      final start = raw.indexOf('"', colon + 1);
      final end = raw.indexOf('"', start + 1);
      if (start < 0 || end < 0) return '';
      return raw.substring(start + 1, end);
    }
    return raw;
  }

  Future<void> dispose() async {
    try {
      await _speechService?.dispose();
      _recognizer?.dispose();
      _model?.dispose();
    } catch (_) {}
  }
}