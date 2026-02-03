import "package:flutter/material.dart";
import "package:supabase_flutter/supabase_flutter.dart";

import "package:meu_ajudante_fg/core/app_theme.dart";

import "../services/industrial_context.dart";
import "../services/industrial_kpi_controller.dart";

import "industrial_diagnostic_form_screen.dart";
import "industrial_reports_screen.dart";
import "supervisor_users_screen.dart";
import "supervisor_audit_screen.dart";

class IndustrialHomeScreen extends StatefulWidget {
  const IndustrialHomeScreen({super.key});

  @override
  State<IndustrialHomeScreen> createState() => _IndustrialHomeScreenState();
}

class _IndustrialHomeScreenState extends State<IndustrialHomeScreen> {
  IndustrialContext? _ctx;
  bool _loading = true;

  final IndustrialKpiController _kpiCtrl = IndustrialKpiController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _kpiCtrl.dispose();
    super.dispose();
  }

  bool get _canManageUsers {
    final r = (_ctx?.role ?? "").toLowerCase().trim();
    return r == "supervisor" || r == "admin";
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final c = await IndustrialContextService.loadMyContext();
    if (!mounted) return;

    setState(() {
      _ctx = c;
      _loading = false;
    });

    if (c != null) {
      // KPIs: carrega sempre que atualizar contexto
      // ignore: unawaited_futures
      _kpiCtrl.load(c);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text("Industrial • DQX"),
        actions: [
          IconButton(
            tooltip: "Recarregar",
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: "Sair",
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_ctx == null)
              ? _noRoleCard()
              : RefreshIndicator(
                  onRefresh: () async => _load(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _heroHeader(_ctx!),
                      const SizedBox(height: 14),

                      // KPIs reais (Supabase)
                      _kpisBlock(),
                      const SizedBox(height: 14),

                      _sectionTitle("Ações"),
                      const SizedBox(height: 10),

                      _bigAction(
                        title: "Novo Diagnóstico",
                        subtitle:
                            "Registrar problema + ação tomada + causa raiz.",
                        icon: Icons.playlist_add_check,
                        primary: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const IndustrialDiagnosticFormScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _bigAction(
                        title: "Histórico + Export",
                        subtitle:
                            "Filtrar por Linha/Grupo/Máquina e gerar PDF/CSV.",
                        icon: Icons.picture_as_pdf,
                        primary: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const IndustrialReportsScreen(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      _sectionTitle("Atalhos"),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _miniTile(
                              title: "Recarregar role",
                              subtitle: "Atualiza permissões",
                              icon: Icons.verified_user,
                              onTap: _load,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _miniTile(
                              title: "Sair",
                              subtitle: "Trocar usuário",
                              icon: Icons.logout,
                              onTap: _logout,
                            ),
                          ),
                        ],
                      ),

                      if (_canManageUsers) ...[
                        const SizedBox(height: 18),
                        _sectionTitle("Gestão"),
                        const SizedBox(height: 10),
                        _bigAction(
                          title: "Usuários do site",
                          subtitle:
                              "Permissões por hierarquia (Supervisor/Admin).",
                          icon: Icons.group,
                          primary: false,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SupervisorUsersScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _bigAction(
                          title: "Auditoria",
                          subtitle: "Ver ações e alterações (audit log).",
                          icon: Icons.history,
                          primary: false,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SupervisorAuditScreen()),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  // ================= UI PARTS =================

  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: child,
    );
  }

  Widget _heroHeader(IndustrialContext c) {
    final name =
        c.displayName.trim().isEmpty ? "Operador" : c.displayName.trim();
    final role = (c.role).toString();
    return _card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.gold.withOpacity(.35)),
            ),
            child: const Icon(Icons.factory, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bem-vindo, $name",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Role: $role • Site: DQX",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpisBlock() {
    return AnimatedBuilder(
      animation: _kpiCtrl,
      builder: (_, __) {
        final loading = _kpiCtrl.loading;
        final k = _kpiCtrl.kpis;

        String vToday() =>
            loading ? "..." : (k == null ? "—" : "${k.todayCount}");
        String vLast7() =>
            loading ? "..." : (k == null ? "—" : "${k.last7dCount}");
        String vTopLine() => loading ? "..." : (k == null ? "—" : k.topLine);
        String vTopMachine() =>
            loading ? "..." : (k == null ? "—" : k.topMachine);

        Widget card(String title, String value) {
          return Expanded(
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.75),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Row(
              children: [
                card("Hoje", vToday()),
                const SizedBox(width: 10),
                card("Últimos 7 dias", vLast7()),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                card("Linha mais afetada", vTopLine()),
                const SizedBox(width: 10),
                card("Máquina mais recorrente", vTopMachine()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      );

  Widget _bigAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primary ? AppTheme.gold.withOpacity(.95) : AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary
                ? AppTheme.gold.withOpacity(.55)
                : AppTheme.border.withOpacity(.35),
          ),
          boxShadow: primary
              ? const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    color: Color(0x22000000),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary
                    ? Colors.black.withOpacity(.12)
                    : AppTheme.bg.withOpacity(.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: primary ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primary ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: primary
                          ? Colors.black.withOpacity(.7)
                          : Colors.white.withOpacity(.75),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: primary ? Colors.black : Colors.white.withOpacity(.85),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _noRoleCard() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(16),
        child: _card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Sem role no DQX",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                "Seu login está ok, mas o Supabase não retornou seu role.\nClique em Recarregar.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(.75)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _load,
                child: const Text("Recarregar",
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
