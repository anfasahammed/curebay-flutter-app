import 'package:flutter/material.dart';
import '../models/patient.dart';

/// PDF service — full implementation in chunk 3
/// For chunk 1 this is a stub so the project compiles
class PdfService {
  static Future<void> shareSummary(Patient p) async {
    // Implemented in chunk 3
    debugPrint('PDF download for ${p.name} — coming in chunk 3');
  }
}
