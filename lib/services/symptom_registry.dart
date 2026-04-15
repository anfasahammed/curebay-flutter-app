/// Symptom registry — derived from chief_complaints.yaml
/// Hardcoded in Dart for fast loading and zero file I/O on chip screens.
class SymptomRegistry {
  /// Returns chips for a complaint key
  static List<SymptomChip> chipsFor(String complaintKey) {
    return _chips[complaintKey] ?? [];
  }

  /// Returns red flag questions for a complaint key
  static List<SymptomChip> redFlagsFor(String complaintKey) {
    return _redFlags[complaintKey] ?? [];
  }

  static const Map<String, List<SymptomChip>> _chips = {
    'fever': [
      SymptomChip('high_fever',   'Very high fever (>39°C)'),
      SymptomChip('chills',       'Chills / shivering'),
      SymptomChip('sweating',     'Sweating a lot'),
      SymptomChip('body_ache',    'Body ache'),
      SymptomChip('headache',     'Headache'),
      SymptomChip('vomiting',     'Vomiting'),
      SymptomChip('cough',        'Cough'),
      SymptomChip('skin_rash',    'Skin rash'),
      SymptomChip('joint_pain',   'Joint pain'),
      SymptomChip('night_sweats', 'Night sweats (>2 weeks)'),
    ],
    'respiratory': [
      SymptomChip('cough',               'Cough'),
      SymptomChip('productive_cough',    'Cough with phlegm'),
      SymptomChip('dry_cough',           'Dry cough'),
      SymptomChip('blood_in_sputum',     'Blood in cough'),
      SymptomChip('shortness_of_breath', 'Shortness of breath'),
      SymptomChip('fast_breathing',      'Fast breathing'),
      SymptomChip('chest_pain',          'Chest pain'),
      SymptomChip('wheezing',            'Wheezing'),
      SymptomChip('sore_throat',         'Sore throat'),
      SymptomChip('runny_nose',          'Runny nose'),
      SymptomChip('fever',               'Fever along with this'),
      SymptomChip('night_sweats',        'Night sweats'),
      SymptomChip('weight_loss',         'Weight loss (>2 weeks)'),
    ],
    'gi': [
      SymptomChip('diarrhea',         'Loose motions'),
      SymptomChip('watery_diarrhea',  'Very watery stools'),
      SymptomChip('bloody_diarrhea',  'Blood in stool'),
      SymptomChip('rice_water_stool', 'Rice-water like stool'),
      SymptomChip('vomiting',         'Vomiting'),
      SymptomChip('nausea',           'Nausea / feeling sick'),
      SymptomChip('abdominal_pain',   'Stomach pain'),
      SymptomChip('constipation',     'Constipation'),
      SymptomChip('jaundice',         'Yellow eyes / skin'),
      SymptomChip('loss_of_appetite', 'No appetite'),
      SymptomChip('fever',            'Fever along with this'),
    ],
    'pain': [
      SymptomChip('headache',            'Headache'),
      SymptomChip('severe_headache',     'Worst headache ever'),
      SymptomChip('chest_pain',          'Chest pain'),
      SymptomChip('crushing_chest_pain', 'Crushing chest pain'),
      SymptomChip('radiating_arm_pain',  'Pain spreading to arm/jaw'),
      SymptomChip('abdominal_pain',      'Stomach pain'),
      SymptomChip('back_pain',           'Back pain'),
      SymptomChip('joint_pain',          'Joint pain'),
      SymptomChip('body_ache',           'Whole body ache'),
      SymptomChip('muscle_cramps',       'Muscle cramps'),
      SymptomChip('ear_pain',            'Ear pain'),
      SymptomChip('burning_urination',   'Burning urination'),
    ],
    'skin': [
      SymptomChip('skin_rash',           'Rash on skin'),
      SymptomChip('hypopigmented_patch', 'Pale / white patch'),
      SymptomChip('skin_ulcer',          'Open ulcer / sore'),
      SymptomChip('swelling',            'Swelling'),
      SymptomChip('loss_of_sensation',   'Numbness in patch'),
      SymptomChip('numbness_patch',      'Cannot feel touch'),
      SymptomChip('fever',               'Fever along with this'),
    ],
    'neuro': [
      SymptomChip('weakness',              'General weakness'),
      SymptomChip('fatigue',               'Tired all the time'),
      SymptomChip('dizziness',             'Dizzy / spinning'),
      SymptomChip('facial_droop',          'Face drooping one side'),
      SymptomChip('arm_weakness',          'Arm or leg weakness'),
      SymptomChip('slurred_speech',        'Slurred speech'),
      SymptomChip('altered_consciousness', 'Drowsy / not responding'),
      SymptomChip('seizure',               'Seizure / fits'),
      SymptomChip('numbness_patch',        'Numbness'),
      SymptomChip('syncope',               'Fainted / passed out'),
      SymptomChip('vision_problems',       'Vision problems'),
      SymptomChip('severe_headache',       'Severe headache'),
    ],
    'maternal_child': [
      SymptomChip('yellow_skin_newborn',   'Newborn yellow skin'),
      SymptomChip('poor_feeding',          'Baby not feeding well'),
      SymptomChip('lethargy_infant',       'Baby very sleepy'),
      SymptomChip('fast_breathing',        'Fast breathing (child)'),
      SymptomChip('chest_indrawing',       'Chest sucking in (child)'),
      SymptomChip('fever',                 'Fever in child'),
      SymptomChip('diarrhea',              'Loose motions (child)'),
      SymptomChip('vomiting',              'Vomiting (child)'),
      SymptomChip('vaginal_bleeding',      'Vaginal bleeding (preg)'),
      SymptomChip('severe_abdominal_pain', 'Severe stomach pain (preg)'),
      SymptomChip('severe_headache',       'Severe headache (preg)'),
      SymptomChip('vision_problems',       'Blurred vision (preg)'),
      SymptomChip('swelling',              'Swelling feet/face (preg)'),
    ],
    'injury_bite': [
      SymptomChip('bite_mark',             'Visible bite mark'),
      SymptomChip('snake_bite',            'Snake bite'),
      SymptomChip('dog_bite',              'Dog / animal bite'),
      SymptomChip('wound',                 'Cut / wound'),
      SymptomChip('swelling',              'Swelling at bite/wound'),
      SymptomChip('bleeding',              'Bleeding'),
      SymptomChip('vomiting',              'Vomiting after bite'),
      SymptomChip('bleeding_gums',         'Bleeding from gums'),
      SymptomChip('dark_urine',            'Cola-coloured urine'),
      SymptomChip('shortness_of_breath',   'Difficulty breathing'),
    ],
  };

