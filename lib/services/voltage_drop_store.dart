import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VoltageDropEntry {
  final String id;
  final int createdAtMs;

  final int voltage;
  final int phases; // 1 ou 3
  final double distanceM; // ida (m)
  final double powerW; // se usuário usar potência
  final double currentA; // se usuário usar corrente
  final double pf; // fator de potência
  final String material; // Cobre/Alumínio
  final double vdMaxPercent;

  final double sectionMm2;
  final double vdPercent;

  VoltageDropEntry({
    required this.id,
    required this.createdAtMs,
    required this.voltage,
    required this.phases,
    required this.distanceM,
    required this.powerW,
    required this.currentA,
    required this.pf,
    required this.material,
    required this.vdMaxPercent,
    required this.sectionMm2,
    required this.vdPercent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAtMs': createdAtMs,
        'voltage': voltage,
        'phases': phases,
        'distanceM': distanceM,
        'powerW': powerW,
        'currentA': currentA,
        'pf': pf,
        'material': material,
        'vdMaxPercent': vdMaxPercent,
        'sectionMm2': sectionMm2,
        'vdPercent': vdPercent,
      };

  static VoltageDropEntry fromJson(Map<String, dynamic> j) => VoltageDropEntry(
        id: (j['id'] ?? '').toString(),
        createdAtMs: (j['createdAtMs'] ?? 0) as int,
        voltage: (j['voltage'] ?? 220) as int,
        phases: (j['phases'] ?? 1) as int,
        distanceM: (j['distanceM'] ?? 0).toDouble(),
        powerW: (j['powerW'] ?? 0).toDouble(),
        currentA: (j['currentA'] ?? 0).toDouble(),
        pf: (j['pf'] ?? 1).toDouble(),
        material: (j['material'] ?? 'Cobre').toString(),
        vdMaxPercent: (j['vdMaxPercent'] ?? 4).toDouble(),
        sectionMm2: (j['sectionMm2'] ?? 2.5).toDouble(),
        vdPercent: (j['vdPercent'] ?? 0).toDouble(),
      );
}

class VoltageDropStore {
  static const _key = 'vd_history_v1';

  static Future<List<VoltageDropEntry>> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<dynamic>();
      final out = list
          .map((e) =>
              VoltageDropEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      out.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
      return out;
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(VoltageDropEntry e) async {
    final items = await load();
    items.removeWhere((x) => x.id == e.id);
    items.insert(0, e);
    // mantém no máximo 60 registros
    final trimmed = items.take(60).map((x) => x.toJson()).toList();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(trimmed));
  }

  static Future<void> remove(String id) async {
    final items = await load();
    final trimmed =
        items.where((x) => x.id != id).map((x) => x.toJson()).toList();
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(trimmed));
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
