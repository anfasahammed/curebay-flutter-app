import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import 'result_screen.dart';

/// Stage 5: Vitals (all optional, defaults to normal range if skipped)
class VitalsScreen extends StatefulWidget {
  final Map<String, dynamic> demographics;
  final List<String> chipsSelected;
  final List<String> redFlagsYes;

  const VitalsScreen({
    super.key,
    required this.demographics,
    required this.chipsSelected,
    required this.redFlagsYes,
  });

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _temp = TextEditingController();
  final _pulse = TextEditingController();
  final _sbp = TextEditingController();
  final _dbp = TextEditingController();
  final _spo2 = TextEditingController();
  final _resp = TextEditingController();
  final _hb = TextEditingController();
  final _glucose = TextEditingController();

  @override
  void dispose() {
    _temp.dispose();
    _pulse.dispose();
    _sbp.dispose();
    _dbp.dispose();
    _spo2.dispose();
    _resp.dispose();
    _hb.dispose();
    _glucose.dispose();
    super.dispose();
  }

  Map<String, double> _collectVitals() {
    final v = <String, double>{};
    void addIf(String key, TextEditingController c) {
      final n = double.tryParse(c.text);
      if (n != null) v[key] = n;
    }
    addIf('temp_c', _temp);
    addIf('pulse_bpm', _pulse);
    addIf('sbp_mmhg', _sbp);
    addIf('dbp_mmhg', _dbp);
    addIf('spo2_pct', _spo2);
    addIf('resp_rate', _resp);
    addIf('hb_gdl', _hb);
    addIf('random_glucose', _glucose);
    return v;
  }

  void _proceed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          demographics: widget.demographics,
          chipsSelected: widget.chipsSelected,
          redFlagsYes: widget.redFlagsYes,
          vitals: _collectVitals(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: const Text('Vitals')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _Hint(),
            const SizedBox(height: 20),
            _VitalRow(
              icon: Icons.thermostat,
              label: 'Temperature',
              labelHi: 'तापमान',
              unit: '°C',
              normal: '36.5-37.2',
              controller: _temp,
            ),
            _VitalRow(
              icon: Icons.favorite,
              label: 'Pulse',
              labelHi: 'नब्ज़',
              unit: 'bpm',
              normal: '60-100',
              controller: _pulse,
            ),
            _VitalRow(
              icon: Icons.speed,
              label: 'Systolic BP',
              labelHi: 'ऊपर का BP',
              unit: 'mmHg',
              normal: '<140',
              controller: _sbp,
            ),
            _VitalRow(
              icon: Icons.speed,
              label: 'Diastolic BP',
              labelHi: 'नीचे का BP',
              unit: 'mmHg',
              normal: '<90',
              controller: _dbp,
            ),
            _VitalRow(
              icon: Icons.water_drop,
              label: 'SpO2',
              labelHi: 'ऑक्सीजन',
              unit: '%',
              normal: '95-100',
              controller: _spo2,
            ),
            _VitalRow(
              icon: Icons.air,
              label: 'Resp Rate',
              labelHi: 'सांस दर',
              unit: '/min',
              normal: '12-20',
              controller: _resp,
            ),
            _VitalRow(
              icon: Icons.opacity,
              label: 'Hemoglobin',
              labelHi: 'हीमोग्लोबिन',
              unit: 'g/dL',
              normal: '12-16',
              controller: _hb,
            ),
            _VitalRow(
              icon: Icons.science,
              label: 'Random Glucose',
              labelHi: 'शुगर',
              unit: 'mg/dL',
              normal: '<140',
              controller: _glucose,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _proceed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.psychology, size: 20),
                  SizedBox(width: 8),
                  Text('Run AI Triage / जांच करें'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CureBayColors.greenLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline,
              color: CureBayColors.green, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Skip any vital you cannot measure. Defaults will be used.',
              style: TextStyle(
                color: CureBayColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String labelHi;
  final String unit;
  final String normal;
  final TextEditingController controller;

  const _VitalRow({
    required this.icon,
    required this.label,
    required this.labelHi,
    required this.unit,
    required this.normal,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CureBayColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CureBayColors.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: CureBayColors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: CureBayColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$labelHi · normal $normal',
                  style: const TextStyle(
                    color: CureBayColors.textLight,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: CureBayColors.navy,
              ),
              decoration: InputDecoration(
                hintText: '—',
                suffixText: unit,
                suffixStyle: const TextStyle(
                  color: CureBayColors.textLight,
                  fontSize: 11,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
