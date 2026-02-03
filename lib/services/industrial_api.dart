import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:csv/csv.dart';

import 'download_csv.dart';

class IndustrialApi {
  static Future<List<Map<String, dynamic>>> listDiagnostics({
    required String siteId,
    required int startMs,
    required int endMs,
    String shift = 'ALL',
    String line = 'ALL',
    String group = 'ALL',
    String machine = 'ALL',
    int limit = 5000,
  }) async {
    final client = Supabase.instance.client;

    // ⚠️ dynamic para evitar o erro de tipagem do PostgrestTransformBuilder
    dynamic q = client
        .from('industrial_diagnostics_export')
        .select()
        .eq('site_id', siteId)
        .gte('created_at_ms', startMs)
        .lte('created_at_ms', endMs)
        .order('created_at_ms', ascending: false)
        .limit(limit);

    if (shift != 'ALL') q = q.eq('shift', shift);
    if (line != 'ALL') q = q.eq('line', line);
    if (group != 'ALL') q = q.eq('machine_group', group);
    if (machine != 'ALL') q = q.eq('machine', machine);

    final res = await q;
    if (res is! List) return <Map<String, dynamic>>[];
    return res.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<List<Map<String, dynamic>>> listAudit({
    required String siteId,
    int limit = 300,
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

  static Future<List<Map<String, dynamic>>> listUsers() async {
    final client = Supabase.instance.client;
    final res = await client.rpc('supervisor_list_users');
    if (res is! List) return <Map<String, dynamic>>[];
    return res.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static String buildCsv(List<Map<String, dynamic>> list) {
    final rows = <List<String>>[
      [
        'data',
        'turno',
        'linha',
        'grupo',
        'maquina',
        'problema',
        'acao_tomada',
        'causa_raiz',
        'descricao_causa',
        'usuario',
      ],
    ];

    for (final d in list) {
      rows.add([
        (d['created_at'] ?? '').toString(),
        (d['shift'] ?? '').toString(),
        (d['line'] ?? '').toString(),
        (d['machine_group'] ?? '').toString(),
        (d['machine'] ?? '').toString(),
        (d['problem'] ?? '').toString(),
        (d['action_taken'] ?? '').toString(),
        (d['has_root_cause'] == true) ? 'SIM' : 'NAO',
        (d['root_cause'] ?? '').toString(),
        (d['created_by_name'] ?? '').toString(),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  static void downloadCsv(String filename, String csv) {
    downloadCsvWeb(filename, csv);
  }
}
