import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../../routes/app_routes.dart';

Future<void> proGuard(BuildContext context) async {
  final role = await AuthService.getMyRole();
  if (role != 'pro') {
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
}
