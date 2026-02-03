import 'package:supabase_flutter/supabase_flutter.dart';

class IndustrialKpis {
  final int todayCount;
  final int last7dCount;
  final String topLine;
  final String topMachine;

  const IndustrialKpis({
    required this.todayCount,
    required this.last7dCount,
    required this.topLine,
    required this.topMachine,
  });
}

class IndustrialKpiService {
  static int _startOfDayMs(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  static int _endOfDayMs(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).millisecondsSinceEpoch;

  static Future<List<Map<String, dynamic>>> _fetchRange({
    required String siteId,
    required int startMs,
    required int endMs,
    int limit = 5000,
  }) async {
    final sb = Supabase.instance.client;

    dynamic q = sb
        .from('industrial_diagnostics_export')
        .select('created_at_ms,line,machine')
        .filter('site_id', 'eq', siteId)
        .gte('created_at_ms', startMs)
        .lte('created_at_ms', endMs)
        .order('created_at_ms', ascending: false)
        .limit(limit);

    final res = await q;
    if (res is! List) return <Map<String, dynamic>>[];
    return res.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static String _safeStr(dynamic v) => (v ?? '').toString().trim();

  static String _topKey(Map<String, int> m) {
    if (m.isEmpty) return '—';
    final top = m.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  static Future<IndustrialKpis> fetchForSite({required String siteId}) async {
    final now = DateTime.now();

    final todayStart = _startOfDayMs(now);
    final todayEnd = _endOfDayMs(now);

    final last7Start = _startOfDayMs(now.subtract(const Duration(days: 6)));
    final last7End = todayEnd;

    final today = await _fetchRange(
      siteId: siteId,
      startMs: todayStart,
      endMs: todayEnd,
      limit: 5000,
    );

    final last7 = await _fetchRange(
      siteId: siteId,
      startMs: last7Start,
      endMs: last7End,
      limit: 5000,
    );

    final lineCount = <String, int>{};
    final machineCount = <String, int>{};

    for (final r in last7) {
      final line = _safeStr(r['line']);
      final machine = _safeStr(r['machine']);
      final lk = line.isEmpty ? '—' : line;
      final mk = machine.isEmpty ? '—' : machine;
      lineCount[lk] = (lineCount[lk] ?? 0) + 1;
      machineCount[mk] = (machineCount[mk] ?? 0) + 1;
    }

    return IndustrialKpis(
      todayCount: today.length,
      last7dCount: last7.length,
      topLine: _topKey(lineCount),
      topMachine: _topKey(machineCount),
    );
  }
}
