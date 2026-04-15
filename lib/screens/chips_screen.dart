import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import '../services/symptom_registry.dart';
import '../widgets/voice_button.dart';
import 'red_flags_screen.dart';

/// Stage 2: Symptom chips for the chosen chief complaint
/// Now includes voice button (Vosk Hindi) that auto-ticks matching chips.
class ChipsScreen extends StatefulWidget {
  final Map<String, dynamic> demographics;
  final String complaintKey;
  final String complaintLabel;

  /// Optional: pre-tick these symptom IDs (e.g. from camera classifier)
  final List<String> preTickedSymptoms;

  const ChipsScreen({
    super.key,
    required this.demographics,
    required this.complaintKey,
    required this.complaintLabel,
    this.preTickedSymptoms = const [],
  });

  @override
  State<ChipsScreen> createState() => _ChipsScreenState();
}

class _ChipsScreenState extends State<ChipsScreen> {
  final Set<String> _selected = {};
  final Set<String> _extraSymptomsFromVoice = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.preTickedSymptoms);
  }

  void _onVoiceSymptoms(Set<String> extracted) {
    final chips = SymptomRegistry.chipsFor(widget.complaintKey);
    final chipIds = chips.map((c) => c.id).toSet();

    setState(() {
      for (final s in extracted) {
        if (chipIds.contains(s)) {
          _selected.add(s);
        } else {
          _extraSymptomsFromVoice.add(s);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chips = SymptomRegistry.chipsFor(widget.complaintKey);

    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: Text(widget.complaintLabel)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tap all that apply',
                    style: TextStyle(
                      color: CureBayColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const Text(
                    'जो भी लागू हो, टैप करें',
                    style: TextStyle(
                      color: CureBayColors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Voice button — Hindi auto-tick
                  VoiceButton(onSymptomsExtracted: _onVoiceSymptoms),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CureBayColors.greenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selected.length} selected',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips.map((chip) {
                        final isSelected = _selected.contains(chip.id);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selected.remove(chip.id);
                            } else {
                              _selected.add(chip.id);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CureBayColors.green
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? CureBayColors.green
                                    : CureBayColors.divider,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(Icons.check,
                                        size: 16, color: Colors.white),
                                  ),
                                Text(
                                  chip.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : CureBayColors.textDark,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_extraSymptomsFromVoice.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CureBayColors.greenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Other symptoms from voice (will be sent to model):',
                              style: TextStyle(
                                color: CureBayColors.navy,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _extraSymptomsFromVoice.map((s) =>
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: CureBayColors.green),
                                  ),
                                  child: Text(
                                    s.replaceAll('_', ' '),
                                    style: const TextStyle(
                                      color: CureBayColors.navy,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: CureBayColors.divider)),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Combine chip-selected + voice-extras as final symptom list
                  final allSymptoms = {..._selected, ..._extraSymptomsFromVoice};
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RedFlagsScreen(
                        demographics: widget.demographics,
                        complaintKey: widget.complaintKey,
                        chipsSelected: allSymptoms.toList(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue / आगे बढ़ें'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
