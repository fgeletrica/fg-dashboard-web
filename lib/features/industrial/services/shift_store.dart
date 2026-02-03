import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shift_models.dart';

class ShiftStore {
  static const _kSummaries = 'ind_supervisor_shift_summaries_v1';
  static const _kSupervisorInbox = 'ind_supervisor_inbox_v1';

  static Future<List<String>> _getList(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(key) ?? <String>[];
  }

  static Future<void> _setList(String key, List<String> v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(key, v);
  }

  // --------- SUMÁRIOS (local) ----------
  static Future<void> addSummary(ShiftSummary s) async {
    final raw = await _getList(_kSummaries);
    raw.add(s.toJson());
    await _setList(_kSummaries, raw);
  }

  static Future<List<ShiftSummary>> listSummaries({int limit = 200}) async {
    final raw = await _getList(_kSummaries);
    final list = raw.map((e) => ShiftSummary.fromJson(e)).toList();
    list.sort((a, b) => b.ts.compareTo(a.ts));
    return list.take(limit).toList();
  }

  // --------- COLETA SUPERVISOR ----------
  static Future<void> addSupervisorPackage(ShiftPackage p) async {
    final raw = await _getList(_kSupervisorInbox);
    raw.add(jsonEncode(p.toMap()));
    await _setList(_kSupervisorInbox, raw);
  }

  static Future<List<ShiftPackage>> listSupervisorPackages(
      {int limit = 500}) async {
    final raw = await _getList(_kSupervisorInbox);
    final list = raw
        .map((e) => ShiftPackage.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.summary.ts.compareTo(a.summary.ts));
    return list.take(limit).toList();
  }

  // --------- APAGAR TUDO (unificado) ----------
  static Future<void> clearAllShiftData() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kSummaries);
    await sp.remove(_kSupervisorInbox);
  }
}
