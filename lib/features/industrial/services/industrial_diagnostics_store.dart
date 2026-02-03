import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/industrial_diagnostic.dart';

class IndustrialDiagnosticsStore {
  static Future<void> insert(IndustrialDiagnostic d) async {
    final client = Supabase.instance.client;
    await client.from('industrial_diagnostics').insert(d.toSupabase());
  }

  /// Lista registros por período + filtros.
  /// Importante: usamos `dynamic` e aplicamos filtros ANTES de order/limit
  /// pra não cair no erro de PostgrestTransformBuilder sem .eq().
  static Future<List<Map<String, dynamic>>> listByRange({
    required String siteId,
    required int startMs,
    required int endMs,
    String shift = 'ALL',
    String line = 'ALL',
    String machineGroup = 'ALL',
    String machine = 'ALL',
    int limit = 5000,
  }) async {
    final client = Supabase.instance.client;

    dynamic q = client.from('industrial_diagnostics_export').select();

    q = q.eq('site_id', siteId);
    q = q.gte('created_at_ms', startMs);
    q = q.lte('created_at_ms', endMs);

    if (shift != 'ALL') q = q.eq('shift', shift);
    if (line != 'ALL') q = q.eq('line', line);
    if (machineGroup != 'ALL') q = q.eq('machine_group', machineGroup);
    if (machine != 'ALL') q = q.eq('machine', machine);

    q = q.order('created_at_ms', ascending: false);
    q = q.limit(limit);

    final res = await q;
    if (res is! List) return <Map<String, dynamic>>[];
    return res.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }
}