  static const Map<String, List<SymptomChip>> _redFlags = {
    'fever': [
      SymptomChip('altered_consciousness', 'Drowsy or unconscious?'),
      SymptomChip('seizure',               'Had a seizure / fits?'),
      SymptomChip('neck_stiffness',        'Neck stiff / can\'t bend?'),
      SymptomChip('bleeding_gums',         'Bleeding from gums or nose?'),
      SymptomChip('jaundice',              'Yellow eyes or skin?'),
    ],
    'respiratory': [
      SymptomChip('chest_indrawing',       'Chest sucking inward (child)?'),
      SymptomChip('cyanosis',              'Bluish lips or fingertips?'),
      SymptomChip('altered_consciousness', 'Drowsy / confused?'),
      SymptomChip('spo2_low',              'SpO2 below 90%?'),
      SymptomChip('crushing_chest_pain',   'Crushing chest pain?'),
    ],
    'gi': [
      SymptomChip('dehydration_signs',     'Sunken eyes, no urine 6h?'),
      SymptomChip('lethargy_infant',       'Child very sleepy?'),
      SymptomChip('altered_consciousness', 'Adult drowsy / confused?'),
      SymptomChip('severe_dehydration',    'Skin pinch slow back?'),
      SymptomChip('bloody_diarrhea',       'Blood in vomit / stool?'),
    ],
    'pain': [
      SymptomChip('cold_sweat',            'Cold sweat with chest pain?'),
      SymptomChip('shortness_of_breath',   'Difficulty breathing?'),
      SymptomChip('altered_consciousness', 'Drowsy / confused?'),
      SymptomChip('facial_droop',          'Face drooping one side?'),
      SymptomChip('vision_problems',       'Vision problems?'),
    ],
    'skin': [
      SymptomChip('high_fever',            'High fever with skin problem?'),
      SymptomChip('loss_of_sensation',     'Lost feeling in patch?'),
      SymptomChip('spreading_redness',     'Red streaks spreading?'),
      SymptomChip('skin_ulcer',            'Deep ulcer not healing?'),
    ],
    'neuro': [
      SymptomChip('facial_droop',          'F.A.S.T: Face drooping?'),
      SymptomChip('arm_weakness',          'F.A.S.T: Arm weakness?'),
      SymptomChip('slurred_speech',        'F.A.S.T: Slurred speech?'),
      SymptomChip('altered_consciousness', 'Confused / unresponsive?'),
      SymptomChip('seizure_active',        'Currently seizing?'),
    ],
    'maternal_child': [
      SymptomChip('lethargy_infant',       'Baby unresponsive?'),
      SymptomChip('vaginal_bleeding',      'Heavy bleeding (preg)?'),
      SymptomChip('seizure',               'Seizure (pregnant)?'),
      SymptomChip('chest_indrawing',       'Severe breathing (child)?'),
      SymptomChip('cant_feed',             'Baby cannot feed at all?'),
    ],
    'injury_bite': [
      SymptomChip('snake_bite',            'Confirmed snake bite?'),
      SymptomChip('altered_consciousness', 'Drowsy or unresponsive?'),
      SymptomChip('shortness_of_breath',   'Trouble breathing?'),
      SymptomChip('bleeding_gums',         'Bleeding from gums/nose?'),
      SymptomChip('dark_urine',            'Cola-coloured urine?'),
    ],
  };

  /// Symptoms that force triage to emergency
  static const Set<String> forceEmergency = {
    'altered_consciousness', 'seizure', 'seizure_active',
    'facial_droop', 'arm_weakness', 'slurred_speech',
    'crushing_chest_pain', 'cold_sweat',
    'chest_indrawing', 'cyanosis',
    'lethargy_infant', 'vaginal_bleeding', 'severe_dehydration',
    'bleeding_gums', 'dark_urine', 'snake_bite', 'cant_feed', 'spo2_low',
  };

  /// Symptoms that force triage to at least urgent
  static const Set<String> forceUrgentMinimum = {
    'bloody_diarrhea', 'dehydration_signs', 'jaundice', 'high_fever',
    'shortness_of_breath', 'vision_problems', 'neck_stiffness',
    'spreading_redness', 'loss_of_sensation',
    'severe_headache', 'severe_abdominal_pain',
  };
}

class SymptomChip {
  final String id;
  final String label;
  const SymptomChip(this.id, this.label);
}
