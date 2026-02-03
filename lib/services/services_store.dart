import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceDbItem {
  String name;
  double price;

  ServiceDbItem({required this.name, required this.price});

  Map<String, dynamic> toJson() => {"name": name, "price": price};

  static ServiceDbItem fromJson(Map<String, dynamic> j) => ServiceDbItem(
        name: (j["name"] ?? "").toString(),
        price: (j["price"] ?? 0).toDouble(),
      );
}

class ServicesStore {
  static const _k = 'services_db_v1';

  static Future<List<ServiceDbItem>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => ServiceDbItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  static Future<void> save(List<ServiceDbItem> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> add(ServiceDbItem item) async {
    final list = await load();
    list.insert(0, item);
    await save(list);
  }

  static Future<void> removeAt(int i) async {
    final list = await load();
    if (i < 0 || i >= list.length) return;
    list.removeAt(i);
    await save(list);
  }
}
