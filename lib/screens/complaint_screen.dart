import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import 'chips_screen.dart';
import 'camera_screen.dart';

/// Stage 1: Worker picks the chief complaint from 8 big icon cards.
/// If they pick Skin, the camera opens first to capture a photo,
/// then routes to chips with the classifier's symptom pre-ticked.
class ComplaintScreen extends StatelessWidget {
  final Map<String, dynamic> demographics;

  const ComplaintScreen({super.key, required this.demographics});

  static const List<_Complaint> complaints = [
    _Complaint('fever', '🤒', 'Fever', 'बुखार'),
    _Complaint('respiratory', '🤧', 'Cough / Breath', 'खांसी / सांस'),
    _Complaint('gi', '🤢', 'Stomach', 'पेट की समस्या'),
    _Complaint('pain', '🤕', 'Pain', 'दर्द'),
    _Complaint('skin', '🩹', 'Skin', 'त्वचा'),
    _Complaint('neuro', '🧠', 'Weakness', 'कमज़ोरी'),
    _Complaint('maternal_child', '🤰', 'Pregnancy/Child', 'गर्भ / बच्चा'),
    _Complaint('injury_bite', '🐍', 'Injury / Bite', 'चोट / काटना'),
  ];

  Future<void> _onComplaintTap(BuildContext ctx, _Complaint complaint) async {
    List<String> preTicked = [];

    // Skin complaint → open camera first
    if (complaint.key == 'skin') {
      final result = await Navigator.push<Map<String, dynamic>?>(
        ctx,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
      if (result != null) {
        final symptomId = result['symptom_id'] as String?;
        if (symptomId != null && symptomId.isNotEmpty) {
          preTicked = [symptomId];
        }
      }
      // If user skipped camera (result is null), just continue to chips
    }

    if (!ctx.mounted) return;
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => ChipsScreen(
          demographics: demographics,
          complaintKey: complaint.key,
          complaintLabel: complaint.labelEn,
          preTickedSymptoms: preTicked,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: const Text('Main Problem')),
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
                  Text(
                    'For: ${demographics['name']}',
                    style: const TextStyle(
                      color: CureBayColors.textMid,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'What is the main problem?',
                    style: TextStyle(
                      color: CureBayColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  const Text(
                    'मुख्य समस्या क्या है?',
                    style: TextStyle(
                      color: CureBayColors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: complaints.length,
                itemBuilder: (_, i) => _ComplaintTile(
                  complaint: complaints[i],
                  onTap: () => _onComplaintTap(context, complaints[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Complaint {
  final String key;
  final String emoji;
  final String labelEn;
  final String labelHi;
  const _Complaint(this.key, this.emoji, this.labelEn, this.labelHi);
}

class _ComplaintTile extends StatelessWidget {
  final _Complaint complaint;
  final VoidCallback onTap;

  const _ComplaintTile({required this.complaint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CureBayColors.divider, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CureBayColors.greenLight,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  complaint.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              complaint.labelEn,
              style: const TextStyle(
                color: CureBayColors.navy,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              complaint.labelHi,
              style: const TextStyle(
                color: CureBayColors.green,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
