import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialDbItem {
  String name;
  String unit; // m, un, kg...
  double price;
  String
      icon; // 'cable','breaker','lamp','outlet','switch','pipe','box','build'

  MaterialDbItem({
    required this.name,
    required this.unit,
    required this.price,
    this.icon = 'build',
  });

  Map<String, dynamic> toJson() => {
        "name": name,
        "unit": unit,
        "price": price,
        "icon": icon,
      };

  static MaterialDbItem fromJson(Map<String, dynamic> j) => MaterialDbItem(
        name: (j["name"] ?? "").toString(),
        unit: (j["unit"] ?? "un").toString(),
        price: (j["price"] is num) ? (j["price"] as num).toDouble() : 0.0,
        icon: (j["icon"] ?? "build").toString(),
      );
}

class MaterialsStore {
  static const _k = 'materials_db_v1';

  // Lista base (aparece pro FREE ver e pro PRO usar como ponto de partida)
  static List<MaterialDbItem> seed() => [
        // === EXTRA_MATERIALS_START ===

        // Cabos flexíveis (metro)
        MaterialDbItem(
            name: 'Cabo flexível 1,5mm²',
            unit: 'm',
            price: 3.20,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo flexível 2,5mm²',
            unit: 'm',
            price: 4.50,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo flexível 4mm²', unit: 'm', price: 7.90, icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo flexível 6mm²', unit: 'm', price: 11.90, icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo flexível 10mm²',
            unit: 'm',
            price: 19.90,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo flexível 16mm²',
            unit: 'm',
            price: 29.90,
            icon: 'cable'),

        // Cabos rígidos (metro)
        MaterialDbItem(
            name: 'Cabo rígido 1,5mm²', unit: 'm', price: 2.80, icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo rígido 2,5mm²', unit: 'm', price: 3.90, icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo rígido 4mm²', unit: 'm', price: 6.90, icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo rígido 6mm²', unit: 'm', price: 10.90, icon: 'cable'),

        // Disjuntores (unidade) — genéricos
        MaterialDbItem(
            name: 'Disjuntor 10A', unit: 'un', price: 25.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 16A', unit: 'un', price: 26.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 20A', unit: 'un', price: 28.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 25A', unit: 'un', price: 30.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 32A', unit: 'un', price: 35.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 40A', unit: 'un', price: 39.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 50A', unit: 'un', price: 45.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 63A', unit: 'un', price: 55.00, icon: 'breaker'),

        // Disjuntores por marca (unidade)
        MaterialDbItem(
            name: 'Disjuntor Steck 20A',
            unit: 'un',
            price: 28.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor Steck 32A',
            unit: 'un',
            price: 34.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor Schneider 20A',
            unit: 'un',
            price: 39.90,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor Schneider 32A',
            unit: 'un',
            price: 49.90,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor Siemens 20A',
            unit: 'un',
            price: 42.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor Siemens 32A',
            unit: 'un',
            price: 52.00,
            icon: 'breaker'),

        // === EXTRA_MATERIALS_END ===

        MaterialDbItem(
            name: 'Cabo Flex 2,5mm²', unit: 'm', price: 4.50, icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo Flex 4mm²', unit: 'm', price: 7.90, icon: 'cable'),
        MaterialDbItem(
            name: 'Disjuntor 20A', unit: 'un', price: 28.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 32A', unit: 'un', price: 35.00, icon: 'breaker'),
        MaterialDbItem(
            name: 'Tomada 10A', unit: 'un', price: 12.00, icon: 'outlet'),
        MaterialDbItem(
            name: 'Tomada 20A', unit: 'un', price: 16.00, icon: 'outlet'),
        MaterialDbItem(
            name: 'Interruptor Simples',
            unit: 'un',
            price: 10.00,
            icon: 'switch'),
        MaterialDbItem(
            name: 'Lâmpada LED 9W', unit: 'un', price: 12.90, icon: 'lamp'),
        MaterialDbItem(
            name: 'Conduíte corrugado 20mm',
            unit: 'm',
            price: 2.50,
            icon: 'pipe'),
        MaterialDbItem(name: 'Caixa 4x2', unit: 'un', price: 3.50, icon: 'box'),

        // --- Cabos (mais bitolas) ---
        MaterialDbItem(
            name: 'Cabo Flex 1,5mm² (Sil)',
            unit: 'm',
            price: 3.20,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo Flex 2,5mm² (Prysmian)',
            unit: 'm',
            price: 5.10,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo Flex 4mm² (Sil)',
            unit: 'm',
            price: 7.80,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo Flex 6mm² (Prysmian)',
            unit: 'm',
            price: 11.90,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo Flex 10mm² (Sil)',
            unit: 'm',
            price: 19.90,
            icon: 'cable'),
        MaterialDbItem(
            name: 'Cabo Flex 16mm² (Prysmian)',
            unit: 'm',
            price: 31.90,
            icon: 'cable'),

        // --- Disjuntores (mais tipos / marcas) ---
        MaterialDbItem(
            name: 'Disjuntor 10A (Steck)',
            unit: 'un',
            price: 22.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 16A (Steck)',
            unit: 'un',
            price: 24.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 20A (Schneider)',
            unit: 'un',
            price: 39.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 25A (Schneider)',
            unit: 'un',
            price: 42.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 32A (Schneider)',
            unit: 'un',
            price: 49.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 40A (Schneider)',
            unit: 'un',
            price: 55.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 50A (Schneider)',
            unit: 'un',
            price: 69.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'Disjuntor 63A (Schneider)',
            unit: 'un',
            price: 79.00,
            icon: 'breaker'),

        // --- DR / DPS (bem comum em orçamento) ---
        MaterialDbItem(
            name: 'DR 25A 30mA (Schneider)',
            unit: 'un',
            price: 189.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'DR 40A 30mA (Schneider)',
            unit: 'un',
            price: 229.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'DPS Classe II 20kA (Clamper)',
            unit: 'un',
            price: 69.00,
            icon: 'breaker'),
        MaterialDbItem(
            name: 'DPS Classe II 40kA (Clamper)',
            unit: 'un',
            price: 109.00,
            icon: 'breaker'),

        // --- Conectores / Caixas extras ---
        MaterialDbItem(
            name: 'Conector WAGO 221 (3 vias)',
            unit: 'un',
            price: 6.50,
            icon: 'box'),
        MaterialDbItem(
            name: 'Conector WAGO 221 (5 vias)',
            unit: 'un',
            price: 9.50,
            icon: 'box'),
        MaterialDbItem(
            name: 'Caixa octogonal 4"', unit: 'un', price: 6.90, icon: 'box'),
        MaterialDbItem(
            name: 'Fita isolante 19mm', unit: 'un', price: 6.00, icon: 'build'),
      ];

  static Future<List<MaterialDbItem>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);

    // 1) Se vazio: auto-seed
    if (raw == null || raw.trim().isEmpty) {
      final seeded = seed();
      await save(seeded);
      return seeded;
    }

    // 2) Carrega DB
    List<MaterialDbItem> list;
    try {
      final decoded = (jsonDecode(raw) as List).cast<dynamic>();
      list = decoded
          .map((e) =>
              MaterialDbItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      list = [];
    }

    // 3) Mescla seed (não duplica por nome)
    final existing = {for (final it in list) it.name.toLowerCase().trim()};
    final add = <MaterialDbItem>[];
    for (final it in seed()) {
      final key = it.name.toLowerCase().trim();
      if (!existing.contains(key)) add.add(it);
    }

    if (add.isNotEmpty) {
      // adiciona no topo pra aparecer logo
      list = [...add, ...list];
      await save(list);
    }

    return list;
  }

  static Future<void> save(List<MaterialDbItem> items) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  static Future<void> add(MaterialDbItem item) async {
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

  // 🔄 Merge do seed no DB atual (não apaga nada, só adiciona o que não existe)
  static Future<int> mergeSeed() async {
    final cur = await load();
    final curNames = {for (final x in cur) x.name.trim().toLowerCase()};
    final add = <MaterialDbItem>[];

    for (final x in seed()) {
      final k = x.name.trim().toLowerCase();
      if (k.isEmpty) continue;
      if (!curNames.contains(k)) add.add(x);
    }

    if (add.isEmpty) return 0;
    // coloca os novos no topo
    final merged = [...add, ...cur];
    await save(merged);
    return add.length;
  }
}
