import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_theme.dart';
import '../services/industrial_context.dart';
import 'new_diagnostic_screen.dart';
import 'history_export_screen.dart';
import 'supervisor_users_screen.dart';
import 'supervisor_audit_screen.dart';

class IndustrialDiagnosticsHomeScreen extends StatefulWidget {
  const IndustrialDiagnosticsHomeScreen({super.key});

  @override
  State<IndustrialDiagnosticsHomeScreen> createState() =>
      _IndustrialDiagnosticsHomeScreenState();
}

class _IndustrialDiagnosticsHomeScreenState
    extends State<IndustrialDiagnosticsHomeScreen> {
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
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
          IconButton(
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
              ? Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 520),
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.35)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Sem role no DQX',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(
                            'Seu login está ok, mas o Supabase não retornou seu role.\n'
                            'Se você acabou de criar conta, aguarde alguns segundos e clique Recarregar.\n'
                            'Se continuar, é o SQL (auto-operator / industrial_user_roles).',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white.withOpacity(.75)),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                              onPressed: _load,
                              child: const Text('Recarregar')),
                        ],
                      ),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _whoCard(ctx!),
                    const SizedBox(height: 12),
                    _btn('Novo Diagnóstico', Icons.playlist_add_check,
                        () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NewDiagnosticScreen()),
                      );
                      if (ok == true) _load();
                    }),
                    const SizedBox(height: 10),
                    _btn('Histórico + Export (PDF/CSV)', Icons.picture_as_pdf,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryExportScreen()));
                    }),
                    if (ctx!.isSupervisor) ...[
                      const SizedBox(height: 14),
                      Text('Supervisor',
                          style: TextStyle(
                              color: Colors.white.withOpacity(.8),
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      _btn('Supervisor • Usuários do site', Icons.group, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SupervisorUsersScreen()));
                      }),
                      const SizedBox(height: 10),
                      _btn('Supervisor • Auditoria', Icons.history, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SupervisorAuditScreen()));
                      }),
                    ],
                  ],
                ),
    );
  }

  Widget _whoCard(IndustrialContext c) {
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

  Widget _btn(String text, IconData icon, VoidCallback onTap) {
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
}
