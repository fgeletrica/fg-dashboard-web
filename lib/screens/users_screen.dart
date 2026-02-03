import 'package:flutter/material.dart';
import '../services/industrial_api.dart';
import '../services/industrial_context.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  IndustrialContext? ctx;
  bool loading = true;
  List<Map<String, dynamic>> users = [];
  String q = '';

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
      final list = await IndustrialApi.listUsers();
      if (!mounted) return;
      setState(() {
        users = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro users: $e')));
    }
  }

  List<Map<String, dynamic>> get filtered {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return users;
    return users.where((u) {
      final name = (u['display_name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final role = (u['role'] ?? '').toString().toLowerCase();
      return name.contains(s) || email.contains(s) || role.contains(s);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = ctx;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Usuários do site'),
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  UiCard(
                    child: TextField(
                      onChanged: (v) => setState(() => q = v),
                      decoration: const InputDecoration(
                        hintText: 'Buscar (nome/email/role)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final u = filtered[i];
                              return UiCard(
                                child: Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (u['display_name'] ?? '—')
                                                .toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (u['email'] ?? '—').toString(),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                .7,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Role: ${(u['role'] ?? '—').toString()}',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                .85,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
