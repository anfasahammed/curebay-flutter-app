import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import '../services/symptom_registry.dart';
import 'vitals_screen.dart';

/// Stage 3: Red flag safety check — Y/N for each
class RedFlagsScreen extends StatefulWidget {
  final Map<String, dynamic> demographics;
  final String complaintKey;
  final List<String> chipsSelected;

  const RedFlagsScreen({
    super.key,
    required this.demographics,
    required this.complaintKey,
    required this.chipsSelected,
  });

  @override
  State<RedFlagsScreen> createState() => _RedFlagsScreenState();
}

class _RedFlagsScreenState extends State<RedFlagsScreen> {
  int _currentIndex = 0;
  final Map<String, bool> _answers = {};

  @override
  Widget build(BuildContext context) {
    final flags = SymptomRegistry.redFlagsFor(widget.complaintKey);

    if (flags.isEmpty) {
      // No red flags for this complaint, skip ahead
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VitalsScreen(
              demographics: widget.demographics,
              chipsSelected: widget.chipsSelected,
              redFlagsYes: const [],
            ),
          ),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final flag = flags[_currentIndex];

    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: const Text('Safety Check')),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / flags.length,
              backgroundColor: CureBayColors.divider,
              color: CureBayColors.green,
              minHeight: 4,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CureBayColors.greenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Question ${_currentIndex + 1} / ${flags.length}',
                      style: const TextStyle(
                        color: CureBayColors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: CureBayColors.emergency.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: CureBayColors.emergency,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      flag.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CureBayColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Row(
                      children: [
                        Expanded(
                          child: _AnswerButton(
                            label: 'NO',
                            labelHi: 'नहीं',
                            color: CureBayColors.normal,
                            onTap: () => _answer(flag.id, false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _AnswerButton(
                            label: 'YES',
                            labelHi: 'हाँ',
                            color: CureBayColors.emergency,
                            onTap: () => _answer(flag.id, true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _answer(String id, bool yes) {
    setState(() => _answers[id] = yes);

    final flags = SymptomRegistry.redFlagsFor(widget.complaintKey);
    if (_currentIndex < flags.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // Done — collect Yes answers and proceed
      final redFlagsYes =
          _answers.entries.where((e) => e.value).map((e) => e.key).toList();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VitalsScreen(
            demographics: widget.demographics,
            chipsSelected: widget.chipsSelected,
            redFlagsYes: redFlagsYes,
          ),
        ),
      );
    }
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final String labelHi;
  final Color color;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.labelHi,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
            ),
            Text(
              labelHi,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
