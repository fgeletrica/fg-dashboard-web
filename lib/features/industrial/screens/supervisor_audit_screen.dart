import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meu_ajudante_fg/core/app_theme.dart';
import '../services/industrial_context.dart';
import '../services/industrial_supervisor_service.dart';

class SupervisorAuditScreen extends StatefulWidget {
  const SupervisorAuditScreen({super.key});

  @override
  State<SupervisorAuditScreen> createState() => _SupervisorAuditScreenState();
}

class _SupervisorAuditScreenState extends State<SupervisorAuditScreen> {
  IndustrialContext? ctx;
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  final fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final c = await IndustrialContextService.loadMyContext();
    if (!mounted) return;
    setState(() => ctx = c);
    await reload();
  }

  Future<void> reload() async {
    final c = ctx;
    if (c == null || !c.isSupervisor) {
      setState(() => loading = false);
      return;
    }

    setState(() => loading = true);
    try {
      final list = await IndustrialSupervisorService.listAudit(
          siteId: c.siteId, limit: 250);
      if (!mounted) return;
      setState(() {
        items = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro auditoria: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ctx;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('Supervisor • Auditoria (DQX)'),
        actions: [
          IconButton(onPressed: reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: (c == null)
          ? const Center(child: CircularProgressIndicator())
          : (!c.isSupervisor)
              ? Center(
                  child: Text(
                    'Sem permissão de supervisor/admin.',
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                )
              : loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final a = items[i];
                        final action = (a['action'] ?? '').toString();
                        final tableName = (a['table_name'] ?? '').toString();
                        final actor = (a['actor_name'] ?? '').toString();
                        final created = (a['created_at'] ?? '').toString();
                        final target = (a['target_id'] ?? '').toString();

                        String when = created;
                        try {
                          when = fmt.format(DateTime.parse(created).toLocal());
                        } catch (_) {}

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppTheme.border.withOpacity(.35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$action • $tableName',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              Text('Por: $actor',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.85))),
                              const SizedBox(height: 4),
                              Text('Quando: $when',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.7),
                                      fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('Target: ${target.isEmpty ? '—' : target}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.7),
                                      fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
