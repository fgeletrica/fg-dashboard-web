import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../models/industrial_models.dart';

class IndustrialExport {
  static String _csvEsc(String s) {
    final v = s.replaceAll('"', '""');
    return '"$v"';
  }

  static int _toInt(String s) {
    final t = s.trim().replaceAll(',', '.');
    final n = double.tryParse(t);
    if (n == null) return 0;
    return n.round();
  }

  static Future<Directory> _bestDir() async {
    try {
      final d = await getDownloadsDirectory();
      if (d != null) return d;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  static Future<File> exportLineStopsCsv(List<LineStopReport> list,
      {String filePrefix = 'linha_parou'}) async {
    final dir = await _bestDir();
    final now = DateTime.now();
    final name =
        '${filePrefix}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.csv';
    final file = File('${dir.path}/$name');

    final header = [
      'id',
      'timestamp',
      'data',
      'area',
      'maquina',
      'turno',
      'sintoma',
      'descricao',
      'testes',
      'causa_probavel',
      'acao_tomada',
      'tempo_parado_min',
      'prevencao',
    ];

    final lines = <String>[];
    lines.add(header.join(';'));

    for (final r in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
      final tests = r.testsDone.join(' | ');
      lines.add([
        _csvEsc(r.id),
        _csvEsc(r.ts.toString()),
        _csvEsc(dt.toString()),
        _csvEsc(r.area),
        _csvEsc(r.machine),
        _csvEsc(r.shift),
        _csvEsc(r.symptom),
        _csvEsc(r.description),
        _csvEsc(tests),
        _csvEsc(r.probableCause),
        _csvEsc(r.actionTaken),
        _csvEsc(_toInt(r.downtimeMin).toString()),
        _csvEsc(r.prevention),
      ].join(';'));
    }

    await file.writeAsString(lines.join('\n'));
    return file;
  }

  static Future<File> exportChecklistsCsv(List<ChecklistRun> list,
      {String filePrefix = 'checklists'}) async {
    final dir = await _bestDir();
    final now = DateTime.now();
    final name =
        '${filePrefix}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.csv';
    final file = File('${dir.path}/$name');

    final header = [
      'id',
      'timestamp',
      'data',
      'checklist_id',
      'checklist_titulo',
      'turno',
      'itens_total',
      'itens_marcados',
      'itens_json',
    ];

    final lines = <String>[];
    lines.add(header.join(';'));

    for (final r in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
      final total = r.items.length;
      final done = r.items.values.where((v) => v).length;
      final items = r.items.entries
          .map((e) => '${e.key}=${e.value ? "1" : "0"}')
          .join('|');
      lines.add([
        _csvEsc(r.id),
        _csvEsc(r.ts.toString()),
        _csvEsc(dt.toString()),
        _csvEsc(r.checklistId),
        _csvEsc(r.checklistTitle),
        _csvEsc(r.shift),
        _csvEsc(total.toString()),
        _csvEsc(done.toString()),
        _csvEsc(items),
      ].join(';'));
    }

    await file.writeAsString(lines.join('\n'));
    return file;
  }

  static Future<void> openFile(File f) async {
    await OpenFilex.open(f.path);
  }

  static Future<void> shareFile(File f) async {
    await Share.shareXFiles([XFile(f.path)]);
  }
}
