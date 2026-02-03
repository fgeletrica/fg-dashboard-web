import '../services/pro_guard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/pdf_service.dart';
import 'package:meu_ajudante_fg/services/pdf_limits.dart';
import '../services/voltage_drop_store.dart';

class VoltageDropScreen extends StatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  State<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends State<VoltageDropScreen> {
  final _fmt = NumberFormat('#,##0.##', 'pt_BR');
  final _fmtDate = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  // inputs
  bool _usePower = true; // potência ou corrente
  final _powerCtrl = TextEditingController(text: '5500');
  final _currentCtrl = TextEditingController(text: '');
  final _distCtrl = TextEditingController(text: '20');
  final _pfCtrl = TextEditingController(text: '1.0');
  int _voltage = 220;
  int _phases = 1;
  String _material = 'Cobre';
  double _vdMax = 4.0;

  // result
  VoltageDropEntry? _last;
  bool _loading = false;

  // history
  List<VoltageDropEntry> _history = [];
  bool _loadingHistory = true;

  static const _sections = <double>[
    1.5,
    2.5,
    4,
    6,
    10,
    16,
    25,
    35,
    50,
    70,
    95,
    120
  ];

  double _parseDouble(String s) {
    final cleaned = s.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double _calcCurrentA({
    required double powerW,
    required int voltage,
    required int phases,
    required double pf,
  }) {
    if (voltage <= 0) return 0;
    if (phases == 3) {
      // I = P / (sqrt(3)*V*pf)
      return powerW / (1.7320508075688772 * voltage * (pf == 0 ? 1 : pf));
    }
    // monofásico: I = P / (V*pf)
    return powerW / (voltage * (pf == 0 ? 1 : pf));
  }

  double _suggestSectionMm2({
    required double currentA,
    required double distanceM_oneWay,
    required int voltage,
    required int phases,
    required String material,
    required double vdMaxPercent,
  }) {
    // Fórmula prática (resistiva):
    // S = (K * L * I) / ΔV
    // monofásico: K=2; trifásico: K=sqrt(3)
    // condutividade (k): cobre ~56, alumínio ~35
    final kCond = (material == 'Alumínio') ? 35.0 : 56.0;
    final k = (phases == 3) ? 1.7320508075688772 : 2.0;

    final dv = (vdMaxPercent / 100.0) * voltage;
    if (dv <= 0) return _sections.first;

    final raw = (k * distanceM_oneWay * currentA) / (kCond * dv); // mm² (aprox)
    // arredonda para seção comercial
    for (final s in _sections) {
      if (s >= raw) return s;
    }
    return _sections.last;
  }

  double _estimateDropPercent({
    required double currentA,
    required double distanceM_oneWay,
    required int voltage,
    required int phases,
    required String material,
    required double sectionMm2,
  }) {
    final kCond = (material == 'Alumínio') ? 35.0 : 56.0;
    final k = (phases == 3) ? 1.7320508075688772 : 2.0;

    // ΔV = (k*L*I)/(kCond*S)
    final dv = (k * distanceM_oneWay * currentA) / (kCond * sectionMm2);
    if (voltage <= 0) return 0;
    return (dv / voltage) * 100.0;
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    _history = await VoltageDropStore.load();
    setState(() => _loadingHistory = false);
  }

  Future<void> _compute() async {
    setState(() => _loading = true);

    final dist = _parseDouble(_distCtrl.text);
    final pf = _parseDouble(_pfCtrl.text);
    final powerW = _usePower ? _parseDouble(_powerCtrl.text) : 0.0;
    final currentA = !_usePower
        ? _parseDouble(_currentCtrl.text)
        : _calcCurrentA(
            powerW: powerW, voltage: _voltage, phases: _phases, pf: pf);

    final section = _suggestSectionMm2(
      currentA: currentA,
      distanceM_oneWay: dist,
      voltage: _voltage,
      phases: _phases,
      material: _material,
      vdMaxPercent: _vdMax,
    );

    final vd = _estimateDropPercent(
      currentA: currentA,
      distanceM_oneWay: dist,
      voltage: _voltage,
      phases: _phases,
      material: _material,
      sectionMm2: section,
    );

    final entry = VoltageDropEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      voltage: _voltage,
      phases: _phases,
      distanceM: dist,
      powerW: powerW,
      currentA: currentA,
      pf: pf,
      material: _material,
      vdMaxPercent: _vdMax,
      sectionMm2: section,
      vdPercent: vd,
    );

    await VoltageDropStore.add(entry);
    _last = entry;

    await _loadHistory();
    setState(() => _loading = false);
  }

