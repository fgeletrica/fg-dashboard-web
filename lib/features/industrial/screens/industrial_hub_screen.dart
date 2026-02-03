import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meu_ajudante_fg/core/app_theme.dart';
import '../services/industrial_context.dart';

// Telas que você já tem (pelo seu ls)
import 'diagnosis_screen.dart';
import 'line_stop_screen.dart';
import 'checklists_screen.dart';
import 'knowledge_base_screen.dart';
import 'line_stop_history_screen.dart';

// Supervisor (que você já criou)
import 'supervisor_users_screen.dart';
import 'supervisor_audit_screen.dart';

class IndustrialHubScreen extends StatefulWidget {
  const IndustrialHubScreen({super.key});

  @override
  State<IndustrialHubScreen> createState() => _IndustrialHubScreenState();
}

class _IndustrialHubScreenState extends State<IndustrialHubScreen> {
  IndustrialContext? ctx;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final c = await IndustrialContextService.loadMyContext();
    if (!mounted) return;
    setState(() {
      ctx = c;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('Industrial • DQX'),
        actions: [
          IconButton(
            tooltip: 'Recarregar role',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (ctx == null)
              ? _noRole()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _who(ctx!),
                    const SizedBox(height: 12),
                    _gridButtons(context),
                    const SizedBox(height: 14),
                    if (ctx!.isSupervisor) ...[
                      _section('Supervisor'),
                      const SizedBox(height: 10),
                      _bigBtn(
                        context,
                        'Supervisor • Usuários do site',
                        Icons.group,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SupervisorUsersScreen()),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _bigBtn(
                        context,
                        'Supervisor • Auditoria',
                        Icons.history,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SupervisorAuditScreen()),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _section('Atalhos rápidos'),
                    const SizedBox(height: 10),
                    _cardTile(
                      title: 'Falhas recorrentes',
                      subtitle: 'Ver histórico de paradas e padrões',
                      icon: Icons.repeat,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LineStopHistoryScreen()),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _gridButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _tile(
                'Diagnóstico',
                Icons.medical_services,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const DiagnosisScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _tile(
                'Linha Parou',
                Icons.warning_amber,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LineStopScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _tile(
                'Checklists',
                Icons.checklist,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChecklistsScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _tile(
                'Base de conhecimento',
                Icons.menu_book,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const KnowledgeBaseScreen())),
              ),
            ),
          ],
        ),
      ],
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
              const Text('Sem role no DQX',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                'Seu login está ok, mas o Supabase ainda não retornou seu role.\nClique em Recarregar.',
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
                child: const Text('Recarregar',
                    style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _who(IndustrialContext c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border.withOpacity(.35)),
      ),
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
    );
  }

  Widget _section(String t) => Text(t,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16));

  Widget _tile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 84,
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
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.6)),
          ],
        ),
      ),
    );
  }

  Widget _bigBtn(
      BuildContext context, String text, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.gold,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _cardTile({
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
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(.7), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(.6)),
          ],
        ),
      ),
    );
  }
}
