import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../models/industrial_models.dart';
import '../models/shift_summary.dart';

class IndustrialStore {
  static const _kLineStops = 'ind_line_stops_v1';
  static const _kKnowledge = 'ind_knowledge_v1';
  static const _kChecklistRuns = 'ind_checklist_runs_v1';
  static const _kShiftSummaries = 'ind_shift_summaries_v1';

  // ========= BASE =========
  static Future<List<String>> _get(String k) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(k) ?? <String>[];
  }

  static Future<void> _set(String k, List<String> v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(k, v);
  }

  // ========= LINHA PAROU =========
  static Future<List<LineStopReport>> listLineStops({int limit = 500}) async {
    final raw = await _get(_kLineStops);
    final list = raw.map((e) => LineStopReport.fromJson(e)).toList();
    list.sort((a, b) => b.ts.compareTo(a.ts));
    return list.take(limit).toList();
  }

  static Future<void> addLineStop(LineStopReport r) async {
    final raw = await _get(_kLineStops);
    raw.add(r.toJson());
    await _set(_kLineStops, raw);
  }

  static Future<void> deleteLineStop(String id) async {
    final raw = await _get(_kLineStops);
    raw.removeWhere((e) {
      try {
        final m = jsonDecode(e) as Map<String, dynamic>;
        return (m['id'] ?? '').toString() == id;
      } catch (_) {
        return false;
      }
    });
    await _set(_kLineStops, raw);
  }

  // ========= KNOWLEDGE =========
  static Future<List<KnowledgeItem>> listKnowledge({int limit = 500}) async {
    final raw = await _get(_kKnowledge);
    final items = raw
        .map(
            (e) => KnowledgeItem.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => b.ts.compareTo(a.ts));
    return items.take(limit).toList();
  }

  static Future<void> addKnowledge(KnowledgeItem k) async {
    final raw = await _get(_kKnowledge);
    raw.add(jsonEncode(k.toMap()));
    await _set(_kKnowledge, raw);
  }

  static Future<void> deleteKnowledge(String id) async {
    final raw = await _get(_kKnowledge);
    raw.removeWhere((e) {
      try {
        final m = jsonDecode(e) as Map<String, dynamic>;
        return (m['id'] ?? '').toString() == id;
      } catch (_) {
        return false;
      }
    });
    await _set(_kKnowledge, raw);
  }

  // ========= CHECKLISTS =========
  static Future<List<ChecklistRun>> listChecklistRuns({int limit = 300}) async {
    final raw = await _get(_kChecklistRuns);
    final items = raw
        .map((e) => ChecklistRun.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => b.ts.compareTo(a.ts));
    return items.take(limit).toList();
  }

  static Future<void> addChecklistRun(ChecklistRun r) async {
    final raw = await _get(_kChecklistRuns);
    raw.add(jsonEncode(r.toMap()));
    await _set(_kChecklistRuns, raw);
  }

  // ========= FILTRO =========
  static List<LineStopReport> filterLineStops(
    List<LineStopReport> all, {
    required DateTime start,
    required DateTime end,
    String shift = 'ALL',
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return all.where((r) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
      if (dt.isBefore(start) || dt.isAfter(end)) return false;
      if (shift != 'ALL' && r.shift != shift) return false;

      if (q.isNotEmpty) {
        final hay = ('${r.area} ${r.machine} ${r.symptom} ${r.description} '
                '${r.probableCause} ${r.actionTaken} ${r.prevention}')
            .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  // ========= CSV =========
  static String _csvEsc(String s) {
    final v = s.replaceAll('"', '""');
    return '"$v"';
  }

  static int parseDowntimeMin(LineStopReport r) {
    final raw = r.downtimeMin.trim();
    if (raw.isEmpty) return 0;
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  static Future<File> exportLineStopsCsv(
    List<LineStopReport> list, {
    String filenamePrefix = 'linha_parou',
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/$filenamePrefix-$ts.csv');

    final b = StringBuffer();
    b.writeln(
        'data,turno,area,maquina,sintoma,causa,acao,tempo_min,descricao,prevencao,testes');
    for (final r in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.ts).toString();
      final tests = r.testsDone.join(' | ');
      b.writeln([
        _csvEsc(dt),
        _csvEsc(r.shift),
        _csvEsc(r.area),
        _csvEsc(r.machine),
        _csvEsc(r.symptom),
        _csvEsc(r.probableCause),
        _csvEsc(r.actionTaken),
        _csvEsc(r.downtimeMin),
        _csvEsc(r.description),
        _csvEsc(r.prevention),
        _csvEsc(tests),
      ].join(','));
    }

    await file.writeAsString(b.toString(), flush: true);
    return file;
  }

  // ========= ANALYTICS (Ranking/Heatmap) =========
  static int sumDowntime(List<LineStopReport> list) {
    var s = 0;
    for (final r in list) {
      s += parseDowntimeMin(r);
    }
    return s;
  }

  static Map<String, int> countByMachine(List<LineStopReport> list) {
    final m = <String, int>{};
    for (final r in list) {
      final k = r.machine.trim().isEmpty ? '—' : r.machine.trim();
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  static Map<String, int> countByCause(List<LineStopReport> list) {
    final m = <String, int>{};
    for (final r in list) {
      final k = r.probableCause.trim().isEmpty ? '—' : r.probableCause.trim();
      m[k] = (m[k] ?? 0) + 1;
    }
    return m;
  }

  static Map<String, int> downtimeByMachine(List<LineStopReport> list) {
    final m = <String, int>{};
    for (final r in list) {
      final k = r.machine.trim().isEmpty ? '—' : r.machine.trim();
      m[k] = (m[k] ?? 0) + parseDowntimeMin(r);
    }
    return m;
  }

  static String topKey(Map<String, int> m) {
    if (m.isEmpty) return '—';
    final top = m.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return top.key;
  }

  static List<MapEntry<String, int>> topN(Map<String, int> m, {int n = 5}) {
    final list = m.entries.toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(n).toList();
  }

  // Heatmap por hora (0..23) usando downtime (min)
  static List<int> downtimeHeatByHour(List<LineStopReport> list) {
    final buckets = List<int>.filled(24, 0);
    for (final r in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
      buckets[dt.hour] += parseDowntimeMin(r);
    }
    return buckets;
  }

  // ========= A (turno) =========
  static Future<List<ShiftCloseSummary>> listShiftSummaries(
      {int limit = 200}) async {
    final raw = await _get(_kShiftSummaries);
    final list = raw.map((e) => ShiftCloseSummary.fromJson(e)).toList();
    list.sort((a, b) => b.ts.compareTo(a.ts));
    return list.take(limit).toList();
  }

  static Future<void> closeShiftAndClear({
    required String shift,
    required DateTime start,
    required DateTime end,
  }) async {
    final all = await listLineStops(limit: 2000);
    final filtered = filterLineStops(all, start: start, end: end, shift: shift);

    final summary = ShiftCloseSummary(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ts: DateTime.now().millisecondsSinceEpoch,
      shift: shift,
      totalStops: filtered.length,
      downtimeMin: sumDowntime(filtered),
      topMachine: topKey(downtimeByMachine(filtered)),
      topCause: topKey(countByCause(filtered)),
    );

    final sums = await _get(_kShiftSummaries);
    sums.add(summary.toJson());
    await _set(_kShiftSummaries, sums);

    // remove do histórico os itens desse turno/intervalo
    final remaining = all.where((r) => !filtered.contains(r)).toList();
    await _set(_kLineStops, remaining.map((e) => e.toJson()).toList());
  }
}
