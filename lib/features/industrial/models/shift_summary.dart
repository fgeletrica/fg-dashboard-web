import 'dart:convert';

class ShiftCloseSummary {
  final String id;
  final int ts;
  final String shift;
  final int totalStops;
  final int downtimeMin;
  final String topMachine;
  final String topCause;

  ShiftCloseSummary({
    required this.id,
    required this.ts,
    required this.shift,
    required this.totalStops,
    required this.downtimeMin,
    required this.topMachine,
    required this.topCause,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ts': ts,
        'shift': shift,
        'totalStops': totalStops,
        'downtimeMin': downtimeMin,
        'topMachine': topMachine,
        'topCause': topCause,
      };

  String toJson() => jsonEncode(toMap());

  static ShiftCloseSummary fromJson(String s) =>
      ShiftCloseSummary.fromMap(jsonDecode(s));

  static ShiftCloseSummary fromMap(Map<String, dynamic> m) => ShiftCloseSummary(
        id: m['id'],
        ts: m['ts'],
        shift: m['shift'],
        totalStops: m['totalStops'],
        downtimeMin: m['downtimeMin'],
        topMachine: m['topMachine'],
        topCause: m['topCause'],
      );
}
