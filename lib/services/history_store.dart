import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryStore {
  static const _k = 'fg_history_v1';
  static const _kFav = 'fg_favs_v1';

  static Future<List<Map<String, dynamic>>> list() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k) ?? '[]';
    try {
      final j = jsonDecode(raw);
      if (j is List) return j.cast<Map<String, dynamic>>();
    } catch (_) {}
    return [];
  }

  static Future<void> add(Map<String, dynamic> item,
      {int maxItems = 30}) async {
    final sp = await SharedPreferences.getInstance();
    final all = await list();
    // remove duplicado por id se existir
    final id = (item['id'] ?? '').toString();
    all.removeWhere((e) => (e['id'] ?? '').toString() == id);
    all.insert(0, item);
    if (all.length > maxItems) all.removeRange(maxItems, all.length);
    await sp.setString(_k, jsonEncode(all));
  }

  static Future<List<String>> favIds() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_kFav) ?? <String>[];
  }

  static Future<bool> isFav(String id) async {
    final f = await favIds();
    return f.contains(id);
  }

  static Future<void> toggleFav(String id) async {
    final sp = await SharedPreferences.getInstance();
    final f = await favIds();
    if (f.contains(id)) {
      f.remove(id);
    } else {
      f.insert(0, id);
    }
    await sp.setStringList(_kFav, f);
  }

  static Future<List<Map<String, dynamic>>> favItems() async {
    final all = await list();
    final f = await favIds();
    final set = f.toSet();
    return all.where((e) => set.contains((e['id'] ?? '').toString())).toList();
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k);
    await sp.remove(_kFav);
  }
}
