import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/curebay_theme.dart';
import '../services/skin_classifier_service.dart';

/// Camera screen — capture photo, classify with TFLite, return result map
/// to caller via Navigator.pop. Result map: {class, symptom_id, confidence, all_probs}
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _capturedImage;
  bool _classifying = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    SkinClassifierService.instance.init();
  }

  Future<void> _capture() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() {
        _capturedImage = File(picked.path);
        _result = null;
        _error = null;
      });
      await _classify();
    } catch (e) {
      setState(() => _error = 'Camera error: $e');
    }
  }

  Future<void> _classify() async {
    if (_capturedImage == null) return;
    setState(() => _classifying = true);
    final result = await SkinClassifierService.instance.classify(_capturedImage!);
    setState(() {
      _classifying = false;
      _result = result;
      if (result == null) {
        _error = SkinClassifierService.instance.initError ?? 'Classification failed';
      }
    });
  }

  void _useResult() {
    if (_result != null) Navigator.pop(context, _result);
  }

  void _retake() {
    setState(() {
      _capturedImage = null;
      _result = null;
      _error = null;
    });
    _capture();
  }

  String _humanize(String s) =>
      s.replaceAll('_', ' ').split(' ')
       .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
       .join(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: const Text('Skin Photo')),
      body: SafeArea(
        child: _capturedImage == null ? _buildPrompt() : _buildResult(),
      ),
    );
  }

  Widget _buildPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: CureBayColors.greenLight,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Icons.camera_alt,
                  size: 64, color: CureBayColors.green),
            ),
            const SizedBox(height: 24),
            const Text('Take photo of skin',
                style: TextStyle(
                  color: CureBayColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                )),
            const Text('त्वचा की फोटो लें',
                style: TextStyle(
                  color: CureBayColors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 16),
            const Text(
              'Hold camera 6-8 inches from skin.\nGood light. Steady hand.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CureBayColors.textMid, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _capture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(220, 52)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip — no photo'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!,
                  style: const TextStyle(color: CureBayColors.emergency, fontSize: 12),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(_capturedImage!, height: 280, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          if (_classifying)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: CureBayColors.green),
                  SizedBox(height: 12),
                  Text('Analyzing photo...',
                      style: TextStyle(color: CureBayColors.navy)),
                ],
              ),
            )
          else if (_result != null)
            _buildClassification()
          else if (_error != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CureBayColors.emergency.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_error!,
                  style: const TextStyle(color: CureBayColors.emergency, fontSize: 13)),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retake,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    foregroundColor: CureBayColors.navy,
                    side: const BorderSide(color: CureBayColors.navy),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _result != null ? _useResult : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Use This'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassification() {
    final cls = _result!['class'] as String;
    final conf = _result!['confidence'] as double;
    final probs = _result!['all_probs'] as Map<String, double>;

    Color color;
    String label;
    String labelHi;
    if (cls == 'skin_lesion_serious') {
      color = CureBayColors.emergency;
      label = 'Concerning Lesion';
      labelHi = 'गंभीर घाव — डॉक्टर को दिखाएं';
    } else if (cls == 'skin_rash') {
      color = CureBayColors.urgent;
      label = 'Rash Detected';
      labelHi = 'त्वचा पर दाने';
    } else {
      color = CureBayColors.normal;
      label = 'Skin Appears Normal';
      labelHi = 'त्वचा सामान्य लगती है';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(Icons.image_search, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        )),
                    Text(labelHi,
                        style: const TextStyle(
                          color: CureBayColors.textMid,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
              Text('${(conf * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: CureBayColors.divider),
          const SizedBox(height: 8),
          ...probs.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        _humanize(e.key),
                        style: const TextStyle(
                          color: CureBayColors.textMid,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value,
                          backgroundColor: CureBayColors.divider,
                          color: e.key == cls ? color : CureBayColors.textLight,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 36,
                      child: Text('${(e.value * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: CureBayColors.textMid,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
