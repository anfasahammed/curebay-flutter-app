/// Schema constants — baked from feature_schema.json + label_encoders.json
/// So the app doesn't need to parse JSON at startup
class Schema {
  static const List<String> demographicFeatures = [
    'age',
    'sex',
    'has_diabetes',
    'has_hypertension',
    'is_smoker',
  ];

  static const List<String> vitalFeatures = [
    'temp_c',
    'pulse_bpm',
    'sbp_mmhg',
    'dbp_mmhg',
    'spo2_pct',
    'resp_rate',
    'hb_gdl',
    'hba1c_pct',
    'random_glucose',
  ];

  /// Default values for vitals (used when worker skips them)
  static const Map<String, double> normalVitals = {
    'temp_c':         37.0,
    'pulse_bpm':      80.0,
    'sbp_mmhg':       120.0,
    'dbp_mmhg':       80.0,
    'spo2_pct':       98.0,
    'resp_rate':      16.0,
    'hb_gdl':         13.0,
    'hba1c_pct':      5.4,
    'random_glucose': 100.0,
  };

  /// All 71 symptom feature names (mirrors generate_dataset.py SYMPTOMS list)
  static const List<String> symptomFeatures = [
    'sym_fever', 'sym_high_fever', 'sym_chills', 'sym_sweating',
    'sym_fatigue', 'sym_weakness', 'sym_weight_loss', 'sym_night_sweats',
    'sym_loss_of_appetite',
    'sym_cough', 'sym_dry_cough', 'sym_productive_cough', 'sym_blood_in_sputum',
    'sym_shortness_of_breath', 'sym_chest_pain', 'sym_fast_breathing',
    'sym_chest_indrawing', 'sym_wheezing', 'sym_sore_throat', 'sym_runny_nose',
    'sym_vomiting', 'sym_nausea', 'sym_diarrhea', 'sym_watery_diarrhea',
    'sym_bloody_diarrhea', 'sym_rice_water_stool', 'sym_abdominal_pain',
    'sym_constipation', 'sym_jaundice', 'sym_dehydration_signs',
    'sym_sunken_eyes', 'sym_reduced_urine',
    'sym_headache', 'sym_severe_headache', 'sym_altered_consciousness',
    'sym_seizure', 'sym_neck_stiffness', 'sym_facial_droop', 'sym_arm_weakness',
    'sym_slurred_speech', 'sym_dizziness', 'sym_numbness_patch',
    'sym_loss_of_sensation',
    'sym_palpitations', 'sym_crushing_chest_pain', 'sym_radiating_arm_pain',
    'sym_cold_sweat', 'sym_syncope',
    'sym_body_ache', 'sym_muscle_cramps', 'sym_joint_pain', 'sym_back_pain',
    'sym_skin_rash', 'sym_hypopigmented_patch', 'sym_skin_ulcer', 'sym_wound',
    'sym_swelling', 'sym_bleeding_gums', 'sym_petechiae', 'sym_bite_mark',
    'sym_burning_urination', 'sym_frequent_urination', 'sym_dark_urine',
    'sym_blood_in_urine',
    'sym_poor_feeding', 'sym_lethargy_infant', 'sym_yellow_skin_newborn',
    'sym_eye_redness', 'sym_vision_problems',
    'sym_ear_pain', 'sym_ear_discharge',
  ];

  static List<String> get allFeatures => [
        ...demographicFeatures,
        ...vitalFeatures,
        ...symptomFeatures,
      ];

  /// Number of features (must match what the model was trained on)
  static int get totalFeatures => allFeatures.length;

  /// Disease classes from label_encoders.json (28 after wound removal)
  /// IMPORTANT: This MUST be in the exact alphabetical order LabelEncoder produced.
  static const List<String> diseaseClasses = [
    'acute_diarrhea',
    'acute_mi',
    'chikungunya',
    'cholera',
    'copd_exacerbation',
    'dengue',
    'filariasis',
    'gastritis',
    'heat_stroke',
    'hypertension_uncontrolled',
    'iron_deficiency_anemia',
    'japanese_encephalitis',
    'leprosy',
    'malaria',
    'migraine',
    'neonatal_jaundice',
    'pneumonia',
    'scrub_typhus',
    'severe_dehydration_child',
    'severe_pneumonia_child',
    'sickle_cell_crisis',
    'snakebite',
    'stroke',
    'tuberculosis',
    'type2_diabetes_uncontrolled',
    'typhoid',
    'uti',
    'viral_fever_uri',
  ];

  static const List<String> triageClasses = [
    'emergency',
    'normal',
    'urgent',
  ];
}
