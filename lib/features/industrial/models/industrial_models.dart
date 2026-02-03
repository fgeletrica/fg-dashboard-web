import 'dart:convert';

String _id() => DateTime.now().millisecondsSinceEpoch.toString();

class LineStopReport {
  final String id;
  final int ts;
  final String area;
  final String machine;
  final String shift; // A/B/C/D ou Manhã/Tarde/Noite
  final String symptom;
  final String description;
  final List<String> testsDone;
  final String probableCause;
  final String actionTaken;
  final String downtimeMin;
  final String prevention;

  LineStopReport({
    String? id,
    int? ts,
    this.area = '',
    this.machine = '',
    this.shift = '',
    this.symptom = '',
    this.description = '',
    List<String>? testsDone,
    this.probableCause = '',
    this.actionTaken = '',
    this.downtimeMin = '',
    this.prevention = '',
  })  : id = id ?? _id(),
        ts = ts ?? DateTime.now().millisecondsSinceEpoch,
        testsDone = testsDone ?? const [];

  LineStopReport copyWith({
    String? area,
    String? machine,
    String? shift,
    String? symptom,
    String? description,
    List<String>? testsDone,
    String? probableCause,
    String? actionTaken,
    String? downtimeMin,
    String? prevention,
  }) {
    return LineStopReport(
      id: id,
      ts: ts,
      area: area ?? this.area,
      machine: machine ?? this.machine,
      shift: shift ?? this.shift,
      symptom: symptom ?? this.symptom,
      description: description ?? this.description,
      testsDone: testsDone ?? this.testsDone,
      probableCause: probableCause ?? this.probableCause,
      actionTaken: actionTaken ?? this.actionTaken,
      downtimeMin: downtimeMin ?? this.downtimeMin,
      prevention: prevention ?? this.prevention,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'ts': ts,
        'area': area,
        'machine': machine,
        'shift': shift,
        'symptom': symptom,
        'description': description,
        'testsDone': testsDone,
        'probableCause': probableCause,
        'actionTaken': actionTaken,
        'downtimeMin': downtimeMin,
        'prevention': prevention,
      };

  static LineStopReport fromMap(Map<String, dynamic> m) => LineStopReport(
        id: (m['id'] ?? '').toString(),
        ts: int.tryParse((m['ts'] ?? '').toString()) ??
            DateTime.now().millisecondsSinceEpoch,
        area: (m['area'] ?? '').toString(),
        machine: (m['machine'] ?? '').toString(),
        shift: (m['shift'] ?? '').toString(),
        symptom: (m['symptom'] ?? '').toString(),
        description: (m['description'] ?? '').toString(),
        testsDone: (m['testsDone'] is List)
            ? List<String>.from(m['testsDone'])
            : <String>[],
        probableCause: (m['probableCause'] ?? '').toString(),
        actionTaken: (m['actionTaken'] ?? '').toString(),
        downtimeMin: (m['downtimeMin'] ?? '').toString(),
        prevention: (m['prevention'] ?? '').toString(),
      );

  String toJson() => jsonEncode(toMap());
  static LineStopReport fromJson(String s) =>
      fromMap(jsonDecode(s) as Map<String, dynamic>);
}

class KnowledgeItem {
  final String id;
  final int ts;
  final String title;
  final String tags; // texto livre "cola;palete;encoder"
  final String problem;
  final String fix;
  final String prevention;

  KnowledgeItem({
    String? id,
    int? ts,
    this.title = '',
    this.tags = '',
    this.problem = '',
    this.fix = '',
    this.prevention = '',
  })  : id = id ?? _id(),
        ts = ts ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'id': id,
        'ts': ts,
        'title': title,
        'tags': tags,
        'problem': problem,
        'fix': fix,
        'prevention': prevention,
      };

  static KnowledgeItem fromMap(Map<String, dynamic> m) => KnowledgeItem(
        id: (m['id'] ?? '').toString(),
        ts: int.tryParse((m['ts'] ?? '').toString()) ??
            DateTime.now().millisecondsSinceEpoch,
        title: (m['title'] ?? '').toString(),
        tags: (m['tags'] ?? '').toString(),
        problem: (m['problem'] ?? '').toString(),
        fix: (m['fix'] ?? '').toString(),
        prevention: (m['prevention'] ?? '').toString(),
      );
}

class ChecklistRun {
  final String id;
  final int ts;
  final String checklistId;
  final String checklistTitle;
  final String shift;
  final Map<String, bool> items; // texto -> marcado

  ChecklistRun({
    String? id,
    int? ts,
    required this.checklistId,
    required this.checklistTitle,
    required this.shift,
    required this.items,
  })  : id = id ?? _id(),
        ts = ts ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'id': id,
        'ts': ts,
        'checklistId': checklistId,
        'checklistTitle': checklistTitle,
        'shift': shift,
        'items': items,
      };

  static ChecklistRun fromMap(Map<String, dynamic> m) => ChecklistRun(
        id: (m['id'] ?? '').toString(),
        ts: int.tryParse((m['ts'] ?? '').toString()) ??
            DateTime.now().millisecondsSinceEpoch,
        checklistId: (m['checklistId'] ?? '').toString(),
        checklistTitle: (m['checklistTitle'] ?? '').toString(),
        shift: (m['shift'] ?? '').toString(),
        items: (m['items'] is Map)
            ? Map<String, bool>.from(m['items'])
            : <String, bool>{},
      );
}
