import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_models.dart';

class BudgetStore {
  static const _kBudgets = 'budgets_v1';
  static const _kMaterialsDb = 'materials_db_v1';

  static Future<List<BudgetDoc>> loadBudgets() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kBudgets);
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => BudgetDoc.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  static Future<void> saveBudgets(List<BudgetDoc> budgets) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _kBudgets, jsonEncode(budgets.map((b) => b.toJson()).toList()));
  }

  static Future<void> upsert(BudgetDoc doc) async {
    final list = await loadBudgets();
    final idx = list.indexWhere((b) => b.id == doc.id);
    if (idx >= 0) {
      list[idx] = doc;
    } else {
      list.insert(0, doc);
    }
    await saveBudgets(list);
  }

  static Future<void> delete(String id) async {
    final list = await loadBudgets();
    list.removeWhere((b) => b.id == id);
    await saveBudgets(list);
  }

  // Materiais DB: [{name, unit, price}]
  static Future<List<Map<String, dynamic>>> loadMaterialsDb() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_kMaterialsDb);
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
  }

  static Future<void> saveMaterialsDb(List<Map<String, dynamic>> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kMaterialsDb, jsonEncode(items));
  }
}
