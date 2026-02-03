import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/industrial_api.dart';
import '../services/industrial_context.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'audit_screen.dart';
import 'users_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  IndustrialContext? ctx;
  bool ctxLoading = true;

  final fmt = DateFormat('dd/MM/yyyy');
  DateTime start = DateTime.now().subtract(const Duration(days: 7));
  DateTime end = DateTime.now();

  String shift = 'ALL';
  String line = 'ALL';
  String group = 'ALL';
  String machine = 'ALL';

  bool loading = false;
  List<Map<String, dynamic>> items = [];

  int _startMs() => DateTime(
    start.year,
    start.month,
    start.day,
    0,
    0,
    0,
  ).millisecondsSinceEpoch;
  int _endMs() =>
      DateTime(end.year, end.month, end.day, 23, 59, 59).millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    setState(() => ctxLoading = true);
    final c = await IndustrialContextService.loadMyContext();
    if (!mounted) return;
    setState(() {
      ctx = c;
      ctxLoading = false;
    });
    await reload();
  }

  Future<void> reload() async {
    final c = ctx;
    if (c == null) return;
    if (!c.isSupervisor) {
      setState(() => items = []);
      return;
    }

    setState(() => loading = true);
    try {
      final list = await IndustrialApi.listDiagnostics(
        siteId: c.siteId,
        startMs: _startMs(),
        endMs: _endMs(),
        shift: shift,
        line: line,
        group: group,
        machine: machine,
      );
      if (!mounted) return;
      setState(() {
        items = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar: $e')));
    }
  }

  Future<void> pickStart() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDate: start,
    );
    if (d == null) return;
    setState(() => start = d);
    await reload();
  }

  Future<void> pickEnd() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDate: end,
    );
    if (d == null) return;
    setState(() => end = d);
    await reload();
  }

  void exportCsv() {
    final csv = IndustrialApi.buildCsv(items);
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    IndustrialApi.downloadCsv('DQX_$ts.csv', csv);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('CSV pronto (download) ✅')));
  }

  @override
  Widget build(BuildContext context) {
    final c = ctx;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('FG Industrial • Dashboard'),
        actions: [
          IconButton(onPressed: _boot, icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () async => Supabase.instance.client.auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ctxLoading
          ? const Center(child: CircularProgressIndicator())
          : (c == null)
          ? Center(
              child: Text(
                'Sem contexto (industrial_user_roles).',
                style: TextStyle(color: Colors.white.withOpacity(.8)),
              ),
            )
          : (!c.isSupervisor)
          ? Center(
              child: UiCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sem permissão',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esse dashboard é só para supervisor/admin.',
                      style: TextStyle(color: Colors.white.withOpacity(.75)),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                UiCard(
                  child: Row(
                    children: [
                      const Icon(Icons.factory, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Usuário: ${c.displayName}\nRole: ${c.role} • Site: DQX',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                UiCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _row('De', fmt.format(start), pickStart),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _row('Até', fmt.format(end), pickEnd),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _drop(
                              'Turno',
                              shift,
                              const ['ALL', 'Manhã', 'Tarde', 'Noite'],
                              (v) async {
                                setState(() => shift = v);
                                await reload();
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _drop(
                              'Linha',
                              line,
                              const [
                                'ALL',
                                'Linha 1',
                                'Linha 2',
                                'Linha 3',
                                'Linha 4',
                                'Linha 5',
                                'Linha 6',
                              ],
                              (v) async {
                                setState(() => line = v);
                                await reload();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _textFilter('Grupo (texto)', group, (
                              v,
                            ) async {
                              setState(() => group = v.isEmpty ? 'ALL' : v);
                              await reload();
                            }),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _textFilter('Máquina (texto)', machine, (
                              v,
                            ) async {
                              setState(() => machine = v.isEmpty ? 'ALL' : v);
                              await reload();
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: UiBtn(
                              text: 'Exportar CSV',
                              icon: Icons.download,
                              onTap: items.isEmpty ? null : exportCsv,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: UiBtn(
                              text: 'Usuários',
                              icon: Icons.group,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UsersScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: UiBtn(
                              text: 'Auditoria',
                              icon: Icons.history,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AuditScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Registros: ${items.length}',
                        style: TextStyle(color: Colors.white.withOpacity(.75)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ...items.map(_itemCard),
              ],
            ),
    );
  }

  Widget _row(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bg.withOpacity(.35),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const Icon(Icons.date_range, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _drop(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    final v = items.contains(value) ? value : items.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.75),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: v,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (x) => onChanged((x ?? v).toString()),
        ),
      ],
    );
  }

  Widget _textFilter(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    final ctrl = TextEditingController(text: value == 'ALL' ? '' : value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.75),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          onSubmitted: (v) => onChanged(v.trim()),
          decoration: const InputDecoration(
            hintText: 'enter para filtrar (vazio = ALL)',
          ),
        ),
      ],
    );
  }

  Widget _itemCard(Map<String, dynamic> d) {
    final when = (d['created_at'] ?? '').toString();
    final shift = (d['shift'] ?? '').toString();
    final line = (d['line'] ?? '').toString();
    final group = (d['machine_group'] ?? '').toString();
    final machine = (d['machine'] ?? '').toString();
    final user = (d['created_by_name'] ?? '').toString();
    final problem = (d['problem'] ?? '').toString();
    final action = (d['action_taken'] ?? '').toString();
    final hasRoot = d['has_root_cause'] == true;
    final root = (d['root_cause'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: UiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$line • $group • $machine',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '$when • Turno: $shift • Usuário: $user',
              style: TextStyle(
                color: Colors.white.withOpacity(.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Problema: $problem',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Ação: $action',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Causa raiz: ${hasRoot ? 'SIM — $root' : 'NÃO'}',
              style: TextStyle(color: Colors.white.withOpacity(.85)),
            ),
          ],
        ),
      ),
    );
  }
}
