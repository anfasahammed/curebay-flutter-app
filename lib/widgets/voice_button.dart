import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import '../services/voice_service.dart';
import '../services/hindi_dictionary.dart';

/// Tap-to-toggle voice button. First tap = start, second tap = stop.
/// More reliable than hold-to-record on touch devices.
class VoiceButton extends StatefulWidget {
  final void Function(Set<String> extractedSymptoms) onSymptomsExtracted;

  const VoiceButton({super.key, required this.onSymptomsExtracted});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  bool _initInProgress = true;
  bool _listening = false;
  String _partial = '';
  String? _initError;
  StreamSubscription<String>? _sub;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _initVosk();
  }

  Future<void> _initVosk() async {
    final ok = await VoiceService.instance.init();
    if (mounted) {
      setState(() {
        _initialized = ok;
        _initInProgress = false;
        _initError = VoiceService.instance.initError;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_initialized) return;

    if (_listening) {
      // STOP
      await _sub?.cancel();
      _sub = null;
      final finalText = await VoiceService.instance.stopListening();
      final transcript = finalText.isNotEmpty ? finalText : _partial;

      print('VOICE FINAL TRANSCRIPT: "$transcript"');

      if (!mounted) return;
      setState(() {
        _listening = false;
      });

      if (transcript.trim().isEmpty) {
        _showSnack('कुछ सुनाई नहीं दिया / No speech detected');
        return;
      }

      final extracted = HindiSymptomDictionary.extract(transcript);
      print('VOICE EXTRACTED SYMPTOMS: $extracted');

      if (extracted.isEmpty) {
        _showSnack('Heard: "$transcript"\nNo known symptoms recognized');
        return;
      }

      widget.onSymptomsExtracted(extracted);
      _showSnack('${extracted.length} symptom(s) added from voice',
          success: true);
    } else {
      // START
      final stream = VoiceService.instance.startListening();
      if (stream == null) {
        _showSnack('Voice not available');
        return;
      }
      setState(() {
        _listening = true;
        _partial = '';
      });
      _sub = stream.listen((text) {
        if (mounted && text.isNotEmpty) {
          setState(() => _partial = text);
        }
      });
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? CureBayColors.green : CureBayColors.navy,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initInProgress) {
      return _buildBar(
        icon: Icons.hourglass_top,
        label: 'Loading voice model...',
        labelHi: 'आवाज़ मॉडल लोड हो रहा है',
        color: CureBayColors.textLight,
      );
    }

    if (!_initialized) {
      return _buildBar(
        icon: Icons.mic_off,
        label: 'Voice unavailable',
        labelHi: _initError ?? 'Mic permission denied',
        color: CureBayColors.textLight,
      );
    }

    if (_listening) {
      return Column(
        children: [
          if (_partial.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CureBayColors.greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _partial,
                style: const TextStyle(
                  color: CureBayColors.navy,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
          _buildBar(
            icon: Icons.stop_circle,
            label: 'Tap to STOP listening',
            labelHi: 'रोकने के लिए टैप करें',
            color: CureBayColors.emergency,
            pulse: true,
            onTap: _toggleListening,
          ),
        ],
      );
    }

    return _buildBar(
      icon: Icons.mic,
      label: 'Tap to speak in Hindi',
      labelHi: 'हिंदी में बोलने के लिए टैप करें',
      color: CureBayColors.navy,
      onTap: _toggleListening,
    );
  }

  Widget _buildBar({
    required IconData icon,
    required String label,
    required String labelHi,
    required Color color,
    bool pulse = false,
    VoidCallback? onTap,
  }) {
    Widget bar = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: pulse
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                  Text(labelHi,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (pulse) {
      bar = AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 + (_pulseCtrl.value * 0.04),
          child: child,
        ),
        child: bar,
      );
    }
    return bar;
  }
}