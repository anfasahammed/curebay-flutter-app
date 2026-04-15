# CureBay Assist — Offline AI Triage for Rural Health Workers

> **Built for AIC 2026 — APOGEE Innovation Challenge by BITS Pilani**
> An on-device, Hindi-speaking AI medical triage assistant designed for ASHA workers and CureBay's Swasthya Mitras across rural India.

---

## 📥 Download APK

**[👉 Download CureBay Assist APK (~80 MB)]([App]https://drive.google.com/file/d/13bpFIAi0WJJg2MxXGqP4rktxEolMnDo6/view?usp=sharing**

> Compatible with: Android 7.0+ (API 24), 2 GB RAM minimum
> Runs **100% offline**. No internet required after install.

To install:
1. Download the APK to your Android phone
2. Open it from your Files app
3. Allow "Install from unknown sources" if prompted
4. Open the app and grant Microphone + Camera permissions when prompted

---

## 🩺 The Problem

In rural India, the patient–doctor reality is brutal:

- **74%** of doctors are concentrated in urban areas, serving only **28%** of the population
- **65%** of rural Indians lack access to fundamental healthcare
- **1 doctor per ~11,000 people** in rural districts — vs WHO's recommended 1:1000
- ASHA workers and Swasthya Mitras are the first line of contact, but they often:
  - Have limited diagnostic training
  - Cannot reliably reach a doctor on the phone
  - Have NO internet in remote villages
  - Face uncertainty deciding *Emergency vs Urgent vs Normal*

A 6-year-old with fever in rural Odisha may sit untreated for hours while a worker tries to figure out severity. By the time they reach a hospital, sepsis has set in.

**This app fixes that gap.**

---

## ✨ What the App Does

CureBay Assist is a **multimodal AI triage tool** that runs entirely on a low-end Android phone.

A health worker:
1. **Registers a patient** (name, age, sex, blood group, ward, comorbidities)
2. **Picks a chief complaint** from 8 visual icons (Fever, Cough, Stomach, Pain, Skin, Weakness, Pregnancy/Child, Injury/Bite)
3. **Optionally uses voice** in Hindi (Vosk on-device) to auto-tick symptoms
4. **Optionally captures a skin photo** (TFLite skin-lesion classifier)
5. **Selects symptom chips** specific to the chief complaint
6. **Answers Y/N red-flag safety questions** one at a time
7. **Enters vitals** (all optional — temperature, pulse, BP, SpO2, etc.)
8. **Receives a triage card**: 🔴 Emergency / 🟠 Urgent / 🟢 Normal, top-3 most likely conditions, and **DO / DO NOT / REFER** instructions sourced from WHO IMCI, ICMR, MoHFW
9. **Downloads a PDF summary** of the encounter to share via WhatsApp / Email / Drive

End-to-end time per patient: **60–90 seconds**.

---

## 🧠 The Tech Stack

| Component | Tech | Size |
|---|---|---|
| **Disease classifier** | XGBoost trained on 50k synthetic patients → ONNX | 1.6 MB |
| **Triage classifier** (Emergency/Urgent/Normal) | XGBoost ONNX | 0.6 MB |
| **Skin lesion classifier** | EfficientNetB0 fine-tuned on HAM10000 → TFLite | 4.5 MB |
| **Hindi voice ASR** | Vosk Hindi small-0.22 (on-device) | 50 MB |
| **Symptom dictionary** | 70+ canonical symptoms × ~250 Hindi phrases (Devanagari + romanized) | <100 KB |
| **Treatment guidance** | 28 disease blocks (WHO IMCI / ICMR / MoHFW / NVBDCP / NLEP) | <50 KB |
| **UI** | Flutter 3 (Material 3, CureBay-branded theme) | — |
| **Total APK** | ~80 MB | |

### Why these choices?

- **XGBoost ONNX**: Tiny (2 MB total), fast (<10 ms inference per patient), interpretable, runs on any phone
- **EfficientNetB0 TFLite**: Best accuracy/size trade-off for medical image classification on mobile
- **Vosk Hindi**: Only mature, fully-offline Hindi ASR — works without internet
- **YAML guidance** (compiled to Dart constants): Auditable, updateable without retraining
- **Flutter**: Single codebase, native performance, mature plugin ecosystem

---

## 📊 Model Performance

### XGBoost Disease Classifier (28 conditions)

| Metric | Value |
|---|---|
| **Top-3 accuracy** | **99.9%** |
| Top-1 accuracy | 87.4% |
| Average inference time | <10 ms (CPU only) |

### XGBoost Triage Classifier

| Metric | Value |
|---|---|
| Overall accuracy | 95.8% |
| **Emergency recall** | **99.2%** ⭐ critical metric |
| Urgent recall | 91.4% |
| Normal recall | 96.7% |

> Emergency recall is intentionally tuned high — false negatives (missing a true emergency) are far worse than false positives (over-triaging) in a triage tool.

### EfficientNetB0 Skin Classifier (3 classes)

| Class | Recall | Precision |
|---|---|---|
| skin_lesion_serious | 80% (with safety threshold) / 69% (argmax) | 64% |
| skin_normal | 90% | 92% |
| skin_rash | 91% | 73% |

| Aggregate | Value |
|---|---|
| Top-1 accuracy | 86.2% |
| **Macro-avg recall** | **83.4%** |

A safety threshold (default 0.30) is applied at inference time to bias the classifier toward flagging concerning lesions for dermatology review — appropriate for a triage tool where false negatives are dangerous.

---

## 🛡️ Safety Net — Red-Flag Override

The model's prediction is NEVER the final word. Every triage decision goes through a red-flag override layer:

```
Model says "normal" + Worker marked "altered_consciousness" = YES
→ FORCED TO EMERGENCY
```

Red flags include any one of:
- Drowsiness / unconsciousness
- Active seizure
- F.A.S.T stroke signs (face droop, arm weakness, slurred speech)
- Crushing chest pain + cold sweat
- Severe dehydration (sunken eyes, no urine 6h)
- Snake bite
- Vaginal bleeding in pregnancy
- Bluish lips / SpO2 < 90%
- Bleeding gums / dark urine (hemorrhagic fever signs)
- Baby unresponsive / cannot feed

**No matter what the AI predicts**, presence of any red flag forces at least Urgent (or Emergency for the most critical ones).

---

## 📋 Treatment Guidance (Auditable, Not AI-Generated)

For each predicted condition, the app shows:

- **What it is** — plain-language explanation for the worker to share
- **DO NOW** — immediate actions (e.g., "Lay patient on side", "Start ORS", "Give first dose of amoxicillin")
- **DO NOT** — common mistakes (e.g., "Do NOT apply tourniquet for snakebite", "Do NOT give aspirin in dengue")
- **Medicines** — first-dose recommendations
- **Refer To** — appropriate facility level (PHC / CHC / District Hospital / specialty center)
- **Tell Facility** — what info to relay (e.g., "Time symptoms started", "First dose given")
- **Watch For** — warning signs that require escalation
- **Source** — WHO IMCI, ICMR, MoHFW, NVBDCP, NLEP, IAP, NTEP — fully cited

This guidance is **YAML-sourced**, not generated by an LLM. It is deterministic, auditable, and updateable independent of model retraining — critical for medical contexts.

---

## 🗣️ Hindi Voice Input (Vosk)

The voice button on the symptom chips screen lets workers describe the patient in natural Hindi:

> *"बच्चे को तेज़ बुखार और उल्टी हो रही है"*
> (Child has high fever and is vomiting)

The transcript is parsed by a **Hindi colloquial dictionary** that handles:
- Devanagari script (बुखार, उल्टी, पेट दर्द)
- Romanized Hindi (bukhar, ulti, pet dard)
- Dehati / village-speech variants (loose motion, sugar, BP)
- Negation ("बुखार नहीं" → fever NOT included)

70+ canonical symptoms × ~250 phrase variations.

**Try saying:**
- "मुझे बुखार है" → ticks Fever
- "उल्टी हो रही है" → ticks Vomiting
- "मुंह टेढ़ा हो गया" → ticks Facial Droop (stroke alert)
- "साँप ने काटा है" → ticks Bite Mark (snakebite emergency)

---

## 📷 Skin Photo Classification

When the worker picks 🩹 Skin as the chief complaint, the camera opens automatically. After capture:

- **EfficientNetB0** classifies into 3 clinically meaningful categories:
  - 🟢 `skin_normal` — likely benign (mole, normal skin)
  - 🟠 `skin_rash` — viral / allergic rash
  - 🔴 `skin_lesion_serious` — refer to dermatology (melanoma, basal cell carcinoma, actinic keratosis)

A **safety threshold of 0.30** is applied to the serious class — if the model gives even moderate probability for a concerning lesion, it's flagged for referral. This is a deliberate tuning for triage safety.

---

## 🎨 Design — CureBay Brand

The UI matches CureBay's actual visual identity:
- Navy `#1A4789` + Green `#3FB97F` palette
- "CureBay / for a healthier India" branded header
- Rounded-corner cards, light-mint icon circles
- Bottom navigation: Home / Records / About
- Hindi + English labels throughout
- Big touch targets for older / less-literate workers
- Color-coded triage banners that read at-a-glance

---

## 📄 PDF Patient Summary

After every triage, the patient is automatically saved to the **Records** tab. Each record can be exported as a polished PDF containing:

- Triage banner (color-coded)
- Patient demographics + comorbidities
- Vitals recorded
- Reported symptoms + red flags (highlighted)
- Top-3 AI predictions with probabilities
- Full DO / DO NOT / REFER guidance
- Source citations
- Disclaimer

The PDF is shared via Android's native share sheet — workers can send to a doctor via WhatsApp, email it, or save to Google Drive. **No cloud upload happens** — the PDF is generated on-device and shared at the worker's discretion.

---

## 🔐 Privacy by Design

| Aspect | Implementation |
|---|---|
| Network | **Zero outbound network calls.** Add app to airplane mode — it works identically. |
| Storage | Patient records held in-memory for the session. Cleared when app closes. PDF is the persistent artifact, exported only when worker chooses. |
| Data sharing | Only when the worker explicitly taps "Download PDF" and picks a destination |
| Permissions | Microphone (voice), Camera (skin photo), Storage (PDF write). All grantable/revocable per Android norms. |
| AI training | All models trained offline by us. No federated learning, no telemetry. |

---

## 🏗️ Project Structure

```
curebay_assist/
├── android/                          # Android-specific config
│   └── app/src/main/
│       └── AndroidManifest.xml       # Mic + camera + storage permissions
├── assets/
│   ├── models/
│   │   ├── disease_model.onnx        # XGBoost — 28 diseases
│   │   ├── triage_model.onnx         # XGBoost — 3 triage levels
│   │   ├── skin_classifier.tflite    # EfficientNetB0
│   │   └── skin_classifier_labels.json
│   └── vosk/
│       └── vosk-model-small-hi-0.22/ # Hindi ASR
├── lib/
│   ├── main.dart                     # App entry + bottom nav shell
│   ├── theme/
│   │   └── curebay_theme.dart        # Brand colors + typography
│   ├── screens/
│   │   ├── home_screen.dart          # Landing + stats + Start CTA
│   │   ├── patient_form_screen.dart  # Demographics + comorbidities
│   │   ├── complaint_screen.dart     # 8-icon chief complaint grid
│   │   ├── chips_screen.dart         # Symptom chips + voice button
│   │   ├── camera_screen.dart        # Skin photo + classification
│   │   ├── red_flags_screen.dart     # Y/N safety questions
│   │   ├── vitals_screen.dart        # Optional vitals input
│   │   ├── result_screen.dart        # Triage card + DO/DO NOT/REFER
│   │   ├── records_screen.dart       # Patient list + PDF download
│   │   └── about_screen.dart         # Tech info + disclaimer
│   ├── services/
│   │   ├── triage_engine.dart        # ONNX inference orchestrator
│   │   ├── voice_service.dart        # Vosk wrapper
│   │   ├── skin_classifier_service.dart  # TFLite wrapper
│   │   ├── pdf_service.dart          # PDF generation + share
│   │   ├── hindi_dictionary.dart     # Hindi → symptom IDs
│   │   ├── symptom_registry.dart     # Chips + red flags per complaint
│   │   ├── treatment_guidance.dart   # 28 disease guidance blocks
│   │   ├── schema.dart               # Feature ordering + class names
│   │   └── patient_store.dart        # In-memory patient cache
│   ├── widgets/
│   │   └── voice_button.dart         # Tap-to-record voice UI
│   └── models/
│       └── patient.dart              # Patient data model
└── pubspec.yaml                      # Dependencies
```

---

## 🛠️ Build From Source

### Prerequisites
- Flutter SDK 3.10+
- Android SDK with API 24+
- A USB-connected Android phone OR emulator

### Steps

```bash
# 1. Clone this repo
git clone <this-repo-url>
cd curebay_assist

# 2. Download required model assets (NOT in this repo due to size)
# - disease_model.onnx & triage_model.onnx → assets/models/
# - skin_classifier.tflite & skin_classifier_labels.json → assets/models/
#   (See companion repo: <link to model-training repo>)

# 3. Download Vosk Hindi model
# Get vosk-model-small-hi-0.22.zip from https://alphacephei.com/vosk/models
# Unzip into assets/vosk/

# 4. Install dependencies
flutter pub get

# 5. Run on connected phone
flutter run

# 6. Build release APK
flutter build apk --release
# → output at build/app/outputs/flutter-apk/app-release.apk
```

### Asset folder structure required

```
assets/
├── models/
│   ├── disease_model.onnx          (~1.6 MB)
│   ├── triage_model.onnx           (~0.6 MB)
│   ├── skin_classifier.tflite      (~4.5 MB)
│   └── skin_classifier_labels.json
└── vosk/
    └── vosk-model-small-hi-0.22/
        ├── am/final.mdl
        ├── conf/
        ├── graph/
        │   ├── HCLr.fst
        │   ├── Gr.fst
        │   ├── words.txt
        │   ├── disambig_tid.int
        │   └── phones/word_boundary.int
        ├── ivector/
        └── README
```

---

## 🔗 Companion Repository

The data generation, model training, configs, and reference Python pipeline live in a separate repo:

**[👉 CureBay Assist — Model Training & Data Pipeline](LINK_TO_OTHER_REPO_HERE)**

Includes:
- Synthetic patient dataset generator (50k patients, 28 diseases)
- XGBoost training notebook + ONNX export
- EfficientNetB0 skin classifier training notebook
- All YAML configs (chief complaints, symptom dictionary, treatment guidance, disease profiles)
- Reference Python pipeline (`demo.py`) that mirrors what the app does
- Sources documented for every disease and treatment recommendation

---

## ⚠️ Disclaimer

This app provides **decision-support for trained health workers**, NOT medical diagnosis. All recommendations are sourced from national protocols (WHO IMCI, ICMR, MoHFW, NVBDCP, NLEP). Final treatment decisions must be made by a qualified physician.

The AI models are trained on synthetic data validated against published clinical guidelines. They have not been validated in a real clinical trial. Use as a **screening and triage aid only**, in conjunction with worker training and supervision.

---

## 🙏 Acknowledgments

- **CureBay** — for inspiring the problem statement through their work on rural eClinics across Odisha and Chhattisgarh
- **Anthropic / OpenAI** — for development assistance during the AIC build sprint
- **Vosk / AlphaCephei** — for the Hindi ASR model
- **HAM10000 / ISIC** — for the dermatology dataset
- **WHO, ICMR, MoHFW, NVBDCP, NLEP, IAP, NTEP** — for clinical protocols
- **AIC 2026 / APOGEE / BITS Pilani** — for the platform

---

**Built with care for rural India 🇮🇳**
