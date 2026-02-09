import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local_store.dart';

class RoleResolver {
  static final _sb = Supabase.instance.client;

  /// STRICT:
  /// - tenta pegar SEMPRE do server (profiles.role)
  /// - só usa cache se existir (nullable)
  /// - se não conseguir determinar, lança exception (pra UI não “mentir” como client)
  static Future<String> resolveRoleStrict({
    Duration maxWait = const Duration(seconds: 6),
  }) async {
    final deadline = DateTime.now().add(maxWait);

    // espera currentUser estabilizar
    while (_sb.auth.currentUser == null && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 120));
    }

    final u = _sb.auth.currentUser;
    if (u == null) {
      final cached = await LocalStore.getMarketRoleNullable();
      if (cached != null) return cached;
      throw Exception('Sem sessão e sem role em cache');
    }

    // tenta ler do server com retry até maxWait
    while (DateTime.now().isBefore(deadline)) {
      try {
        final Map<String, dynamic>? res = await _sb
            .from('profiles')
            .select('role')
            .eq('id', u.id)
            .maybeSingle();

        final raw = (res?['role'] ?? '').toString().trim().toLowerCase();
        if (raw == 'pro' || raw == 'client') {
          try {
            await LocalStore.setMarketRole(raw);
          } catch (_) {}
          return raw;
        }
      } catch (_) {
        // erro de rede/DNS/RLS -> tenta de novo até deadline
      }
      await Future.delayed(const Duration(milliseconds: 220));
    }

    // fallback: cache REAL (se existir)
    final cached = await LocalStore.getMarketRoleNullable();
    if (cached != null) return cached;

    throw Exception('Não consegui resolver role (sem server e sem cache)');
  }

  /// “Soft”: mantém compat com código antigo.
  /// Se strict falhar, devolve 'client' (mas a navegação principal deve usar strict).
  static Future<String> resolveRole() async {
    try {
      final r = await resolveRoleStrict(maxWait: const Duration(seconds: 6));
      return (r == 'pro') ? 'pro' : 'client';
    } catch (_) {
      return 'client';
    }
  }
}
