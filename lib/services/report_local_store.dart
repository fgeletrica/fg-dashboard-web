import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReportLocalStore {
  static const String _keyReports = 'reports_items';

  static Future<List<Map<String, dynamic>>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyReports);
    if (raw == null || raw.trim().isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];

    return decoded
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  static Future<void> setReports(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReports, jsonEncode(items));
  }
}
