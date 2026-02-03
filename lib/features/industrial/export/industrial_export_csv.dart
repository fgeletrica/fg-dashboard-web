import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class IndustrialExportCsv {
  static Future<File> export(List<Map<String, dynamic>> list) async {
    final rows = <List<String>>[
      [
        'data',
        'turno',
        'linha',
        'grupo',
        'maquina',
        'problema',
        'acao_tomada',
        'causa_raiz',
        'descricao_causa',
        'usuario'
      ]
    ];

    for (final d in list) {
      rows.add([
        (d['created_at'] ?? '').toString(),
        (d['shift'] ?? '').toString(),
        (d['line'] ?? '').toString(),
        (d['machine_group'] ?? '').toString(),
        (d['machine'] ?? '').toString(),
        (d['problem'] ?? '').toString(),
        (d['action_taken'] ?? '').toString(),
        (d['has_root_cause'] == true) ? 'SIM' : 'NAO',
        (d['root_cause'] ?? '').toString(),
        (d['created_by_name'] ?? '').toString(),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/DQX_industrial_$ts.csv');
    await file.writeAsString(csv, flush: true);
    return file;
  }
}
