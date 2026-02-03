import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../models/industrial_models.dart';
import '../services/industrial_store.dart';
import '../services/industrial_export.dart';

class ShiftSummaryScreen extends StatefulWidget {
  const ShiftSummaryScreen({super.key});

  @override
  State<ShiftSummaryScreen> createState() => _ShiftSummaryScreenState();
}

class _ShiftSummaryScreenState extends State<ShiftSummaryScreen> {
  String _shift = 'A';
  bool _loading = true;

  List<LineStopReport> _lineStops = [];
  List<ChecklistRun> _checklists = [];

  int _toInt(String s) {
    final t = s.trim().replaceAll(',', '.');
    final n = double.tryParse(t);
    if (n == null) return 0;
    return n.round();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ls = await IndustrialStore.listLineStops(limit: 500);
    final cl = await IndustrialStore.listChecklistRuns(limit: 500);
    if (!mounted) return;
    setState(() {
      _lineStops = ls;
      _checklists = cl;
      _loading = false;
    });
  }

  Future<void> _exportCsv() async {
    final shiftStops = _lineStops.where((e) => (e.shift == _shift)).toList();
    final shiftChecks = _checklists.where((e) => (e.shift == _shift)).toList();

    final f1 = await IndustrialExport.exportLineStopsCsv(shiftStops,
        filePrefix: 'linha_parou_turno_$_shift');
    final f2 = await IndustrialExport.exportChecklistsCsv(shiftChecks,
        filePrefix: 'checklists_turno_$_shift');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV gerado em: ${f1.path}\n+ ${f2.path}')),
    );

    // abre o primeiro automaticamente
    await IndustrialExport.openFile(f1);
  }

  Widget _metric(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.gold.withOpacity(.35)),
              ),
              child: Icon(icon, color: AppTheme.gold, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(title,
                      style: TextStyle(
                          color: Colors.white.withOpacity(.65),
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stopsShift = _lineStops.where((e) => e.shift == _shift).toList();
    final checksShift = _checklists.where((e) => e.shift == _shift).toList();

    final totalStops = stopsShift.length;
    final totalDowntime =
        stopsShift.fold<int>(0, (acc, r) => acc + _toInt(r.downtimeMin));
    final avgDowntime =
        totalStops == 0 ? 0 : (totalDowntime / totalStops).round();

    // Top máquinas
    final byMachine = <String, int>{};
    final byMachineDowntime = <String, int>{};
    for (final r in stopsShift) {
      final m = (r.machine.trim().isEmpty) ? 'Sem máquina' : r.machine.trim();
      byMachine[m] = (byMachine[m] ?? 0) + 1;
      byMachineDowntime[m] =
          (byMachineDowntime[m] ?? 0) + _toInt(r.downtimeMin);
    }
    final topMachines = byMachine.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top5 = topMachines.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Resumo do Turno'),
        actions: [
          IconButton(
            tooltip: 'Exportar CSV',
            onPressed: _loading ? null : _exportCsv,
            icon: const Icon(Icons.table_view),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border.withOpacity(.35)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _shift,
                          decoration: const InputDecoration(labelText: 'Turno'),
                          items: const [
                            DropdownMenuItem(
                                value: 'A', child: Text('Turno A')),
                            DropdownMenuItem(
                                value: 'B', child: Text('Turno B')),
                            DropdownMenuItem(
                                value: 'C', child: Text('Turno C')),
                            DropdownMenuItem(
                                value: 'D', child: Text('Turno D')),
                          ],
                          onChanged: (v) => setState(() => _shift = v ?? 'A'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _exportCsv,
                          icon: const Icon(Icons.download),
                          label: const Text('CSV'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _metric('Paradas', '$totalStops', Icons.report),
                    const SizedBox(width: 10),
                    _metric('Tempo total (min)', '$totalDowntime',
                        Icons.timer_outlined),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _metric(
                        'Média (min)', '$avgDowntime', Icons.insights_outlined),
                    const SizedBox(width: 10),
                    _metric(
                        'Checklists', '${checksShift.length}', Icons.checklist),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Top máquinas (por paradas)',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (top5.isEmpty)
                  Text('Sem dados nesse turno ainda.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(.7),
                          fontWeight: FontWeight.w700))
                else
                  ...top5.map((e) {
                    final name = e.key;
                    final count = e.value;
                    final down = byMachineDowntime[name] ?? 0;
                    final bar = min(1.0, count / max(1, top5.first.value));
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.35)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900)),
                              ),
                              Text('$count paradas',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.75),
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(value: bar),
                          ),
                          const SizedBox(height: 6),
                          Text('Tempo somado: $down min',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(.65),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 8),
                Text(
                  'Obs: o “tempo parado” depende do campo (min) nos relatórios.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.55),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
    );
  }
}
