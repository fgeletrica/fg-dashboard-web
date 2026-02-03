import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

import '../services/industrial_context.dart';

import 'new_diagnostic_screen.dart';
import 'history_export_screen.dart';
import 'supervisor_users_screen.dart';
import 'supervisor_audit_screen.dart';

class IndustrialDashboardScreen extends StatefulWidget {
  const IndustrialDashboardScreen({super.key});

  @override
  State<IndustrialDashboardScreen> createState() =>
      _IndustrialDashboardScreenState();
}

class _IndustrialDashboardScreenState extends State<IndustrialDashboardScreen> {
  IndustrialContext? _ctx;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final c = await IndustrialContextService.loadMyContext();
    if (!mounted) return;
    setState(() {
      _ctx = c;
      _loading = false;
    });
  }

  void _go(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctx;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text("HOME_V2_ATIVA • " + 'Industrial • DQX'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (c == null)
              ? _noRole()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _hero(c),
                    const SizedBox(height: 12),
                    _kpiRow(c),
                    const SizedBox(height: 14),
                    _sectionTitle('Ações rápidas'),
                    const SizedBox(height: 10),
                    _gridActions(c),
                    const SizedBox(height: 16),
                    if (c.isSupervisor) ...[
                      _sectionTitle('Supervisor'),
                      const SizedBox(height: 10),
                      _supervisorBlock(),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(.25)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      child: const Text('Voltar / Trocar modo',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
    );
  }

  Widget _hero(IndustrialContext c) {
    final role = c.role.toUpperCase();
    final site = c.siteName.isEmpty ? 'DQX' : c.siteName;
    final org = c.orgName.isEmpty ? 'Coca Cola Andina' : c.orgName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 12),
            color: Color(0x22000000),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(.16),
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
                  org,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Site: $site',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill('ROLE: $role', Icons.badge),
                    _pill(c.displayName.isEmpty ? 'Usuário' : c.displayName,
                        Icons.person),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.bg.withOpacity(.35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(.9)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(.9),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiRow(IndustrialContext c) {
    // por enquanto: KPIs “visuais” (depois a gente liga com dados reais)
    // eles já deixam a tela com “cara de sistema”
    final isSup = c.isSupervisor;
    return Row(
      children: [
        Expanded(
          child: _kpi(
            title: 'Status',
            value: 'Online',
            icon: Icons.wifi_tethering,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _kpi(
            title: 'Acesso',
            value: isSup ? 'Supervisor' : 'Operador',
            icon: isSup ? Icons.admin_panel_settings : Icons.engineering,
          ),
        ),
      ],
    );
  }

  Widget _kpi({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.bg.withOpacity(.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(.12)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    )),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: TextStyle(
        color: Colors.white.withOpacity(.92),
        fontWeight: FontWeight.w900,
        fontSize: 14,
      ),
    );
  }

  Widget _gridActions(IndustrialContext c) {
    // Grid responsivo simples
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final cols = w > 520 ? 2 : 1;
        final gap = 10.0;

        final cards = <Widget>[
          _actionCard(
            title: 'Novo diagnóstico',
            desc: 'Registrar problema + ação + causa raiz',
            icon: Icons.playlist_add_check,
            primary: true,
            onTap: () => _go(const NewDiagnosticScreen()),
          ),
          _actionCard(
            title: 'Histórico + Export',
            desc: 'Buscar e gerar PDF/CSV por período',
            icon: Icons.picture_as_pdf,
            onTap: () => _go(const HistoryExportScreen()),
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards.map((c) {
            return SizedBox(
              width: cols == 2 ? (w - gap) / 2 : w,
              child: c,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _actionCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    final bg = primary ? AppTheme.gold : AppTheme.card;
    final fg = primary ? Colors.black : Colors.white;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: primary
                ? Colors.black.withOpacity(.12)
                : AppTheme.border.withOpacity(.35),
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 10),
              color: Color(0x22000000),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary
                    ? Colors.black.withOpacity(.10)
                    : AppTheme.bg.withOpacity(.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primary
                      ? Colors.black.withOpacity(.15)
                      : Colors.white.withOpacity(.12),
                ),
              ),
              child: Icon(icon, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: fg.withOpacity(primary ? .85 : .70),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: fg.withOpacity(.9)),
          ],
        ),
      ),
    );
  }

  Widget _supervisorBlock() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
      child: Column(
        children: [
          _superRow(
            title: 'Usuários do site',
            desc: 'Promover operator → technician/supervisor/admin',
            icon: Icons.group,
            onTap: () => _go(const SupervisorUsersScreen()),
          ),
          const SizedBox(height: 10),
          _superRow(
            title: 'Auditoria',
            desc: 'Ver ações e mudanças registradas',
            icon: Icons.history,
            onTap: () => _go(const SupervisorAuditScreen()),
          ),
        ],
      ),
    );
  }

  Widget _superRow({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.bg.withOpacity(.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.12)),
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
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text(desc,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.7)),
          ],
        ),
      ),
    );
  }

  Widget _noRole() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border.withOpacity(.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sem role no DQX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sua conta ainda não recebeu acesso ao site DQX.\n'
                'Peça para um supervisor liberar seu usuário.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.75),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _load,
                child: const Text('Tentar novamente',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
