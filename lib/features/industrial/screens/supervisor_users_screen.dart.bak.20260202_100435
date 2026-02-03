import "package:flutter/material.dart";
import "package:meu_ajudante_fg/core/app_theme.dart";

import "../services/industrial_context.dart";
import "../services/industrial_supervisor_service.dart";
import "../services/industrial_role_helper.dart";

class SupervisorUsersScreen extends StatefulWidget {
  const SupervisorUsersScreen({super.key});

  @override
  State<SupervisorUsersScreen> createState() => _SupervisorUsersScreenState();
}

class _SupervisorUsersScreenState extends State<SupervisorUsersScreen> {
  IndustrialContext? ctx;
  bool loading = true;

  List<Map<String, dynamic>> users = [];
  String q = "";

  bool get _canEditRoles {
    final r = (ctx?.role ?? "").toLowerCase().trim();
    return r == "supervisor" || r == "admin";
  }

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
    if (ctx == null || !_canEditRoles) {
      setState(() => loading = false);
      return;
    }
    setState(() => loading = true);
    try {
      final list = await IndustrialSupervisorService.listUsers();
      if (!mounted) return;
      setState(() {
        users = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao listar usuários: $e")),
      );
    }
  }

  List<Map<String, dynamic>> get filtered {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return users;
    return users.where((u) {
      final name = (u["display_name"] ?? "").toString().toLowerCase();
      final email = (u["email"] ?? "").toString().toLowerCase();
      final role = (u["role"] ?? "").toString().toLowerCase();
      return name.contains(s) || email.contains(s) || role.contains(s);
    }).toList();
  }

  Future<void> _promote(Map<String, dynamic> u) async {
    final actorRole = (ctx?.role ?? "").toString().toLowerCase().trim();
    final actorName = (ctx?.displayName ?? "").toString();
    final isOwner = actorName.contains("\(6131450\)");

    final allowed = isOwner
        ? ["operator", "technician", "admin", "supervisor"]
        : IndustrialRoleHelper.editableRolesFor(actorRole);

    final id = (u["user_id"] ?? "").toString();
    final currentRole =
        (u["role"] ?? "operator").toString().toLowerCase().trim();
    final displayName = (u["display_name"] ?? "").toString();

    // Escolha inicial: se o atual não está permitido, começa em operator
    String selected = allowed.contains(currentRole) ? currentRole : "operator";

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppTheme.card,
          title: const Text("Alterar role",
              style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final r in allowed)
                _roleRadio(r, selected, (v) => selected = v),
              const SizedBox(height: 10),
              Text(
                "Usuário: ${displayName.isEmpty ? "—" : displayName}",
                style: TextStyle(color: Colors.white.withOpacity(.8)),
              ),
              const SizedBox(height: 6),
              Text(
                "Seu cargo: $actorRole",
                style: TextStyle(
                    color: Colors.white.withOpacity(.55), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Salvar",
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await IndustrialSupervisorService.setRoleChecked(
        targetUserId: id,
        newRole: selected,
        displayName: displayName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Role atualizado ✅")));
      await reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Falha ao atualizar role: $e")));
    }
  }

  Widget _roleRadio(String v, String group, ValueChanged<String> onChange) {
    return RadioListTile<String>(
      value: v,
      groupValue: group,
      onChanged: (x) => onChange((x ?? group).toString()),
      title: Text(v, style: const TextStyle(fontWeight: FontWeight.w800)),
      activeColor: AppTheme.gold,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ctx;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text("Gestão • Usuários (DQX)"),
        actions: [
          IconButton(onPressed: reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: (c == null)
          ? const Center(child: CircularProgressIndicator())
          : (!_canEditRoles)
              ? Center(
                  child: Text(
                    "Sem permissão (apenas Supervisor/Admin).",
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: AppTheme.border.withOpacity(.35)),
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => q = v),
                          decoration: InputDecoration(
                            hintText: "Buscar por nome, email ou role...",
                            filled: true,
                            fillColor: AppTheme.bg.withOpacity(.35),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
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
                                  final name =
                                      (u["display_name"] ?? "").toString();
                                  final email = (u["email"] ?? "").toString();
                                  final role = (u["role"] ?? "").toString();

                                  final isTargetSupervisor =
                                      role.toLowerCase().trim() == "supervisor";

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppTheme.card,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color:
                                              AppTheme.border.withOpacity(.35)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person,
                                            color: Colors.white),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.isEmpty ? "—" : name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                email.isEmpty ? "—" : email,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Role: $role",
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.85)),
                                              ),
                                              if (isTargetSupervisor) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Supervisor só altera no Supabase.",
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.55),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ]
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.gold,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                          onPressed: isTargetSupervisor
                                              ? null
                                              : () => _promote(u),
                                          child: const Text(
                                            "Editar",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900),
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
