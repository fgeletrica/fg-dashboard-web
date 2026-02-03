import 'package:meu_ajudante_fg/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'pro_access.dart';

class ProGuard {
  /// Retorna o estado PRO (async) — fonte única
  static Future<bool> hasPro() async {
    return await ProAccess.hasProAccessNow();
  }

  /// Garante acesso PRO sem obrigar o caller a usar await.
  /// - Se for PRO → executa a ação
  /// - Se for FREE → abre paywall
  static void requirePro(BuildContext context, VoidCallback action) {
    hasPro().then((ok) async {
      if (!context.mounted) return;
      if (ok) {
        action();
      } else {
        Navigator.of(context).pushNamed(AppRoutes.paywall);
      }
    });
  }
}
