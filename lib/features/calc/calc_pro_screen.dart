import 'package:meu_ajudante_fg/services/pro_guard.dart';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../routes/app_routes.dart';

class CalcProScreen extends StatelessWidget {
  const CalcProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Cálculo PRO'),
      ),
      body: Padding(
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
              Icon(Icons.lock, color: AppTheme.gold, size: 40),
              const SizedBox(height: 10),
              const Text('Recurso PRO',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 6),
              Text('Desbloqueie para usar este módulo.',
                  style: TextStyle(color: Colors.white.withOpacity(.70))),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
