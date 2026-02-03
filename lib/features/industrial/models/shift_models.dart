import 'dart:convert';

String _id() => DateTime.now().millisecondsSinceEpoch.toString();

class ShiftSummary {
  final String id;
  final int ts;
  final String techName; // nome do eletricista
  final String shift; // A/B/C/D
  final String area; // linha/área principal (texto livre)
  final int lineStops; // quantas “linha parou”
  final int checklistsDone; // checklists salvos
  final int points; // pontuação do turno
  final String highlights; // resumo livre

  ShiftSummary({
    String? id,
    int? ts,
    required this.techName,
    required this.shift,
    required this.area,
    required this.lineStops,
    required this.checklistsDone,
    required this.points,
    required this.highlights,
  })  : id = id ?? _id(),
        ts = ts ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'id': id,
        'ts': ts,
        'techName': techName,
        'shift': shift,
        'area': area,
        'lineStops': lineStops,
        'checklistsDone': checklistsDone,
        'points': points,
        'highlights': highlights,
      };

  static ShiftSummary fromMap(Map<String, dynamic> m) => ShiftSummary(
        id: (m['id'] ?? '').toString(),
        ts: int.tryParse((m['ts'] ?? '').toString()) ??
            DateTime.now().millisecondsSinceEpoch,
        techName: (m['techName'] ?? '').toString(),
        shift: (m['shift'] ?? '').toString(),
        area: (m['area'] ?? '').toString(),
        lineStops: int.tryParse((m['lineStops'] ?? '0').toString()) ?? 0,
        checklistsDone:
            int.tryParse((m['checklistsDone'] ?? '0').toString()) ?? 0,
        points: int.tryParse((m['points'] ?? '0').toString()) ?? 0,
        highlights: (m['highlights'] ?? '').toString(),
      );

  String toJson() => jsonEncode(toMap());
  static ShiftSummary fromJson(String s) =>
      fromMap(jsonDecode(s) as Map<String, dynamic>);
}

/// Pacote que o eletricista “entrega” pro supervisor (vira QR/código).
class ShiftPackage {
  final String version; // "v1"
  final ShiftSummary summary;
  final List<Map<String, dynamic>> lastLineStops; // resumo dos últimos eventos
  final List<Map<String, dynamic>>
      lastChecklists; // resumo dos últimos checklists

  ShiftPackage({
    this.version = 'v1',
    required this.summary,
    required this.lastLineStops,
    required this.lastChecklists,
  });

  Map<String, dynamic> toMap() => {
        'version': version,
        'summary': summary.toMap(),
        'lastLineStops': lastLineStops,
        'lastChecklists': lastChecklists,
      };

  static ShiftPackage fromMap(Map<String, dynamic> m) => ShiftPackage(
        version: (m['version'] ?? 'v1').toString(),
        summary:
            ShiftSummary.fromMap((m['summary'] as Map).cast<String, dynamic>()),
        lastLineStops: (m['lastLineStops'] is List)
            ? List<Map<String, dynamic>>.from(m['lastLineStops'])
            : <Map<String, dynamic>>[],
        lastChecklists: (m['lastChecklists'] is List)
            ? List<Map<String, dynamic>>.from(m['lastChecklists'])
            : <Map<String, dynamic>>[],
      );

  /// Texto curto pra colar (base64) — perfeito pra WhatsApp/QR.
  String toCode() {
    final jsonStr = jsonEncode(toMap());
    final bytes = utf8.encode(jsonStr);
    return base64UrlEncode(bytes);
  }

  static ShiftPackage fromCode(String code) {
    final bytes = base64Url.decode(code.trim());
    final jsonStr = utf8.decode(bytes);
    return fromMap(jsonDecode(jsonStr) as Map<String, dynamic>);
  }
}
