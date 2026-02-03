import 'package:supabase_flutter/supabase_flutter.dart';

class IndustrialSupervisorService {
  static Future<List<Map<String, dynamic>>> listUsers() async {
    final client = Supabase.instance.client;
    final res = await client.rpc('supervisor_list_users');
    if (res is! List) return <Map<String, dynamic>>[];
    return res.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> setRoleChecked({
    required String targetUserId,
    required String newRole,
    required String displayName,
  }) async {
    final client = Supabase.instance.client;
    await client.rpc('industrial_set_role_checked', params: {
      '_target_user': targetUserId,
      '_new_role': newRole,
      '_display_name': displayName,
    });
  }

  static Future<List<Map<String, dynamic>>> listAudit({
    required String siteId,
    int limit = 200,
  }) async {
    final client = Supabase.instance.client;

    final res = await client
        .from('industrial_audit_log')
        .select()
        .eq('site_id', siteId)
        .order('created_at', ascending: false)
        .limit(limit);

    if (res is! List) return <Map<String, dynamic>>[];
    return res.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}
