import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import '../services/triage_engine.dart';
import '../services/treatment_guidance.dart';
import '../services/patient_store.dart';
import '../models/patient.dart' as model;

/// Stage 7: Final triage result with guidance card
class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> demographics;
  final List<String> chipsSelected;
  final List<String> redFlagsYes;
  final Map<String, double> vitals;

  const ResultScreen({
    super.key,
    required this.demographics,
    required this.chipsSelected,
    required this.redFlagsYes,
    required this.vitals,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _loading = true;
  String? _error;
  TriageResult? _result;
  GuidanceBlock? _guidance;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _runInference();
  }

  Future<void> _runInference() async {
    try {
      final result = await TriageEngine.instance.predict(
        demographics: widget.demographics,
        vitals: widget.vitals,
        symptoms: widget.chipsSelected,
        redFlags: widget.redFlagsYes,
      );
      final guidance = TreatmentGuidance.lookup(result.topDisease)
                       ?? TreatmentGuidance.fallback();
      setState(() {
        _result = result;
        _guidance = guidance;
        _loading = false;
      });
      _autoSave();
    } catch (e, st) {
      debugPrint('Inference error: $e\n$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _autoSave() {
    if (_result == null || _guidance == null || _saved) return;
    final patient = model.Patient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: widget.demographics['name'] as String,
      age: widget.demographics['age'] as int,
      sex: widget.demographics['sex'] as String,
      bloodGroup: widget.demographics['bloodGroup'] as String,
      ward: widget.demographics['ward'] as String,
      phone: widget.demographics['phone'] as String?,
      hasDiabetes:     (widget.demographics['has_diabetes'] ?? 0) == 1,
      hasHypertension: (widget.demographics['has_hypertension'] ?? 0) == 1,
      isPregnant:      (widget.demographics['is_pregnant'] ?? 0) == 1,
      isSmoker:        (widget.demographics['is_smoker'] ?? 0) == 1,
      vitals: widget.vitals,
      symptoms: widget.chipsSelected,
      redFlags: widget.redFlagsYes,
      triage: _result!.triage,
      topDisease: _result!.topDisease,
      top3Diseases: _result!.top3.map((d) => model.TopDisease(
        disease: d.disease,
        probability: d.probability,
      )).toList(),
      doNow: _guidance!.doNow,
      doNot: _guidance!.doNot,
      referTo: _guidance!.referTo,
      watchFor: _guidance!.watchFor,
      guidanceSource: _guidance!.source,
    );
    PatientStore.instance.add(patient);
    _saved = true;
  }

  Color _triageColor(String t) {
    switch (t) {
      case 'emergency': return CureBayColors.emergency;
      case 'urgent':    return CureBayColors.urgent;
      default:          return CureBayColors.normal;
    }
  }

  String _triageEmoji(String t) {
    switch (t) {
      case 'emergency': return '🔴';
      case 'urgent':    return '🟠';
      default:          return '🟢';
    }
  }

  String _triageLabel(String t) {
    switch (t) {
      case 'emergency': return 'EMERGENCY';
      case 'urgent':    return 'URGENT';
      default:          return 'NORMAL';
    }
  }

  String _triageLabelHi(String t) {
    switch (t) {
      case 'emergency': return 'आपातकाल';
      case 'urgent':    return 'जल्दी';
      default:          return 'सामान्य';
    }
  }

  String _humanizeDisease(String d) {
    return d.replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: CureBayColors.background,
        appBar: AppBar(title: const Text('Analyzing...')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: CureBayColors.green),
              const SizedBox(height: 24),
              const Text(
                'Running AI triage...',
                style: TextStyle(
                  color: CureBayColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI जांच चल रही है',
                style: TextStyle(color: CureBayColors.green, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: CureBayColors.background,
        appBar: AppBar(title: const Text('Error')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: CureBayColors.emergency, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Inference failed',
                style: TextStyle(
                  color: CureBayColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: CureBayColors.textMid, fontSize: 13)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil(
                    (route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final r = _result!;
    final g = _guidance!;
    final tColor = _triageColor(r.triage);

    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(
        title: const Text('Triage Result'),
        actions: [
          if (_saved)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle, color: CureBayColors.green),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Triage banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: tColor.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_triageEmoji(r.triage),
                          style: const TextStyle(fontSize: 36)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _triageLabel(r.triage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              _triageLabelHi(r.triage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Most likely diagnosis',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _humanizeDisease(r.topDisease),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Top 3 differential
            _Section(
              title: 'Top 3 Possible Conditions',
              child: Column(
                children: r.top3.map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: CureBayColors.navy,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${(d.probability * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _humanizeDisease(d.disease),
                          style: const TextStyle(
                            color: CureBayColors.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // What it is
            _Section(
              title: 'What is this?',
              child: Text(
                g.whatItIs,
                style: const TextStyle(
                  color: CureBayColors.textDark,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),

            // DO NOW
            if (g.doNow.isNotEmpty)
              _Section(
                title: 'DO NOW',
                titleIcon: Icons.check_circle,
                titleColor: CureBayColors.green,
                child: _BulletList(items: g.doNow, bulletColor: CureBayColors.green),
              ),

            // DO NOT
            if (g.doNot.isNotEmpty)
              _Section(
                title: 'DO NOT',
                titleIcon: Icons.cancel,
                titleColor: CureBayColors.emergency,
                child: _BulletList(items: g.doNot, bulletColor: CureBayColors.emergency),
              ),

            // Medicines
            if (g.medicines.isNotEmpty)
              _Section(
                title: 'Medicines',
                titleIcon: Icons.medication,
                child: _BulletList(items: g.medicines, bulletColor: CureBayColors.navy),
              ),

            // Refer to
            if (g.referTo.isNotEmpty)
              _Section(
                title: 'Refer To',
                titleIcon: Icons.local_hospital,
                titleColor: CureBayColors.urgent,
                child: Text(
                  g.referTo,
                  style: const TextStyle(
                    color: CureBayColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),

            // Tell facility
            if (g.tellFacility.isNotEmpty)
              _Section(
                title: 'Tell the Facility',
                titleIcon: Icons.phone_in_talk,
                child: _BulletList(items: g.tellFacility, bulletColor: CureBayColors.navy),
              ),

            // Watch for
            if (g.watchFor.isNotEmpty)
              _Section(
                title: 'Watch For (warning signs)',
                titleIcon: Icons.warning_amber,
                titleColor: CureBayColors.urgent,
                child: _BulletList(items: g.watchFor, bulletColor: CureBayColors.urgent),
              ),

            // Source
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CureBayColors.greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book, size: 14, color: CureBayColors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Source: ${g.source}',
                      style: const TextStyle(
                        color: CureBayColors.navy,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                backgroundColor: CureBayColors.navy,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home, size: 20),
                  SizedBox(width: 8),
                  Text('Done — Back to Home'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Patient saved to records',
                style: TextStyle(
                  color: CureBayColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Color? titleColor;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
    this.titleIcon,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CureBayColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, color: titleColor ?? CureBayColors.navy, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  color: titleColor ?? CureBayColors.navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color bulletColor;

  const _BulletList({required this.items, required this.bulletColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 7, right: 10),
              decoration: BoxDecoration(
                color: bulletColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  color: CureBayColors.textDark,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
