import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import '../services/patient_store.dart';
import '../models/patient.dart';
import '../services/pdf_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  Widget build(BuildContext context) {
    final patients = PatientStore.instance.all();

    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(
        title: const Text('Patient Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: patients.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PatientCard(patient: patients[i]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CureBayColors.greenLight,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.folder_open,
              size: 48,
              color: CureBayColors.green,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No patient records yet',
            style: TextStyle(
              color: CureBayColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completed triage cases will appear here.\nGo to Home to start a new patient.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CureBayColors.textMid,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  const _PatientCard({required this.patient});

  Color get triageColor {
    switch (patient.triage) {
      case 'emergency':
        return CureBayColors.emergency;
      case 'urgent':
        return CureBayColors.urgent;
      default:
        return CureBayColors.normal;
    }
  }

  String get triageLabel {
    switch (patient.triage) {
      case 'emergency':
        return '🔴 Emergency';
      case 'urgent':
        return '🟠 Urgent';
      default:
        return '🟢 Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CureBayColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: triageColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(Icons.person, color: triageColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          color: CureBayColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${patient.age} yrs • ${patient.sex} • ${patient.ward}',
                        style: const TextStyle(
                          color: CureBayColors.textMid,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  triageLabel,
                  style: TextStyle(
                    color: triageColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CureBayColors.greenLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Top diagnosis: ${patient.topDisease}',
                style: const TextStyle(
                  color: CureBayColors.navy,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 13, color: CureBayColors.textLight),
                const SizedBox(width: 4),
                Text(
                  patient.createdAt
                      .toString()
                      .substring(0, 16)
                      .replaceAll('-', '/'),
                  style: const TextStyle(
                    color: CureBayColors.textLight,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await PdfService.shareSummary(patient);
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Download PDF'),
                  style: TextButton.styleFrom(
                    foregroundColor: CureBayColors.green,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
