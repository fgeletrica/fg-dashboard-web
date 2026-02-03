import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class IndustrialExportPdf {
  // Evita caracteres que viram "quadradinho" (•, —, etc)
  static String _safe(String s) {
    final t = s.trim();
    if (t.isEmpty) return '-';
    return t
        .replaceAll('•', '-')
        .replaceAll('—', '-')
        .replaceAll('\u2014', '-') // em dash
        .replaceAll('\u2013', '-') // en dash
        .replaceAll('\u00A0', ' '); // nbsp
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _fmtWhen(dynamic createdAt, dynamic createdAtMs) {
    try {
      if (createdAtMs != null) {
        final ms = int.tryParse(createdAtMs.toString());
        if (ms != null && ms > 0) {
          final dt = DateTime.fromMillisecondsSinceEpoch(ms);
          return '${_two(dt.day)}/${_two(dt.month)}/${dt.year} ${_two(dt.hour)}:${_two(dt.minute)}';
        }
      }
    } catch (_) {}

    try {
      final dt = DateTime.tryParse((createdAt ?? '').toString());
      if (dt != null) {
        return '${_two(dt.day)}/${_two(dt.month)}/${dt.year} ${_two(dt.hour)}:${_two(dt.minute)}';
      }
    } catch (_) {}

    return _safe((createdAt ?? '').toString());
  }

  static Future<Uint8List?> _tryLoadLogoBytes() async {
    // arquivo que você falou: assets/images/coca cola andina.jpeg
    try {
      final bd = await rootBundle.load('assets/images/coca cola andina.jpeg');
      if (bd.lengthInBytes > 0) return bd.buffer.asUint8List();
    } catch (_) {}
    return null;
  }

  static Future<File> export(
    List<Map<String, dynamic>> list, {
    String headerCompany = 'Coca Cola Andina',
    String headerPlant = 'DQX',
    String periodLabel = '',
  }) async {
    final pdf = pw.Document();

    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    final logoBytes = await _tryLoadLogoBytes();
    pw.ImageProvider? logo;
    if (logoBytes != null) {
      logo = pw.MemoryImage(logoBytes);
    }

    pw.Widget header() {
      return pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFE10600),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null)
              pw.Container(
                width: 36,
                height: 36,
                margin: const pw.EdgeInsets.only(right: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                padding: const pw.EdgeInsets.all(4),
                child: pw.Image(logo!, fit: pw.BoxFit.contain),
              ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    _safe(headerCompany),
                    style: pw.TextStyle(
                      font: fontBold,
                      color: PdfColors.white,
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _safe(headerPlant),
                    style: pw.TextStyle(
                      font: font,
                      color: PdfColors.white,
                      fontSize: 11,
                    ),
                  ),
                  if (periodLabel.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text(
                      _safe(periodLabel),
                      style: pw.TextStyle(
                        font: font,
                        color: PdfColors.white,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Text(
                'Relatorio - Diagnosticos',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 9,
                  color: PdfColor.fromInt(0xFFE10600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget infoRow(String label, String value) {
      return pw.Row(
        children: [
          pw.Container(
            width: 62,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                  font: fontBold, fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _safe(value),
              style: pw.TextStyle(
                  font: font, fontSize: 9, color: PdfColors.grey800),
            ),
          ),
        ],
      );
    }

    pw.Widget card(Map<String, dynamic> d) {
      final createdAt = d['created_at'];
      final createdAtMs = d['created_at_ms'];
      final when = _fmtWhen(createdAt, createdAtMs);

      final line = _safe((d['line'] ?? '').toString());
      final group = _safe((d['machine_group'] ?? '').toString());
      final machine = _safe((d['machine'] ?? '').toString());
      final shift = _safe((d['shift'] ?? '').toString());
      final user = _safe((d['created_by_name'] ?? '').toString());

      final problem = _safe((d['problem'] ?? '').toString());
      final action = _safe((d['action_taken'] ?? '').toString());

      final hasRoot = d['has_root_cause'] == true;
      final root = _safe((d['root_cause'] ?? '').toString());

      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 10),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // topo do card
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '$line | $group | $machine',
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 11, color: PdfColors.grey900),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Text(
                  when,
                  style: pw.TextStyle(
                      font: font, fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            infoRow('Turno', shift),
            infoRow('Usuario', user),

            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),

            pw.Text('Problema',
                style: pw.TextStyle(font: fontBold, fontSize: 10)),
            pw.Text(problem, style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 6),

            pw.Text('Acao tomada',
                style: pw.TextStyle(font: fontBold, fontSize: 10)),
            pw.Text(action, style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 6),

            pw.Text('Causa raiz',
                style: pw.TextStyle(font: fontBold, fontSize: 10)),
            pw.Text(
              hasRoot
                  ? (root == '-' ? 'SIM (sem descricao)' : 'SIM - $root')
                  : 'NAO',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(22),
        build: (_) => [
          header(),
          pw.SizedBox(height: 10),
          pw.Text(
            'Total de registros: ${list.length}',
            style:
                pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
          ),
          ...list.map(card),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Pagina ${context.pageNumber} / ${context.pagesCount}',
            style:
                pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey700),
          ),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/DQX_diagnosticos_$ts.pdf');
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }
}