  Future<void> _shareOrOpenPdf(VoltageDropEntry e,
      {required bool share}) async {
    final hasPro = await ProGuard.hasPro();

    // opcional: você pode decidir que esse PDF também conta no limite do FREE.
    // aqui eu vou usar o MESMO limite do PDF (3/mês):
    if (!hasPro) {
      final remaining = await PdfLimits.freeRemainingThisMonth();
      final can = remaining > 0;
      if (!can) {
        if (!mounted) return;
        Navigator.pushNamed(context, '/paywall');
        return;
      }
    }

    final data = {
      'title': 'Relatório — Queda de Tensão',
      'date':
          _fmtDate.format(DateTime.fromMillisecondsSinceEpoch(e.createdAtMs)),
      'voltage': e.voltage,
      'phases': e.phases,
      'distanceM': _fmt.format(e.distanceM),
      'material': e.material,
      'pf': _fmt.format(e.pf),
      'vdMaxPercent': _fmt.format(e.vdMaxPercent),
      'currentA': _fmt.format(e.currentA),
      'powerW': _fmt.format(e.powerW),
      'sectionMm2': _fmt.format(e.sectionMm2),
      'vdPercent': _fmt.format(e.vdPercent),
    };

    final file = await PdfService.generateVoltageDropPdf(data: data);

    if (!hasPro) {
      await PdfLimits.markFreePdfGenerated();
    }

    if (share) {
      await PdfService.sharePdf(file);
    } else {
      await PdfService.openPdf(file);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _powerCtrl.dispose();
    _currentCtrl.dispose();
    _distCtrl.dispose();
    _pfCtrl.dispose();
    super.dispose();
  }

  Widget _resultCard(VoltageDropEntry e) {
    final ok = e.vdPercent <= e.vdMaxPercent;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ok ? 'OK ✅' : 'ALERTA ⚠️',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ok ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text('Seção sugerida: ${_fmt.format(e.sectionMm2)} mm²'),
            Text(
                'Queda estimada: ${_fmt.format(e.vdPercent)} % (máx ${_fmt.format(e.vdMaxPercent)} %)'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _shareOrOpenPdf(e, share: false),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Abrir PDF'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _shareOrOpenPdf(e, share: true),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _calcTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                              value: true, label: Text('Potência (W)')),
                          ButtonSegment(
                              value: false, label: Text('Corrente (A)')),
                        ],
                        selected: {_usePower},
                        onSelectionChanged: (v) =>
                            setState(() => _usePower = v.first),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_usePower)
                  TextField(
                    controller: _powerCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potência (W)',
                      prefixIcon: Icon(Icons.bolt),
                      border: OutlineInputBorder(),
                    ),
                  )
                else
                  TextField(
                    controller: _currentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Corrente (A)',
                      prefixIcon: Icon(Icons.flash_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 10),
                TextField(
                  controller: _distCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Distância (ida) em metros',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _voltage,
                        items: const [
                          DropdownMenuItem(value: 127, child: Text('127 V')),
                          DropdownMenuItem(value: 220, child: Text('220 V')),
                          DropdownMenuItem(value: 380, child: Text('380 V')),
                        ],
                        onChanged: (v) => setState(() => _voltage = v ?? 220),
                        decoration: const InputDecoration(
                          labelText: 'Tensão',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _phases,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Monofásico')),
                          DropdownMenuItem(value: 3, child: Text('Trifásico')),
                        ],
                        onChanged: (v) => setState(() => _phases = v ?? 1),
                        decoration: const InputDecoration(
                          labelText: 'Fases',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _material,
                        items: const [
                          DropdownMenuItem(
                              value: 'Cobre', child: Text('Cobre')),
                          DropdownMenuItem(
                              value: 'Alumínio', child: Text('Alumínio')),
                        ],
                        onChanged: (v) =>
                            setState(() => _material = v ?? 'Cobre'),
                        decoration: const InputDecoration(
                          labelText: 'Material',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _pfCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'FP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Queda máx (%)'),
                    Expanded(
                      child: Slider(
                        value: _vdMax,
                        min: 1,
                        max: 10,
                        divisions: 18,
                        label: _vdMax.toStringAsFixed(1),
                        onChanged: (v) => setState(() => _vdMax = v),
                      ),
                    ),
                    SizedBox(width: 56, child: Text(_vdMax.toStringAsFixed(1))),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _compute,
                  icon: const Icon(Icons.calculate),
                  label: Text(_loading ? 'Calculando...' : 'Calcular'),
                ),
              ],
            ),
          ),
        ),
        if (_last != null) _resultCard(_last!),
        const SizedBox(height: 12),
        const Text(
          'Dica rápida',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          '• Distância é “ida”.\n'
          '• Em monofásico a conta considera ida e volta automaticamente.\n'
          '• Resultado é uma aproximação prática (pra ser rápido no campo).',
        ),
      ],
    );
  }

  Widget _historyTab() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_history.isEmpty) {
      return const Center(child: Text('Sem histórico ainda.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final e = _history[i];
        final dt =
            _fmtDate.format(DateTime.fromMillisecondsSinceEpoch(e.createdAtMs));
        final ok = e.vdPercent <= e.vdMaxPercent;

        return Card(
          child: ListTile(
            title: Text(
                '$dt • ${e.voltage}V • ${e.phases}F • ${_fmt.format(e.distanceM)}m'),
            subtitle: Text(
              'Seção ${_fmt.format(e.sectionMm2)} mm² • Queda ${_fmt.format(e.vdPercent)}% (máx ${_fmt.format(e.vdMaxPercent)}%)',
            ),
            leading: Icon(ok ? Icons.check_circle : Icons.warning,
                color: ok ? Colors.green : Colors.orange),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'open') await _shareOrOpenPdf(e, share: false);
                if (v == 'share') await _shareOrOpenPdf(e, share: true);
                if (v == 'del') {
                  await VoltageDropStore.remove(e.id);
                  await _loadHistory();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'open', child: Text('Abrir PDF')),
                PopupMenuItem(value: 'share', child: Text('Compartilhar')),
                PopupMenuDivider(),
                PopupMenuItem(value: 'del', child: Text('Remover')),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Queda de tensão (prática)'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Calcular', icon: Icon(Icons.calculate)),
              Tab(text: 'Histórico', icon: Icon(Icons.history)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Limpar histórico',
              onPressed: () async {
                await VoltageDropStore.clear();
                await _loadHistory();
              },
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _calcTab(),
            _historyTab(),
          ],
        ),
      ),
    );
  }
}
