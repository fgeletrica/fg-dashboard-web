import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDoc {
  String id;
  String name;
  String phone;
  String email;
  String address;
  String cpfCnpj;

  ClientDoc({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.cpfCnpj,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "cpfCnpj": cpfCnpj,
      };

  static ClientDoc fromJson(Map<String, dynamic> j) => ClientDoc(
        id: (j["id"] ?? "").toString(),
        name: (j["name"] ?? "").toString(),
        phone: (j["phone"] ?? "").toString(),
        email: (j["email"] ?? "").toString(),
        address: (j["address"] ?? "").toString(),
        cpfCnpj: (j["cpfCnpj"] ?? "").toString(),
      );
}

class ClientsStore {
  static const _k = "clients_v1";

  static Future<List<ClientDoc>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_k);
    if (raw == null || raw.trim().isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<dynamic>();
    return list
        .map((e) => ClientDoc.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  static Future<void> save(List<ClientDoc> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> upsert(ClientDoc c) async {
    final list = await load();
    final idx = list.indexWhere((x) => x.id == c.id);
    if (idx >= 0) {
      list[idx] = c;
    } else {
      list.insert(0, c);
    }
    await save(list);
  }

  static Future<void> delete(String id) async {
    final list = await load();
    list.removeWhere((x) => x.id == id);
    await save(list);
  }
}
