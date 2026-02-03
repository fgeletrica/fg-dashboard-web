import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_theme.dart';
import '../export/industrial_export_csv.dart';
import '../export/industrial_export_pdf.dart';
import '../services/industrial_catalog_l2.dart';
import '../services/industrial_context.dart';

class HistoryExportScreen extends StatefulWidget {
  const HistoryExportScreen({super.key});

  @override
  State<HistoryExportScreen> createState() => _HistoryExportScreenState();
}

class _HistoryExportScreenState extends State<HistoryExportScreen> {
  IndustrialContext? _ctx;
  bool _loadingCtx = true;

  DateTime _from =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _to =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String _shift = 'ALL';
  String _line = 'Linha 2';
  String _group = 'ROTULAGEM / CODIFICAÇÃO';
  String _machine = 'ALL';

  bool _busy = false;
  bool _searched = false;

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    setState(() => _loadingCtx = true);
    final c = await IndustrialContextService.loadMyContext();
    if (!mounted) return;

    // defaults seguros
    final groups = IndustrialCatalogL2.groupNames();
    final g0 =
        groups.contains(_group) ? _group : (groups.isEmpty ? '' : groups.first);
    final machines = _machinesForGroup(g0);
    final m0 = machines.contains(_machine) ? _machine : 'ALL';

