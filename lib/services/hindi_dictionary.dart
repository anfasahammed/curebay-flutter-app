/// Hindi colloquial → canonical symptom mapping
/// Dart port of symptom_dictionary.yaml
class HindiSymptomDictionary {
  static const Map<String, List<String>> _symptomToPhrases = {
    'fever': ['fever', 'bukhar', 'bukhaar', 'tap', 'jwar',
              'बुखार', 'ज्वर', 'बुखार है', 'मुझे बुखार', 'बच्चे को बुखार',
              'garmi lag rahi hai', 'garam ho gaya', 'body garam', 'tan garam'],
    'high_fever': ['tej bukhar', 'tez bukhar', 'high fever', 'bahut bukhar',
                   'तेज़ बुखार', 'तेज बुखार', 'बहुत बुखार',
                   'khub bukhar', 'jor ka bukhar'],
    'chills': ['chills', 'shivering', 'kanp', 'kapna', 'thand', 'thandi', 'kapkapi',
               'ठंड', 'ठंड लग रही', 'कंपकंपी', 'कांप रहा',
               'thand lag rahi hai', 'kapkapi ho rahi'],
    'sweating': ['sweat', 'sweating', 'paseena', 'pasina',
                 'पसीना', 'पसीना आ रहा', 'बहुत पसीना',
                 'paseena aa raha', 'bahut paseena'],
    'fatigue': ['tired', 'thakan', 'thaka', 'thaki',
                'थकान', 'थका हुआ',
                'thak gaya', 'thakan ho rahi'],
    'weakness': ['weakness', 'kamjori', 'kamzori', 'kamjor', 'kamzor', 'durbal',
                 'कमज़ोरी', 'कमजोरी', 'कमज़ोर',
                 'kamzor lag raha', 'shakti nahi'],
    'cough': ['cough', 'khansi', 'khasi', 'khaansi',
              'खांसी', 'खाँसी', 'खांसी आ रही'],
    'dry_cough': ['dry cough', 'sukhi khansi', 'sookhi khansi',
                   'सूखी खांसी'],
    'productive_cough': ['phlegm', 'sputum', 'balgam', 'kapha',
                          'बलगम', 'कफ', 'बलगम वाली खांसी',
                          'balgam aa raha', 'balgam wali khansi'],
    'blood_in_sputum': ['blood in cough', 'खून की खांसी', 'खांसी में खून',
                         'khoon ki khansi', 'khansi me khoon'],
    'shortness_of_breath': ['shortness of breath',
                             'सांस फूल रही', 'सांस नहीं ले पा रहा', 'दम घुट रहा',
                             'saans phoolti', 'saans nahi le pa raha', 'dum ghut raha'],
    'fast_breathing': ['fast breathing', 'tez saans', 'jaldi saans',
                        'तेज़ सांस', 'जल्दी जल्दी सांस'],
    'chest_pain': ['chest pain', 'chati dard', 'chhati dard', 'seena dard',
                    'सीने में दर्द', 'छाती में दर्द', 'चाती में दर्द'],
    'crushing_chest_pain': ['crushing chest pain',
                             'छाती दब रही', 'छाती पर पत्थर',
                             'chati pe pathar', 'chati dab rahi'],
    'sore_throat': ['sore throat', 'gala dard', 'gala kharab',
                     'गला दर्द', 'गला खराब', 'गले में दर्द'],
    'runny_nose': ['runny nose', 'sardi', 'zukam',
                    'सर्दी', 'जुकाम', 'नाक से पानी',
                    'naak se paani', 'sardi lag gayi'],
    'vomiting': ['vomit', 'vomiting', 'ulti', 'ulta',
                  'उल्टी', 'उल्टी हो रही', 'कै', 'कै हो रही',
                  'ulti ho rahi', 'kai ho rahi'],
    'nausea': ['nausea', 'ji michla', 'jee michla',
                'जी मिचला', 'मतली'],
    'diarrhea': ['diarrhea', 'loose motion', 'loose motions', 'dast', 'patla',
                  'दस्त', 'पतला', 'लूज़ मोशन', 'पेट खराब',
                  'patla pakhana', 'pet kharab'],
    'watery_diarrhea': ['watery stool', 'pani jaisa',
                         'पानी जैसा', 'पानी जैसा पाखाना'],
    'bloody_diarrhea': ['bloody stool', 'blood in stool',
                         'खून वाला दस्त', 'पाखाना में खून',
                         'pakhana me khoon', 'dast me khoon'],
    'abdominal_pain': ['stomach pain', 'pet dard', 'pet me dard',
                        'पेट दर्द', 'पेट में दर्द', 'पेट दुख रहा'],
    'jaundice': ['jaundice', 'yellow skin', 'yellow eyes', 'peeli', 'peelia',
                  'पीलिया', 'आंखें पीली', 'त्वचा पीली'],
    'dehydration_signs': ['dehydration',
                           'पानी की कमी', 'मुंह सूखा',
                           'pani ki kami', 'moonh sukha'],
    'reduced_urine': ['no urine', 'kam peshab', 'peshab nahi',
                       'पेशाब नहीं', 'पेशाब बंद'],
    'headache': ['headache', 'sir dard', 'sar dard',
                  'सिर दर्द', 'सर दर्द', 'सिर में दर्द', 'मस्तक दर्द'],
    'severe_headache': ['severe headache', 'bahut sir dard', 'tez sir dard',
                         'बहुत तेज़ सिर दर्द', 'सिर बहुत दर्द'],
    'altered_consciousness': ['unconscious', 'behos', 'behoshi',
                                'बेहोश', 'होश नहीं', 'सुस्त'],
    'seizure': ['seizure', 'fits', 'mirgi', 'fit aaya',
                 'मिर्गी', 'दौरा', 'फिट आया'],
    'neck_stiffness': ['stiff neck', 'gardan akad',
                        'गर्दन अकड़', 'गला सख्त'],
    'facial_droop': ['face droop',
                      'मुंह टेढ़ा', 'चेहरा टेढ़ा', 'मुंह लटक',
                      'munh tedha', 'chehra tedha'],
    'arm_weakness': ['arm weakness',
                      'हाथ कमज़ोर', 'हाथ उठ नहीं रहा', 'हाथ काम नहीं कर रहा',
                      'haath uth nahi raha', 'haath kamjor'],
    'slurred_speech': ['slurred speech',
                        'साफ नहीं बोल पा रहा', 'बोलने में दिक्कत',
                        'saaf nahi bol pa raha'],
    'dizziness': ['dizziness', 'dizzy', 'chakkar',
                   'चक्कर', 'चक्कर आ रहा', 'सिर घूम रहा'],
    'palpitations': ['palpitations', 'dhadkan tez',
                      'धड़कन तेज़', 'दिल तेज़ चल रहा'],
    'cold_sweat': ['cold sweat',
                    'ठंडा पसीना', 'थर थर पसीना',
                    'thanda paseena'],
    'body_ache': ['body ache', 'badan dard', 'shareer dard',
                   'बदन दर्द', 'शरीर में दर्द', 'पूरे बदन दर्द'],
    'joint_pain': ['joint pain', 'jod dard', 'ghutne dard',
                    'जोड़ दर्द', 'घुटने में दर्द'],
    'back_pain': ['back pain', 'kamar dard', 'peeth dard',
                   'कमर दर्द', 'पीठ दर्द'],
    'skin_rash': ['rash', 'skin rash', 'twacha daag',
                   'दाग', 'त्वचा पर दाग', 'दाने', 'फोड़ा'],
    'hypopigmented_patch': ['white patch', 'safed daag',
                              'सफेद दाग', 'सफेद धब्बा'],
    'wound': ['wound', 'cut', 'ghav', 'chot',
               'घाव', 'चोट', 'कट गया'],
    'swelling': ['swelling', 'sujan', 'soojan',
                  'सूजन', 'फूल गया', 'सूजन आ गई'],
    'bleeding_gums': ['bleeding gums',
                       'मसूड़ों से खून', 'मुंह से खून'],
    'bite_mark': ['bite', 'saap kata', 'saanp kata', 'kutta kata',
                   'सांप ने काटा', 'कुत्ते ने काटा', 'काटने का निशान'],
    'burning_urination': ['burning urination',
                            'पेशाब में जलन', 'पेशाब करते समय जलन'],
    'frequent_urination': ['frequent urination',
                              'बार बार पेशाब'],
    'dark_urine': ['dark urine',
                    'गहरा पेशाब', 'चाय जैसा पेशाब'],
    'blood_in_urine': ['blood in urine',
                         'पेशाब में खून'],
    'poor_feeding': ['not feeding',
                      'दूध नहीं पी रहा', 'बच्चा दूध नहीं'],
    'lethargy_infant': ['baby lethargic',
                          'बच्चा सुस्त', 'बच्चा हिल नहीं रहा'],
    'yellow_skin_newborn': ['newborn jaundice',
                              'नवजात पीला', 'नया बच्चा पीला'],
    'vaginal_bleeding': ['vaginal bleeding',
                           'गर्भवती खून', 'योनि से खून', 'प्रेग्नेंसी में खून'],
    'vision_problems': ['blurred vision',
                          'धुंधला', 'साफ नहीं दिख रहा', 'आंखें धुंधली'],
    'eye_redness': ['red eye',
                     'आंखें लाल'],
    'ear_pain': ['ear pain',
                  'कान दर्द', 'कान में दर्द'],
    'ear_discharge': ['ear discharge',
                       'कान से पानी', 'कान बह रहा'],
  };

