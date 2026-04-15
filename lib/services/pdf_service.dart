import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';

/// Generates a polished PDF summary of the patient triage and shares it.
/// All on-device — no cloud, no upload.
class PdfService {
  /// Build PDF and share via system share sheet.
  static Future<void> shareSummary(Patient p) async {
    final pdfBytes = await _buildPdf(p);
    final dir = await getTemporaryDirectory();
    final filename = _filename(p);
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'CureBay Triage Summary — ${p.name}',
      text: 'Patient triage summary from CureBay Assist',
    );
  }

  static String _filename(Patient p) {
    final safeName = p.name.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
    final date = DateFormat('yyyyMMdd_HHmm').format(p.createdAt);
    return 'CureBay_${safeName}_$date.pdf';
  }

  static Future<Uint8List> _buildPdf(Patient p) async {
    final doc = pw.Document();

    final navy = PdfColor.fromInt(0xFF1A4789);
    final green = PdfColor.fromInt(0xFF3FB97F);
    final mint = PdfColor.fromInt(0xFFE8F5EC);
    final triageColor = _triagePdfColor(p.triage);
    final divider = PdfColor.fromInt(0xFFE5EAF2);
    final textDark = PdfColor.fromInt(0xFF1A2238);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _header(navy, green),
        footer: (ctx) => _footer(ctx, navy),
        build: (ctx) => [
          // Triage banner
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: triageColor,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${_triageEmoji(p.triage)} ${p.triage.toUpperCase()}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Most likely: ${_humanize(p.topDisease)}',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Patient demographics
          _sectionTitle('Patient Information', navy),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: divider),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: [
                _kv('Name', p.name, textDark, navy),
                _kv('Age / Sex', '${p.age} years • ${p.sex}', textDark, navy),
                _kv('Blood Group', p.bloodGroup, textDark, navy),
                _kv('Ward / Village', p.ward, textDark, navy),
                if (p.phone != null && p.phone!.isNotEmpty)
                  _kv('Phone', p.phone!, textDark, navy),
                _kv('Date', DateFormat('dd MMM yyyy, HH:mm').format(p.createdAt), textDark, navy),
              ],
            ),
          ),

          // Comorbidities
          if (p.hasDiabetes || p.hasHypertension || p.isPregnant || p.isSmoker) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Known Conditions', navy),
            pw.Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (p.hasDiabetes) _chip('Diabetes', mint, navy),
                if (p.hasHypertension) _chip('Hypertension', mint, navy),
                if (p.isPregnant) _chip('Pregnant', mint, navy),
                if (p.isSmoker) _chip('Smoker', mint, navy),
              ],
            ),
          ],

          // Vitals
          if (p.vitals.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Vitals Recorded', navy),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: divider),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: p.vitals.entries.map(
                  (e) => _kv(_vitalLabel(e.key), '${e.value} ${_vitalUnit(e.key)}',
                              textDark, navy),
                ).toList(),
              ),
            ),
          ],

          // Symptoms
          if (p.symptoms.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Reported Symptoms', navy),
            pw.Wrap(
              spacing: 5,
              runSpacing: 5,
              children: p.symptoms
                  .map((s) => _chip(_humanize(s), mint, navy))
                  .toList(),
            ),
          ],

          // Red flags (highlighted)
          if (p.redFlags.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Red Flag Findings', PdfColor.fromInt(0xFFE53935)),
            pw.Wrap(
              spacing: 5,
              runSpacing: 5,
              children: p.redFlags.map((s) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFFFEBEE),
                  border: pw.Border.all(color: PdfColor.fromInt(0xFFE53935)),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(_humanize(s),
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFFE53935),
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    )),
              )).toList(),
            ),
          ],

          // Top 3 diseases
          pw.SizedBox(height: 12),
          _sectionTitle('AI Triage Findings', navy),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: divider),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Column(
              children: p.top3Diseases.map((d) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 50,
                      padding: const pw.EdgeInsets.symmetric(vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: navy,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Center(
                        child: pw.Text('${(d.probability * 100).toStringAsFixed(0)}%',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            )),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(_humanize(d.disease),
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
                        )),
                  ],
                ),
              )).toList(),
            ),
          ),

          // Guidance
          if (p.doNow.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('DO NOW', green),
            ..._bulletList(p.doNow, green, textDark),
          ],

          if (p.doNot.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('DO NOT', PdfColor.fromInt(0xFFE53935)),
            ..._bulletList(p.doNot, PdfColor.fromInt(0xFFE53935), textDark),
          ],

          if (p.referTo.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Refer To', PdfColor.fromInt(0xFFFF9800)),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFFFF8E1),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(p.referTo,
                  style: pw.TextStyle(fontSize: 11, color: textDark)),
            ),
          ],

          if (p.watchFor.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Watch For (warning signs)', PdfColor.fromInt(0xFFFF9800)),
            ..._bulletList(p.watchFor, PdfColor.fromInt(0xFFFF9800), textDark),
          ],

          if (p.guidanceSource.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: mint,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text('Source: ${p.guidanceSource}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                    color: navy,
                  )),
            ),
          ],

          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFFF8E1),
              border: pw.Border.all(color: PdfColor.fromInt(0xFFFFE082)),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              'DISCLAIMER: This is AI-assisted triage decision-support for trained '
              'health workers. Not a medical diagnosis. Final treatment decisions '
              'must be made by a qualified physician.',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromInt(0xFF6D4C00),
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header(PdfColor navy, PdfColor green) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: navy, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CureBay',
                  style: pw.TextStyle(
                    color: navy,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.Text('for a healthier India',
                  style: pw.TextStyle(color: green, fontSize: 9)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Patient Triage Summary',
                  style: pw.TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.Text('CureBay Assist v1.0',
                  style: pw.TextStyle(
                      color: PdfColors.grey600, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx, PdfColor navy) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by CureBay Assist',
              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String text, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(text,
          style: pw.TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          )),
    );
  }

  static pw.Widget _kv(String k, String v, PdfColor textDark, PdfColor navy) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(k,
                style: pw.TextStyle(color: PdfColors.grey600, fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(v,
                style: pw.TextStyle(
                  color: textDark,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  static pw.Widget _chip(String text, PdfColor bg, PdfColor fg) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: fg, fontSize: 9, fontWeight: pw.FontWeight.bold)),
    );
  }

  static List<pw.Widget> _bulletList(
      List<String> items, PdfColor bullet, PdfColor textDark) {
    return items.map((item) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 5,
            height: 5,
            margin: const pw.EdgeInsets.only(top: 4, right: 6),
            decoration: pw.BoxDecoration(
              color: bullet,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.Expanded(
            child: pw.Text(item,
                style: pw.TextStyle(fontSize: 10, color: textDark)),
          ),
        ],
      ),
    )).toList();
  }

  static String _humanize(String d) {
    return d
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static PdfColor _triagePdfColor(String t) {
    switch (t) {
      case 'emergency':
        return PdfColor.fromInt(0xFFE53935);
      case 'urgent':
        return PdfColor.fromInt(0xFFFF9800);
      default:
        return PdfColor.fromInt(0xFF4CAF50);
    }
  }

  static String _triageEmoji(String t) {
    switch (t) {
      case 'emergency':
        return '!!';
      case 'urgent':
        return '!';
      default:
        return 'OK';
    }
  }

  static String _vitalLabel(String k) {
    return const {
      'temp_c': 'Temperature',
      'pulse_bpm': 'Pulse',
      'sbp_mmhg': 'Systolic BP',
      'dbp_mmhg': 'Diastolic BP',
      'spo2_pct': 'SpO2',
      'resp_rate': 'Resp Rate',
      'hb_gdl': 'Hemoglobin',
      'random_glucose': 'Random Glucose',
    }[k] ?? k;
  }

  static String _vitalUnit(String k) {
    return const {
      'temp_c': '°C',
      'pulse_bpm': 'bpm',
      'sbp_mmhg': 'mmHg',
      'dbp_mmhg': 'mmHg',
      'spo2_pct': '%',
      'resp_rate': '/min',
      'hb_gdl': 'g/dL',
      'random_glucose': 'mg/dL',
    }[k] ?? '';
  }
}