    setState(() {
      _ctx = c;
      _group = g0;
      _machine = m0;
      _loadingCtx = false;
    });
  }

  int _startMs(DateTime d) =>
      DateTime(d.year, d.month, d.day, 0, 0, 0).millisecondsSinceEpoch;

  int _endMs(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).millisecondsSinceEpoch;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // normalização leve (não mexe em acentos pra não “quebrar” nomes oficiais)
  String _norm(String s) => s.trim().toLowerCase();

  bool _sameText(String a, String b) => _norm(a) == _norm(b);

  List<String> _machinesForGroup(String group) {
    final items = IndustrialCatalogL2.itemsForGroup(group);
    return ['ALL', ...items];
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _from = picked;
      if (_to.isBefore(_from)) _to = _from;
      _searched = false;
      _results = [];
    });
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (!mounted || picked == null) return;
    setState(() {
      _to = picked;
      if (_to.isBefore(_from)) _from = _to;
      _searched = false;
      _results = [];
    });
  }

  Future<List<Map<String, dynamic>>> _query() async {
    final sb = Supabase.instance.client;

    final siteId = _ctx!.siteId;
    final startMs = _startMs(_from);
    final endMs = _endMs(_to);

    // ✅ NÃO usa eq/filter no Postgrest (no seu build está quebrando).
    // Busca por período e filtra no Dart.
    dynamic q = sb
        .from('industrial_diagnostics_export')
        .select()
        .gte('created_at_ms', startMs)
        .lte('created_at_ms', endMs)
        .order('created_at_ms', ascending: false)
        .limit(5000);

    final res = await q;
    if (res is! List) return <Map<String, dynamic>>[];
    final list = res.map((e) => (e as Map).cast<String, dynamic>()).toList();

    String norm(String x) {
      return x.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    }

    bool sameText(String a, String b) => norm(a) == norm(b);

    bool containsText(String hay, String needle) {
      final h = norm(hay);
      final n = norm(needle);
      if (n.isEmpty) return true;
      return h.contains(n);
    }

    // ✅ filtro por site sempre
    var out =
        list.where((d) => (d['site_id'] ?? '').toString() == siteId).toList();

    if (_shift != 'ALL') {
      out = out
          .where((d) => sameText((d['shift'] ?? '').toString(), _shift))
          .toList();
    }
    if (_line != 'ALL') {
      out = out
          .where((d) => sameText((d['line'] ?? '').toString(), _line))
          .toList();
    }
    if (_group != 'ALL') {
      out = out
          .where((d) => sameText((d['machine_group'] ?? '').toString(), _group))
          .toList();
    }

    // ✅ máquina: aceita variações (ex: "Capsulador" bate com "Capsulador - KI31A71")
    if (_machine != 'ALL') {
      out = out
          .where((d) => containsText((d['machine'] ?? '').toString(), _machine))
          .toList();
    }

    return out;
  }

  Future<void> _search() async {
    if (_ctx == null) return;

    setState(() {
      _busy = true;
      _searched = true;
      _results = [];
    });

    try {
      final list = await _query();
      if (!mounted) return;
      setState(() {
        _results = list;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar: $e')),
      );
    }
  }

  Future<void> _exportPdf() async {
    if (_results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem resultados para gerar PDF.')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final period = '${_fmt(_from)} até ${_fmt(_to)}';
      final file = await IndustrialExportPdf.export(
        _results,
        headerCompany: 'Coca Cola Andina',
        headerPlant: 'DQX',
        periodLabel: period,
      );

      // ✅ feedback + abre o arquivo
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF gerado: ${file.path.split('/').last}')),
      );

      // tenta abrir no dispositivo
      try {
        await OpenFilex.open(file.path);
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
      // log no console também
      // ignore: avoid_print
      print('ERRO PDF: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportCsv() async {
    if (_results.isEmpty) return;
    final file = await IndustrialExportCsv.export(_results);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV gerado: ${file.path.split('/').last}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = _ctx;

    final groupOptions = IndustrialCatalogL2.groupNames();
    final machineOptions = _machinesForGroup(_group);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('Histórico • PDF/CSV'),
        actions: [
          IconButton(
            tooltip: 'Recarregar contexto',
            onPressed: _busy ? null : _boot,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loadingCtx
          ? const Center(child: CircularProgressIndicator())
          : (ctx == null)
              ? Center(
                  child: Text(
                    'Sem role no DQX.\nEntre e aguarde o auto-operator.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _rowDate('De', _fmt(_from), _pickFrom),
                          const SizedBox(height: 10),
                          _rowDate('Até', _fmt(_to), _pickTo),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _drop(
                            label: 'Turno',
                            value: _shift,
                            items: const ['ALL', 'Manhã', 'Tarde', 'Noite'],
                            onChanged: (v) => setState(() {
                              _shift = v;
                              _searched = false;
                              _results = [];
                            }),
                          ),
                          const SizedBox(height: 10),
                          _drop(
                            label: 'Linha',
                            value: _line,
                            items: const ['Linha 2', 'ALL'],
                            onChanged: (v) => setState(() {
                              _line = v;
                              _searched = false;
                              _results = [];
                            }),
                          ),
                          const SizedBox(height: 10),
                          _drop(
                            label: 'Máquinas (grupo)',
                            value: _group,
                            items: groupOptions,
                            onChanged: (v) => setState(() {
                              _group = v;
                              _machine = 'ALL';
                              _searched = false;
                              _results = [];
                            }),
                          ),
                          const SizedBox(height: 10),
                          _drop(
                            label: 'Máquina (item)',
                            value: machineOptions.contains(_machine)
                                ? _machine
                                : 'ALL',
                            items: machineOptions,
                            onChanged: (v) => setState(() {
                              _machine = v;
                              _searched = false;
                              _results = [];
                            }),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.gold,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _busy ? null : _search,
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '✅ O histórico só aparece depois do Buscar.',
                            style:
                                TextStyle(color: Colors.white.withOpacity(.65)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resultados: ${_results.length}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.gold,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed:
                                      (!_searched || _results.isEmpty || _busy)
                                          ? null
                                          : _exportPdf,
                                  child: const Text('Gerar PDF',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                        color: Colors.white.withOpacity(.25)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed:
                                      (!_searched || _results.isEmpty || _busy)
                                          ? null
                                          : _exportCsv,
                                  child: const Text('Gerar CSV',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_busy)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (!_searched)
                      _hint('Selecione os filtros e clique em Buscar.')
                    else if (_results.isEmpty)
                      _hint('Nenhum registro encontrado com esses filtros.')
                    else
                      ..._results.map(_itemCard),
                  ],
                ),
    );
  }

  Widget _hint(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withOpacity(.75)),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: child,
    );
  }

  Widget _rowDate(String label, String value, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w900))),
        Text(value, style: TextStyle(color: Colors.white.withOpacity(.85))),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withOpacity(.25)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Selecionar'),
        ),
      ],
    );
  }

  Widget _drop({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final v = items.contains(value) ? value : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: v,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.bg.withOpacity(.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (x) => onChanged((x ?? v).toString()),
        ),
      ],
    );
  }

  Widget _itemCard(Map<String, dynamic> d) {
    final when = (d['created_at'] ?? '').toString();
    final line = (d['line'] ?? '').toString();
    final group = (d['machine_group'] ?? '').toString();
    final machine = (d['machine'] ?? '').toString();
    final shift = (d['shift'] ?? '').toString();
    final user = (d['created_by_name'] ?? '').toString();
    final problem = (d['problem'] ?? '').toString();
    final action = (d['action_taken'] ?? '').toString();
    final hasRoot = d['has_root_cause'] == true;
    final root = (d['root_cause'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$line • $group • $machine',
              style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('$when • Turno: $shift',
              style:
                  TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12)),
          const SizedBox(height: 10),
          Text('Problema: ${problem.isEmpty ? '—' : problem}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Ação: ${action.isEmpty ? '—' : action}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
              'Causa raiz: ${hasRoot ? (root.isEmpty ? 'SIM (sem descrição)' : 'SIM — $root') : 'NÃO'}',
              style: TextStyle(color: Colors.white.withOpacity(.85))),
          const SizedBox(height: 10),
          Text('Usuário: ${user.isEmpty ? '—' : user}',
              style:
                  TextStyle(color: Colors.white.withOpacity(.7), fontSize: 12)),
        ],
      ),
    );
  }
}
