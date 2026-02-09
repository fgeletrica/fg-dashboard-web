import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/app_routes.dart';
import '../services/auth/role_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    if (_navigated) return;
    _navigated = true;

    final sb = Supabase.instance.client;

    // espera auth estabilizar
    final start = DateTime.now();
    while (sb.auth.currentUser == null &&
        DateTime.now().difference(start).inMilliseconds < 2500) {
      await Future.delayed(const Duration(milliseconds: 120));
    }

    final role = await RoleService.getRoleStrict();
    if (!mounted) return;

    final dest =
        (role == 'pro') ? AppRoutes.homePro : AppRoutes.homeClient;

    Navigator.pushNamedAndRemoveUntil(context, dest, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