  static const Set<String> _negationWords = {
    'no', 'not', 'nahi', 'nahin', 'nai',
  };

  static const Map<String, Map<String, int>> _complaintMap = {
    'fever': {
      'fever': 3, 'high_fever': 3, 'chills': 2, 'sweating': 2, 'body_ache': 1,
      'headache': 1, 'night_sweats': 2,
    },
    'respiratory': {
      'cough': 3, 'dry_cough': 3, 'productive_cough': 3, 'blood_in_sputum': 3,
      'shortness_of_breath': 3, 'fast_breathing': 2, 'chest_pain': 2,
      'wheezing': 2, 'sore_throat': 1, 'runny_nose': 1,
    },
    'gi': {
      'diarrhea': 3, 'watery_diarrhea': 3, 'bloody_diarrhea': 3,
      'rice_water_stool': 3, 'vomiting': 2, 'nausea': 1, 'abdominal_pain': 2,
      'constipation': 1, 'jaundice': 2,
    },
    'pain': {
      'headache': 2, 'severe_headache': 3, 'chest_pain': 3,
      'crushing_chest_pain': 3, 'radiating_arm_pain': 3,
      'abdominal_pain': 2, 'back_pain': 2, 'joint_pain': 1, 'body_ache': 1,
    },
    'skin': {
      'skin_rash': 3, 'hypopigmented_patch': 3, 'skin_ulcer': 3, 'wound': 3,
      'swelling': 2, 'bite_mark': 3, 'numbness_patch': 2, 'loss_of_sensation': 2,
    },
    'neuro': {
      'altered_consciousness': 3, 'seizure': 3, 'facial_droop': 3,
      'arm_weakness': 3, 'slurred_speech': 3, 'severe_headache': 2,
      'syncope': 2, 'dizziness': 1, 'weakness': 1,
    },
    'maternal_child': {
      'poor_feeding': 3, 'lethargy_infant': 3, 'yellow_skin_newborn': 3,
      'vaginal_bleeding': 3, 'vision_problems': 1,
    },
    'injury_bite': {
      'bite_mark': 3, 'wound': 2, 'swelling': 2, 'bleeding_gums': 2,
      'dark_urine': 2,
    },
  };

