import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/app_routes.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/role_service.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool _checking = true;
  bool _navigated = false;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    _bootstrap();

    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      dev.log('[GATE] onAuthStateChange: ${event.event}', name: 'AUTH');
      if (!mounted) return;
      _navigated = false;
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;
    setState(() => _checking = true);

    final sb = Supabase.instance.client;
    dev.log('[GATE] isLoggedIn=${AuthService.isLoggedIn} user=${sb.auth.currentUser?.id}', name: 'AUTH');

    if (!AuthService.isLoggedIn) {
      if (!mounted) return;
      setState(() => _checking = false);
      return;
    }

    // aquece o resolver, mas com timeout pra não travar infinito
    try {
      final r = await RoleService.getRoleStrict().timeout(const Duration(seconds: 6));
      dev.log('[GATE] warm role=$r', name: 'AUTH');
    } catch (e) {
      dev.log('[GATE] warm role FAILED: $e', name: 'AUTH');
    }

    if (!mounted) return;
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!AuthService.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return FutureBuilder<String>(
      future: RoleService.getRoleStrict().timeout(
        const Duration(seconds: 6),
        onTimeout: () => 'client',
      ),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final role = (snap.data == 'pro') ? 'pro' : 'client';
        final dest = (role == 'pro') ? AppRoutes.homePro : AppRoutes.homeClient;

        dev.log('[GATE] decision role=$role dest=$dest', name: 'AUTH');

        if (_navigated) return const Scaffold(body: SizedBox.shrink());
        _navigated = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, dest, (_) => false);
        });

        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}
