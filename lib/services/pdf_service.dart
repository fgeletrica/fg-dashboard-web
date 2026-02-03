import 'package:barcode/barcode.dart';
import 'package:meu_ajudante_fg/services/signature_store.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:meu_ajudante_fg/services/pro_guard.dart';

import '../models/budget_models.dart';

class PdfService {
  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static final _fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  static String _money(num v) => _fmt.format(v);

  static String _dt(DateTime d) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(d);
    } catch (_) {
      return d.toIso8601String();
    }
  }

  static pw.TextStyle get _h1 =>
      pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
  static pw.TextStyle get _h2 =>
      pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
  static pw.TextStyle get _muted =>
      pw.TextStyle(fontSize: 9, color: PdfColors.grey700);

  static pw.PageTheme _pageTheme() {
    return pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );
  }

  static pw.Widget _watermarkFree() {
    return pw.Positioned.fill(
      child: pw.Center(
        child: pw.Transform.rotate(
          angle: -0.5,
          child: pw.Opacity(
            opacity: 0.10,
            child: pw.Text(
              'FG ELÉTRICA • FREE',
              style: pw.TextStyle(
                fontSize: 56,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static pw.Widget _kv(String k, String v) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 110,
            child: pw.Text(k, style: _muted),
          ),
          pw.Expanded(child: pw.Text(v)),
        ],
      ),
    );
  }

  static pw.Widget _section(String title, List<pw.Widget> children) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: _h2),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _header({
    required String title,
    required String docNumber,
    required DateTime createdAt,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FG Elétrica',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('Orçamento Técnico', style: _muted),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(title, style: _h1),
              pw.SizedBox(height: 2),
              pw.Text('Nº: $docNumber', style: _muted),
              pw.Text('Data: ${_dt(createdAt)}', style: _muted),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ PRO-only: gera PDF do orçamento (layout profissional).
  static Future<File> generateBudgetPdf({
    required bool hasPro,
    Uint8List? signatureBytes,
    required BudgetDoc doc,
  }) async {
    final legalLog = await SignatureStore.loadLegalLog(doc.id);

    // se não veio assinatura, tenta pegar do log salvo
    if (signatureBytes == null || signatureBytes.isEmpty) {
      try {
        final b64 = (legalLog?['signatureB64'] ?? '').toString();
        if (b64.isNotEmpty) {
          signatureBytes = base64Decode(b64);
        }
      } catch (_) {}
    }

    // tenta preencher signatureBytes (1) do doc.signatureB64, (2) do legalLog (backup)
    if (signatureBytes == null || signatureBytes.isEmpty) {
      try {
        final b64 = (doc.signatureB64 ?? '').toString();
        if (b64.isNotEmpty) {
          signatureBytes = base64Decode(b64);
        }
      } catch (_) {}
    }
    if (signatureBytes == null || signatureBytes.isEmpty) {
      try {
        final b64 = (legalLog?['signatureB64'] ?? '').toString();
        if (b64.isNotEmpty) {
          signatureBytes = base64Decode(b64);
        }
      } catch (_) {}
    }
// FREE permitido: limite é controlado fora (PdfLimits).
    final pdf = pw.Document();

    final docNumber = doc.id.isNotEmpty
        ? doc.id
            .substring(0, doc.id.length > 8 ? 8 : doc.id.length)
            .toUpperCase()
        : DateTime.now().millisecondsSinceEpoch.toString();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Página ${context.pageNumber} / ${context.pagesCount}',
            style: _muted,
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.add(_header(
              title: 'ORÇAMENTO',
              docNumber: docNumber,
              createdAt: doc.createdAt));
          widgets.add(pw.Divider());

          widgets.add(
            _section('Dados do cliente', [
              _kv('Cliente', doc.clientName.isNotEmpty ? doc.clientName : '—'),
              _kv('Documento', docNumber),
            ]),
          );

          widgets.add(
            _section('Materiais', [
              doc.materials.isEmpty
                  ? pw.Text('—')
                  : pw.Table.fromTextArray(
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      headerDecoration:
                          const pw.BoxDecoration(color: PdfColors.grey300),
                      cellAlignment: pw.Alignment.centerLeft,
                      data: <List<String>>[
                        <String>['Item', 'Qtd', 'Un', 'Unit', 'Total'],
                        ...doc.materials.map((m) => <String>[
                              m.name,
                              m.qty.toStringAsFixed(2),
                              m.unit,
                              _money(m.unitPrice),
                              _money(m.total),
                            ]),
                      ],
                    ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text('TOTAL  ',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(_money(doc.total),
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
          );

          widgets.add(
            _section('Observações', [
              pw.Text(
                '• Valores sujeitos a alteração conforme visita técnica.\n'
                '• Este documento foi gerado pelo app FG Elétrica.\n'
                '• Dimensionamento e recomendações conforme boas práticas.',
                style: _muted,
              ),
            ]),
          );

          widgets.add(
            _section('Assinatura do cliente', [
              pw.SizedBox(height: 8),
              pw.Text('Assinatura (capturada no app)', style: _muted),
              pw.SizedBox(height: 8),
              if (signatureBytes != null && signatureBytes!.isNotEmpty) ...[
                pw.Container(
                  height: 110,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Image(pw.MemoryImage(signatureBytes!),
                      fit: pw.BoxFit.contain),
                ),
              ] else ...[
                pw.SizedBox(height: 26),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 6),
                pw.Text('Assinatura', style: _muted),
              ],
              pw.SizedBox(height: 16),
              pw.Container(height: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 6),
              pw.Text('Nome (legível) / CPF', style: _muted),
            ]),
          );

          if (legalLog != null) {
            final raw = jsonEncode(legalLog);
            final hash = _sha256(raw);

            widgets.add(
              _section('Validação jurídica', [
                _kv('Assinado via', 'Aplicativo FG Elétrica'),
                _kv('Data/Hora', legalLog['signedAt'] ?? '—'),
                _kv('Dispositivo', legalLog['device'] ?? '—'),
                _kv('Hash SHA-256', hash),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 90,
                      height: 90,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: Barcode.qrCode(),
                        data: hash,
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Text(
                        'Escaneie o QR para copiar/consultar o Hash SHA-256 deste documento.',
                        style: _muted,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'Este documento foi assinado eletronicamente. Qualquer alteração invalida este hash.',
                  style: _muted,
                ),
              ]),
            );
          }

          if (hasPro) return widgets;

          return [
            pw.Stack(
              children: [
                _watermarkFree(),
                pw.Column(children: widgets),
              ],
            ),
          ];
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/orcamento_${doc.id.isNotEmpty ? doc.id : docNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// ✅ PRO-only: relatório de Queda de Tensão em PDF (sem watermark)
  static Future<File> generateVoltageDropPdf({
    required Map<String, dynamic> data,
  }) async {
    final hasPro = await ProGuard.hasPro();

    // FREE permitido: limite é controlado fora (PdfLimits).
    final pdf = pw.Document();
    final title = (data['title'] ?? 'Relatório — Queda de Tensão').toString();

    List<pw.Widget> page() {
      final w = <pw.Widget>[
        _header(
          title: title.toUpperCase(),
          docNumber: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
        ),
        pw.Divider(),
        _section('Entradas', [
          _kv('Tensão', '${data['voltage']} V'),
          _kv('Fases', '${data['phases']}'),
          _kv('Distância (ida)', '${data['distanceM']} m'),
          _kv('Material', '${data['material']}'),
          _kv('FP', '${data['pf']}'),
          _kv('Queda máx', '${data['vdMaxPercent']} %'),
          _kv('Corrente', '${data['currentA']} A'),
          _kv('Potência', '${data['powerW']} W'),
        ]),
        _section('Resultado', [
          _kv('Seção sugerida', '${data['sectionMm2']} mm²'),
          _kv('Queda estimada', '${data['vdPercent']} %'),
        ]),
        pw.SizedBox(height: 10),
        pw.Text('Gerado pelo app FG Elétrica', style: _muted),
      ];
      return w;
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Página ${context.pageNumber} / ${context.pagesCount}',
            style: _muted,
          ),
        ),
        build: (context) {
          final content = page();
          if (hasPro) return content;
          return [
            pw.Stack(
              children: [
                _watermarkFree(),
                pw.Column(children: content),
              ],
            ),
          ];
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/relatorio_queda_tensao_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // =========================

  /// ✅ Relatório técnico genérico (PDF) — usado pela tela TechnicalReport
  static Future<File> generateTechnicalReportPdf({
    required Map<String, dynamic> data,
  }) async {
    // FREE permitido: limite é controlado fora (PdfLimits).
    final pdf = pw.Document();
    final title = (data['title'] ?? 'Relatório Técnico').toString();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Página ${context.pageNumber} / ${context.pagesCount}',
            style: _muted,
          ),
        ),
        build: (context) {
          final rows = <pw.Widget>[
            _header(
              title: title.toUpperCase(),
              docNumber: DateTime.now().millisecondsSinceEpoch.toString(),
              createdAt: DateTime.now(),
            ),
            pw.Divider(),
          ];

          // imprime campos principais
          for (final e in data.entries) {
            if (e.key == 'title') continue;
            rows.add(_kv(e.key, (e.value ?? '—').toString()));
          }

          return rows;
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/relatorio_tecnico_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Wrappers (compat)
  // =========================
  static Future<void> openPdf(dynamic fileOrPath) async {
    try {
      final path =
          (fileOrPath is File) ? fileOrPath.path : fileOrPath?.toString();
      if (path == null || path.isEmpty) return;

      if (Platform.isLinux) {
        await Process.run('xdg-open', [path]);
        return;
      }
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
        return;
      }
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', path]);
        return;
      }
    } catch (_) {}
  }

  static Future<void> sharePdf(dynamic fileOrPath,
      {String text = 'PDF'}) async {
    try {
      final path =
          (fileOrPath is File) ? fileOrPath.path : fileOrPath?.toString();
      if (path == null || path.isEmpty) return;

      await Share.shareXFiles([XFile(path)], text: text);
    } catch (_) {}
  }
}
