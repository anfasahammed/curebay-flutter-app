import '../models/patient.dart';

/// In-memory patient store — no cloud, no persistent storage.
/// Records exist for the app session only.
/// (Per requirement: "no storage or cloud — but downloadable")
class PatientStore {
  PatientStore._();
  static final PatientStore instance = PatientStore._();

  final List<Patient> _patients = [];

  void add(Patient p) => _patients.insert(0, p);
  List<Patient> all() => List.unmodifiable(_patients);
  void clear() => _patients.clear();
  int get length => _patients.length;
}
