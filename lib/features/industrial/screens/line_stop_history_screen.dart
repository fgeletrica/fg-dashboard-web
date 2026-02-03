import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_theme.dart';
import '../models/industrial_models.dart';
import '../services/industrial_store.dart';

class LineStopHistoryScreen extends StatefulWidget {
  const LineStopHistoryScreen({super.key});

  @override
  State<LineStopHistoryScreen> createState() => _LineStopHistoryScreenState();
}

class _LineStopHistoryScreenState extends State<LineStopHistoryScreen> {
  DateTimeRange? _range;
  String _shift = 'ALL';
  final _q = TextEditingController();

  Future<DateTimeRange?> _pickRange() async {
    final now = DateTime.now();
    final initial = _range ??
        DateTimeRange(
          start: DateTime(now.year, now.month, now.day, 0, 0),
          end: now,
        );

    return showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );
  }

  String _rangeLabel() {
    if (_range == null) return 'Hoje';
    final s = _range!.start.toString().substring(0, 10);
    final e = _range!.end.toString().substring(0, 10);
    return '$s → $e';
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Histórico • Linha Parou'),
        actions: [
          IconButton(
            tooltip: 'Exportar CSV',
            onPressed: () async {
              final all = await IndustrialStore.listLineStops(limit: 1000);

              final now = DateTime.now();
              final defRange = DateTimeRange(
                start: DateTime(now.year, now.month, now.day, 0, 0),
                end: now,
              );
              final rr = _range ?? defRange;

              final filtered = IndustrialStore.filterLineStops(
                all,
                start: rr.start,
                end: rr.end,
                shift: _shift,
                query: _q.text,
              );

              final file = await IndustrialStore.exportLineStopsCsv(
                filtered,
                filenamePrefix:
                    'linha_parou_turno_${_shift == 'ALL' ? 'ALL' : _shift}',
              );

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('CSV salvo em: ${file.path}')));

              try {
                await Share.shareXFiles([XFile(file.path)],
                    text: 'Relatório Linha Parou (CSV)');
              } catch (_) {}
            },
            icon: const Icon(Icons.file_download),
          ),
        ],
      ),
      body: FutureBuilder<List<LineStopReport>>(
        future: IndustrialStore.listLineStops(limit: 1000),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final all = snap.data ?? const <LineStopReport>[];

          final now = DateTime.now();
          final defRange = DateTimeRange(
            start: DateTime(now.year, now.month, now.day, 0, 0),
            end: now,
          );
          final rr = _range ?? defRange;

          final filtered = IndustrialStore.filterLineStops(
            all,
            start: rr.start,
            end: rr.end,
            shift: _shift,
            query: _q.text,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _filters(),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Text('Sem registros nesse filtro.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        fontWeight: FontWeight.w700)),
              ...filtered.take(80).map((r) => _item(r)),
            ],
          );
        },
      ),
    );
  }

  Widget _filters() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final r = await _pickRange();
                    if (!mounted) return;
                    setState(() => _range = r);
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(_rangeLabel()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _shift,
                  decoration: const InputDecoration(labelText: 'Turno'),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('Todos')),
                    DropdownMenuItem(value: 'A', child: Text('Turno A')),
                    DropdownMenuItem(value: 'B', child: Text('Turno B')),
                    DropdownMenuItem(value: 'C', child: Text('Turno C')),
                    DropdownMenuItem(value: 'D', child: Text('Turno D')),
                  ],
                  onChanged: (v) => setState(() => _shift = v ?? 'ALL'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _q,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar (máquina, área, sintoma, causa...)',
              filled: true,
              fillColor: AppTheme.bg,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _range = null;
                _shift = 'ALL';
                _q.clear();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(LineStopReport r) {
    final dt =
        DateTime.fromMillisecondsSinceEpoch(r.ts).toString().substring(0, 16);
    final min = IndustrialStore.parseDowntimeMin(r);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                '${r.machine.isEmpty ? 'Sem máquina' : r.machine} • Turno ${r.shift.isEmpty ? '-' : r.shift}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
            Text('$min min',
                style: TextStyle(
                    color: AppTheme.gold, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 6),
          Text('Área: ${r.area.isEmpty ? '—' : r.area}',
              style: TextStyle(
                  color: Colors.white.withOpacity(.75),
                  fontWeight: FontWeight.w700)),
          Text('Sintoma: ${r.symptom.isEmpty ? '—' : r.symptom}',
              style: TextStyle(
                  color: Colors.white.withOpacity(.75),
                  fontWeight: FontWeight.w700)),
          if (r.probableCause.trim().isNotEmpty)
            Text('Causa: ${r.probableCause}',
                style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(dt,
                  style: TextStyle(
                      color: Colors.white.withOpacity(.55),
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  final txt = [
                    'LINHA PAROU 🚨',
                    'Data: $dt',
                    'Máquina: ${r.machine}',
                    'Área: ${r.area}',
                    'Turno: ${r.shift}',
                    'Sintoma: ${r.symptom}',
                    'Descrição: ${r.description}',
                    'Testes: ${r.testsDone.join(' | ')}',
                    'Causa: ${r.probableCause}',
                    'Ação: ${r.actionTaken}',
                    'Tempo: ${r.downtimeMin} min',
                    'Prevenção: ${r.prevention}',
                  ].join('\n');

                  await Clipboard.setData(ClipboardData(text: txt));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copiado 📋')));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
