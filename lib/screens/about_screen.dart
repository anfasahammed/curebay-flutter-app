import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [CureBayColors.navy, CureBayColors.navyDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('CureBay Assist',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      )),
                  SizedBox(height: 4),
                  Text('Offline AI Triage v1.0',
                      style: TextStyle(
                        color: Color(0xFFB0CEEB),
                        fontSize: 14,
                      )),
                  SizedBox(height: 16),
                  Text(
                    'Built for CureBay\'s Swasthya Mitras to enable rapid '
                    'preliminary triage in rural eClinics — even without '
                    'internet connectivity.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'How it works'),
            const _InfoCard(
              icon: Icons.touch_app,
              title: 'Tap or Speak',
              description:
                  'Worker selects a complaint or speaks symptoms in Hindi.',
            ),
            const _InfoCard(
              icon: Icons.psychology,
              title: 'AI Triage',
              description:
                  'XGBoost models predict top-3 diseases and severity '
                  '(Emergency / Urgent / Normal) on-device.',
            ),
            const _InfoCard(
              icon: Icons.shield_outlined,
              title: 'Safety Net',
              description:
                  'Red-flag symptoms always force escalation, regardless '
                  'of model output.',
            ),
            const _InfoCard(
              icon: Icons.menu_book,
              title: 'Guidance',
              description:
                  'WHO IMCI / ICMR / MoHFW protocols, not AI-generated. '
                  'Auditable for every disease.',
            ),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Technology'),
            const _TechRow(label: 'Triage models', value: 'XGBoost ONNX'),
            const _TechRow(label: 'Skin classifier', value: 'EfficientNetB0 TFLite'),
            const _TechRow(label: 'Voice ASR', value: 'Vosk Hindi (offline)'),
            const _TechRow(label: 'Total APK size', value: '~80 MB'),
            const _TechRow(label: 'Min. Android', value: '6.0 (Marshmallow)'),
            const _TechRow(label: 'RAM required', value: '2 GB+'),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Disclaimer'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Text(
                'This app provides decision-support for trained health workers, '
                'NOT medical diagnosis. All recommendations are sourced from '
                'national protocols (WHO, ICMR, MoHFW). Always refer to a '
                'qualified physician for final diagnosis and treatment.',
                style: TextStyle(
                  color: Color(0xFF6D4C00),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Built for AIC 2026 — APOGEE Innovation Challenge',
                style: TextStyle(
                  color: CureBayColors.textLight,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: CureBayColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CureBayColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CureBayColors.greenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: CureBayColors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CureBayColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: CureBayColors.textMid,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label;
  final String value;
  const _TechRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                color: CureBayColors.textMid,
                fontSize: 14,
              )),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                color: CureBayColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
        ],
      ),
    );
  }
}
