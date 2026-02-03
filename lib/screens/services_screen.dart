import 'package:flutter/material.dart';

import 'package:meu_ajudante_fg/core/app_theme.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';
import 'package:meu_ajudante_fg/services/pro_guard.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Meus Serviços'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border.withOpacity(.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Módulo de Serviços',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Gerencie seus serviços e preços. Alguns recursos são PRO.',
                    style: TextStyle(color: Colors.white.withOpacity(.75)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Text('Voltar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gold,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => ProGuard.requirePro(context, () {
                            Navigator.of(context).pushNamed(AppRoutes.paywall);
                          }),
                          child: const Text(
                            'Ver planos',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storefront),
                    title: const Text('Marketplace'),
                    subtitle: const Text('Serviços e catálogo'),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.marketplace),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Área PRO (Serviços avançados)'),
                    subtitle: const Text('Recurso PRO'),
                    onTap: () => ProGuard.requirePro(context, () {
                      Navigator.of(context).pushNamed(AppRoutes.paywall);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
