import 'package:flutter/material.dart';
import '../theme/curebay_theme.dart';
import 'complaint_screen.dart';

/// Patient registration form — name, age, sex, blood group, ward, comorbidities
class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _wardCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _sex = 'F';
  String _bloodGroup = 'Unknown';
  bool _hasDiabetes = false;
  bool _hasHypertension = false;
  bool _isPregnant = false;
  bool _isSmoker = false;

  final _bloodGroups = const [
    'Unknown', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _wardCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageCtrl.text);
    final demographics = {
      'name': _nameCtrl.text.trim(),
      'age': age,
      'sex': _sex,
      'bloodGroup': _bloodGroup,
      'ward': _wardCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'has_diabetes': _hasDiabetes ? 1 : 0,
      'has_hypertension': _hasHypertension ? 1 : 0,
      'is_pregnant': _isPregnant ? 1 : 0,
      'is_smoker': _isSmoker ? 1 : 0,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComplaintScreen(demographics: demographics),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CureBayColors.background,
      appBar: AppBar(title: const Text('Patient Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Basic Information / बुनियादी जानकारी'),
            const SizedBox(height: 12),
            _TextField(
              controller: _nameCtrl,
              label: 'Full Name / पूरा नाम',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter name' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _TextField(
                    controller: _ageCtrl,
                    label: 'Age / उम्र',
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter age';
                      final n = int.tryParse(v);
                      if (n == null || n < 0 || n > 120) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _SexPicker(
                    value: _sex,
                    onChanged: (v) => setState(() => _sex = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Dropdown(
              label: 'Blood Group / ब्लड ग्रुप',
              icon: Icons.bloodtype_outlined,
              value: _bloodGroup,
              items: _bloodGroups,
              onChanged: (v) => setState(() => _bloodGroup = v!),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Location / स्थान'),
            const SizedBox(height: 12),
            _TextField(
              controller: _wardCtrl,
              label: 'Village / Ward / गाँव',
              icon: Icons.location_on_outlined,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter location' : null,
            ),
            const SizedBox(height: 14),
            _TextField(
              controller: _phoneCtrl,
              label: 'Phone (optional) / फ़ोन',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Known Conditions / पुरानी बीमारियाँ'),
            const SizedBox(height: 8),
            _ToggleTile(
              label: 'Diabetes / मधुमेह (Sugar)',
              value: _hasDiabetes,
              onChanged: (v) => setState(() => _hasDiabetes = v),
            ),
            _ToggleTile(
              label: 'Hypertension / उच्च रक्तचाप (BP)',
              value: _hasHypertension,
              onChanged: (v) => setState(() => _hasHypertension = v),
            ),
            if (_sex == 'F')
              _ToggleTile(
                label: 'Pregnant / गर्भवती',
                value: _isPregnant,
                onChanged: (v) => setState(() => _isPregnant = v),
              ),
            _ToggleTile(
              label: 'Smoker / धूम्रपान',
              value: _isSmoker,
              onChanged: (v) => setState(() => _isSmoker = v),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _proceed,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continue / आगे बढ़ें'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: CureBayColors.navy,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: CureBayColors.green),
        labelStyle: const TextStyle(color: CureBayColors.textMid),
      ),
    );
  }
}

class _SexPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SexPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CureBayColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('F'),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: value == 'F'
                      ? CureBayColors.green
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Female',
                    style: TextStyle(
                      color: value == 'F'
                          ? Colors.white
                          : CureBayColors.textMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('M'),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: value == 'M'
                      ? CureBayColors.green
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Male',
                    style: TextStyle(
                      color: value == 'M'
                          ? Colors.white
                          : CureBayColors.textMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: CureBayColors.green),
        labelStyle: const TextStyle(color: CureBayColors.textMid),
      ),
      items: items
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: value ? CureBayColors.green : CureBayColors.divider),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(
            color: CureBayColors.textDark,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: CureBayColors.green,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
