class Patient {
  final String id;
  final String name;
  final int age;
  final String sex;             // M / F
  final String bloodGroup;
  final String ward;            // village / location
  final String? phone;
  final bool hasDiabetes;
  final bool hasHypertension;
  final bool isPregnant;
  final bool isSmoker;

  // Vitals (optional)
  final Map<String, double> vitals;

  // Symptoms
  final List<String> symptoms;
  final List<String> redFlags;

  // Triage result
  final String triage;          // emergency / urgent / normal
  final String topDisease;
  final List<TopDisease> top3Diseases;

  // Guidance shown to worker
  final List<String> doNow;
  final List<String> doNot;
  final String referTo;
  final List<String> watchFor;
  final String guidanceSource;

  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
    required this.bloodGroup,
    required this.ward,
    this.phone,
    this.hasDiabetes = false,
    this.hasHypertension = false,
    this.isPregnant = false,
    this.isSmoker = false,
    this.vitals = const {},
    this.symptoms = const [],
    this.redFlags = const [],
    required this.triage,
    required this.topDisease,
    this.top3Diseases = const [],
    this.doNow = const [],
    this.doNot = const [],
    this.referTo = '',
    this.watchFor = const [],
    this.guidanceSource = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class TopDisease {
  final String disease;
  final double probability;

  TopDisease({required this.disease, required this.probability});
}
