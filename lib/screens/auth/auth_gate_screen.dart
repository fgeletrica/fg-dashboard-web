import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../routes/app_routes.dart';
import '../../services/auth/auth_service.dart';
import '../../services/local_store.dart';

class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();

    Supabase.instance.client.auth.onAuthStateChange.listen((_) async {
      if (!mounted) return;
      _bootstrap();
    });
  }

  /// 🔐 Lê account_type do profiles SEM quebrar se:
  /// - não existir coluna
  /// - não existir registro
  /// - vier null
  Future<String> _getAccountTypeSafe() async {
    final sb = Supabase.instance.client;
    final u = sb.auth.currentUser;
    if (u == null) return 'residential';

    try {
      final Map<String, dynamic>? res = await sb
          .from('profiles')
          .select('account_type')
          .eq('id', u.id)
          .maybeSingle();

      final v = (res?['account_type'] ?? '').toString().trim().toLowerCase();

      if (v == 'industrial' || v == 'residential') {
        return v;
      }
    } catch (_) {
      // ignora qualquer erro de schema
    }

    return 'residential';
  }

  Future<void> _bootstrap() async {
    setState(() => _checking = true);

    if (!AuthService.isLoggedIn) {
      if (!mounted) return;
      setState(() => _checking = false);
      return;
    }

    try {
      final role = await AuthService.getMyRole();
      await LocalStore.setMarketRole(role);
    } catch (_) {}

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
      future: _getAccountTypeSafe(),
      builder: (context, snapType) {
        if (!snapType.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final accountType = snapType.data!;

        return FutureBuilder<String>(
          future: AuthService.getMyRole(),
          builder: (context, snapRole) {
            if (!snapRole.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = snapRole.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              if (accountType == 'industrial') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.industrial,
                  (_) => false,
                );
              } else {
                if (role == 'pro') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homePro,
                    (_) => false,
                  );
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homeClient,
                    (_) => false,
                  );
                }
              }
            });

            return const Scaffold(body: SizedBox.shrink());
          },
        );
      },
    );
  }
}
