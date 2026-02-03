import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/industrial_api.dart';
import '../services/industrial_context.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
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
      final list = await IndustrialApi.listAudit(siteId: c.siteId, limit: 300);
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
      ).showSnackBar(SnackBar(content: Text('Erro auditoria: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = ctx;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Auditoria'),
        actions: [
          IconButton(onPressed: reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: (c == null)
          ? const Center(child: CircularProgressIndicator())
          : (!c.isSupervisor)
          ? Center(
              child: Text(
                'Sem permissão.',
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
                  child: UiCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$action • $tableName',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Por: $actor',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quando: $when',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Target: ${target.isEmpty ? '—' : target}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
