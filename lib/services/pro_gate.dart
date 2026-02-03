import 'package:flutter/material.dart';
import 'package:meu_ajudante_fg/routes/app_routes.dart';
import 'pro_access.dart';

class ProGate {
  static Future<void> open(BuildContext context, String route,
      {bool proOnly = false}) async {
    final has = await ProAccess.hasProAccessNow();
    if (proOnly && !has) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Recurso PRO — desbloqueie para usar ✅')),
        );
        Navigator.of(context).pushNamed(AppRoutes.paywall);
      }
      return;
    }
    if (context.mounted) Navigator.of(context).pushNamed(route);
  }
}
