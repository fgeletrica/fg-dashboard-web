import 'package:supabase_flutter/supabase_flutter.dart';

import '../local_store.dart';

class AuthService {
  static SupabaseClient get _sb => Supabase.instance.client;

  static bool get isLoggedIn => _sb.auth.currentSession != null;

  static User? get user => _sb.auth.currentUser;

  // =========================
  // LOGIN / LOGOUT
  // =========================
  static Future<void> signOut() async {
    await _sb.auth.signOut();
    // evita role antigo ficar preso no aparelho
    try {
      await LocalStore.setMarketRole('client');
    } catch (_) {}
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _sb.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.session == null) {
      throw Exception('Falha ao entrar');
    }
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required String role, // client | pro
    required String name,
    required String city,
  }) async {
    final res = await _sb.auth.signUp(
      email: email,
      password: password,
    );

    final u = res.user;
    if (u == null) {
      throw Exception('Falha ao criar usuário');
    }

    // garante profile
    await _sb.from('profiles').upsert({
      'id': u.id,
      'role': role,
      'name': name,
      'city': city,
    });
  }

  // =========================
  // ROLE (CLIENTE vs PRO)
  // =========================
  static Future<String> getMyRole() async {
    final u = user;
    if (u == null) return 'client';

    final res =
        await _sb.from('profiles').select('role').eq('id', u.id).maybeSingle();

    return (res?['role'] ?? 'client').toString();
  }
}
