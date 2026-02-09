import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../local_store.dart';

class RoleService {
  static final SupabaseClient _sb = Supabase.instance.client;

  /// Fonte de verdade: public.profiles.role  ('pro' | 'client')
  /// - Server FIRST
  /// - Retry
  /// - Cache só como fallback (se server falhar)
  static Future<String> getRoleStrict({
    Duration maxWait = const Duration(seconds: 8),
  }) async {
    // 1) espera currentUser estabilizar
    final started = DateTime.now();
    while (_sb.auth.currentUser == null &&
        DateTime.now().difference(started) < const Duration(seconds: 3)) {
      await Future.delayed(const Duration(milliseconds: 120));
    }

    final u = _sb.auth.currentUser;
    if (u == null) {
      // sem sessão: tenta cache, senão client
      try {
        final cached = await LocalStore.getMarketRole();
        return (cached == 'pro') ? 'pro' : 'client';
      } catch (_) {
        return 'client';
      }
    }

    // 2) tenta server até maxWait
    final deadline = DateTime.now().add(maxWait);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final Map<String, dynamic> res = await _sb
            .from('profiles')
            .select('role')
            .eq('id', u.id)
            .single()
            .timeout(const Duration(seconds: 3));

        final raw = (res['role'] ?? '').toString().trim().toLowerCase();
        if (raw == 'pro' || raw == 'client') {
          try {
            await LocalStore.setMarketRole(raw);
          } catch (_) {}
          return raw;
        }
      } catch (_) {
        // segue tentando
      }

      await Future.delayed(const Duration(milliseconds: 250));
    }

    // 3) fallback cache (último valor conhecido)
    try {
      final cached = await LocalStore.getMarketRole();
      return (cached == 'pro') ? 'pro' : 'client';
    } catch (_) {
      return 'client';
    }
  }
}
