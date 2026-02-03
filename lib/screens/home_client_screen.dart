import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';
import '../services/auth/auth_service.dart';

class HomeClientScreen extends StatelessWidget {
  const HomeClientScreen({super.key});

  void _go(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService.signOut();
    } catch (_) {}
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.authGate, (_) => false);
  }

  Widget _gridCard(BuildContext context,
      {required IconData icon, required String title, required String route}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _go(context, route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border.withOpacity(.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border.withOpacity(.25)),
              ),
              child: Icon(icon, color: AppTheme.gold),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15),
            ),
            const Spacer(),
            Row(
              children: [
                Text('Abrir',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.65),
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(.55)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text('Painel Cliente'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.gold.withOpacity(.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppTheme.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Crie um pedido no Marketplace e aguarde um profissional chamar no WhatsApp.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _gridCard(context,
                  icon: Icons.miscellaneous_services_outlined,
                  title: 'Marketplace\nServiços',
                  route: AppRoutes.marketplace),
              _gridCard(context,
                  icon: Icons.calculate_outlined,
                  title: 'Cálculo\nElétrico',
                  route: AppRoutes.calc),
              _gridCard(context,
                  icon: Icons.inventory_2_outlined,
                  title: 'Materiais',
                  route: AppRoutes.materiais),
              _gridCard(context,
                  icon: Icons.account_circle_outlined,
                  title: 'Minha\nConta',
                  route: AppRoutes.conta),
            ],
          ),
        ],
      ),
    );
  }
}