  /// Extract canonical symptoms from a Hindi/mixed-Hindi transcript.
  static Set<String> extract(String transcript) {
    final cleaned = transcript.toLowerCase().trim();
    if (cleaned.isEmpty) return {};
    final paddedText = ' $cleaned ';
    final found = <String>{};

    // Sort phrases longer-first so "tez bukhar" matches before "bukhar"
    final allEntries = <_Phrase>[];
    _symptomToPhrases.forEach((sym, phrases) {
      for (final p in phrases) {
        allEntries.add(_Phrase(symptom: sym, phrase: p.toLowerCase()));
      }
    });
    allEntries.sort((a, b) => b.phrase.length.compareTo(a.phrase.length));

    for (final entry in allEntries) {
      final phrase = entry.phrase;
      int searchStart = 0;
      while (true) {
        final idx = paddedText.indexOf(phrase, searchStart);
        if (idx < 0) break;
        if (!_isNegated(paddedText, idx)) {
          found.add(entry.symptom);
        }
        searchStart = idx + phrase.length;
      }
    }
    return found;
  }

  static bool _isNegated(String text, int matchStart) {
    final before = text.substring(0, matchStart).trim();
    if (before.isEmpty) return false;
    final words = before.split(RegExp(r'\s+'));
    if (words.isEmpty) return false;
    final lastWord = words.last;
    return _negationWords.contains(lastWord);
  }

  /// Pick the chief complaint with the highest weighted symptom match.
  static String? routeComplaint(Set<String> symptoms) {
    if (symptoms.isEmpty) return null;
    String? best;
    int bestScore = 0;
    _complaintMap.forEach((complaint, weights) {
      int score = 0;
      for (final s in symptoms) {
        score += weights[s] ?? 0;
      }
      if (score > bestScore) {
        bestScore = score;
        best = complaint;
      }
    });
    return best;
  }
}

class _Phrase {
  final String symptom;
  final String phrase;
  _Phrase({required this.symptom, required this.phrase});
}
