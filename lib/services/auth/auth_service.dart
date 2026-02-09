import 'package:supabase_flutter/supabase_flutter.dart';
import '../local_store.dart';
import 'role_resolver.dart';

class AuthService {
  static final SupabaseClient _sb = Supabase.instance.client;

  static User? get user => _sb.auth.currentUser;
  static Session? get session => _sb.auth.currentSession;

  static bool get isLoggedIn => session != null;

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

    // IMPORTANTE: não força cache pra "client" em corrida pós-login
    // Só aquece o cache se conseguir ler um valor válido do server.
    try {
      await getMyRole();
    } catch (_) {}
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required String role, // client | pro
    required String name,
    required String city,
    required String phone,
  }) async {
    final res = await _sb.auth.signUp(
      email: email,
      password: password,
    );

    final u = res.user;
    if (u == null) {
      throw Exception('Falha ao criar usuário');
    }

    final normalized = (role == 'pro') ? 'pro' : 'client';

    await _sb.from('profiles').upsert({
      'id': u.id,
      'role': normalized,
      'name': name,
      'city': city,
      'phone': phone,
    });

    // aqui pode gravar porque foi você que definiu o role no signUp
    try {
      await LocalStore.setMarketRole(normalized);
    } catch (_) {}
  }

  static Future<void> signOut() async {
    try {
      await _sb.auth.signOut();
    } finally {
      // limpa role local
      try {
        await LocalStore.clearMarketRole();
      } catch (_) {}
    }
  }

  /// Lê role do server.
  /// REGRA: só grava no cache quando server devolve "pro" ou "client".
  /// Se vier null/ruim (corrida/RLS/momento), NÃO sobrescreve com "client".
  static Future<String> getMyRole() async {
    final u = user;
    if (u == null) {
      // sem user: não mexe em cache
      return 'client';
    }

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

    // server não respondeu com valor válido -> usa cache, sem sobrescrever
    try {
      final cached = await LocalStore.getMarketRole();
      return (cached == 'pro') ? 'pro' : 'client';
    } catch (_) {
      return 'client';
    }
  }
}
