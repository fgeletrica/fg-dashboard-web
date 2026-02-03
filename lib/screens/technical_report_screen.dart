import '../services/pro_guard.dart';
import 'package:meu_ajudante_fg/widgets/pro_lock_tile.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/report_models.dart';
import '../services/report_store.dart';
import '../services/pdf_service.dart';
import 'package:meu_ajudante_fg/services/pdf_limits.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';

class TechnicalReportScreen extends StatefulWidget {
  final TechnicalReportDoc? initial;

  const TechnicalReportScreen({super.key, this.initial});

  @override
  State<TechnicalReportScreen> createState() => _TechnicalReportScreenState();
}

class _TechnicalReportScreenState extends State<TechnicalReportScreen> {
  late TechnicalReportDoc doc;

  final _title = TextEditingController();
  final _client = TextEditingController();
  final _addr = TextEditingController();
  final _desc = TextEditingController();
  final _find = TextEditingController();
  final _reco = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    doc = widget.initial ??
        TechnicalReportDoc(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          createdAt: DateTime.now(),
        );

    _title.text = doc.title;
    _client.text = doc.clientName;
    _addr.text = doc.address;
    _desc.text = doc.description;
    _find.text = doc.findings;
    _reco.text = doc.recommendations;
  }

  @override
  void dispose() {
    _title.dispose();
    _client.dispose();
    _addr.dispose();
    _desc.dispose();
    _find.dispose();
    _reco.dispose();
    super.dispose();
  }

  Future<void> _saveLocal() async {
    doc.title = _title.text.trim();
    doc.clientName = _client.text.trim();
    doc.address = _addr.text.trim();
    doc.description = _desc.text.trim();
    doc.findings = _find.text.trim();
    doc.recommendations = _reco.text.trim();
    await ReportStore.upsert(doc);
  }

  Future<void> _generatePdf() async {
    setState(() => _saving = true);
    try {
      await _saveLocal();

      final hasPro = await ProGuard.hasPro();

      // FREE: reaproveita seu limite de PDFs (3/mês)
      if (!hasPro) {
        final left = await PdfLimits.freeRemainingThisMonth();
        if (left <= 0) {
          if (!mounted) return;
          Navigator.pushNamed(context, AppRoutes.paywall);
          return;
        }
      }

      final data = <String, dynamic>{
        'title': 'Relatório Técnico',
        'date': DateTime.now().toIso8601String(),
      };
      final File file = await PdfService.generateTechnicalReportPdf(data: data);

      if (!hasPro) {
        await PdfLimits.markFreePdfGenerated();
      }

      // abre automático no Linux / desktop
      await PdfService.openPdf(file);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF gerado: ${file.path}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vdOk = (doc.vdPercent != null || doc.vdVolts != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laudo técnico'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _generatePdf,
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label:
                const Text('Gerar PDF', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 12),
          TextField(
              controller: _client,
              decoration: const InputDecoration(labelText: 'Cliente')),
          const SizedBox(height: 12),
          TextField(
              controller: _addr,
              decoration: const InputDecoration(labelText: 'Endereço')),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            minLines: 2,
            maxLines: 6,
            decoration:
                const InputDecoration(labelText: 'Descrição do chamado'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _find,
            minLines: 2,
            maxLines: 10,
            decoration:
                const InputDecoration(labelText: 'Constatações / diagnóstico'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reco,
            minLines: 2,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Recomendações'),
          ),
          const SizedBox(height: 16),
          if (vdOk) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text('Dados (queda de tensão)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _kv(
                'Tensão',
                doc.voltageV == null
                    ? '—'
                    : '${doc.voltageV!.toStringAsFixed(0)} V'),
            _kv(
                'Fases',
                doc.phases == null
                    ? '—'
                    : (doc.phases == 3 ? 'Trifásico' : 'Monofásico')),
            _kv(
                'Potência',
                doc.powerW == null
                    ? '—'
                    : '${doc.powerW!.toStringAsFixed(0)} W'),
            _kv(
                'Corrente',
                doc.currentA == null
                    ? '—'
                    : '${doc.currentA!.toStringAsFixed(2)} A'),
            _kv(
                'Comprimento',
                doc.lengthM == null
                    ? '—'
                    : '${doc.lengthM!.toStringAsFixed(1)} m'),
            _kv(
                'Seção',
                doc.sectionMm2 == null
                    ? '—'
                    : '${doc.sectionMm2!.toStringAsFixed(1)} mm²'),
            _kv(
                'Queda (%)',
                doc.vdPercent == null
                    ? '—'
                    : '${doc.vdPercent!.toStringAsFixed(2)} %'),
            _kv(
                'Queda (V)',
                doc.vdVolts == null
                    ? '—'
                    : '${doc.vdVolts!.toStringAsFixed(2)} V'),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saving ? null : _generatePdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(_saving ? 'Gerando...' : 'Gerar PDF'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await _saveLocal();
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Salvo.')));
            },
            icon: const Icon(Icons.save),
            label: const Text('Salvar rascunho'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
