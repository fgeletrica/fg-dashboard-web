import 'dart:convert';

class TechnicalReportDoc {
  final String id;
  final DateTime createdAt;

  String title;
  String clientName;
  String address;
  String description;
  String findings;
  String recommendations;

  // dados opcionais (quando vier da tela de queda de tensão)
  double? voltageV;
  int? phases; // 1 ou 3
  double? powerW;
  double? currentA;
  double? lengthM;
  double? sectionMm2;
  double? vdPercent;
  double? vdVolts;

  TechnicalReportDoc({
    required this.id,
    required this.createdAt,
    this.title = 'Laudo Técnico',
    this.clientName = '',
    this.address = '',
    this.description = '',
    this.findings = '',
    this.recommendations = '',
    this.voltageV,
    this.phases,
    this.powerW,
    this.currentA,
    this.lengthM,
    this.sectionMm2,
    this.vdPercent,
    this.vdVolts,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'title': title,
        'clientName': clientName,
        'address': address,
        'description': description,
        'findings': findings,
        'recommendations': recommendations,
        'voltageV': voltageV,
        'phases': phases,
        'powerW': powerW,
        'currentA': currentA,
        'lengthM': lengthM,
        'sectionMm2': sectionMm2,
        'vdPercent': vdPercent,
        'vdVolts': vdVolts,
      };

  factory TechnicalReportDoc.fromMap(Map<String, dynamic> m) =>
      TechnicalReportDoc(
        id: (m['id'] ?? '').toString(),
        createdAt: DateTime.tryParse((m['createdAt'] ?? '').toString()) ??
            DateTime.now(),
        title: (m['title'] ?? 'Laudo Técnico').toString(),
        clientName: (m['clientName'] ?? '').toString(),
        address: (m['address'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        findings: (m['findings'] ?? '').toString(),
        recommendations: (m['recommendations'] ?? '').toString(),
        voltageV:
            (m['voltageV'] is num) ? (m['voltageV'] as num).toDouble() : null,
        phases: (m['phases'] is num) ? (m['phases'] as num).toInt() : null,
        powerW: (m['powerW'] is num) ? (m['powerW'] as num).toDouble() : null,
        currentA:
            (m['currentA'] is num) ? (m['currentA'] as num).toDouble() : null,
        lengthM:
            (m['lengthM'] is num) ? (m['lengthM'] as num).toDouble() : null,
        sectionMm2: (m['sectionMm2'] is num)
            ? (m['sectionMm2'] as num).toDouble()
            : null,
        vdPercent:
            (m['vdPercent'] is num) ? (m['vdPercent'] as num).toDouble() : null,
        vdVolts:
            (m['vdVolts'] is num) ? (m['vdVolts'] as num).toDouble() : null,
      );

  String toJson() => jsonEncode(toMap());
  factory TechnicalReportDoc.fromJson(String s) =>
      TechnicalReportDoc.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
