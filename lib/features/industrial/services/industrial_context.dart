import 'package:supabase_flutter/supabase_flutter.dart';

class IndustrialContext {
  final String orgId;
  final String siteId;
  final String role;
  final String displayName;

  const IndustrialContext({
    required this.orgId,
    required this.siteId,
    required this.role,
    required this.displayName,
  });

  bool get isSupervisor => role == 'supervisor' || role == 'admin';
}

class IndustrialContextService {
  static Future<IndustrialContext?> loadMyContext() async {
    final client = Supabase.instance.client;
    final u = client.auth.currentUser;
    if (u == null) return null;

    final res = await client
        .from('industrial_user_roles')
        .select('org_id, site_id, role, display_name')
        .eq('user_id', u.id)
        .limit(1);

    if (res is! List || res.isEmpty) return null;
    final m = (res.first as Map).cast<String, dynamic>();

    final display = (m['display_name'] ?? '').toString().trim();
    final fallback = (u.email ?? 'operador').split('@').first;

    return IndustrialContext(
      orgId: (m['org_id'] ?? '').toString(),
      siteId: (m['site_id'] ?? '').toString(),
      role: (m['role'] ?? 'operator').toString(),
      displayName: display.isNotEmpty ? display : fallback,
    );
  }
}
