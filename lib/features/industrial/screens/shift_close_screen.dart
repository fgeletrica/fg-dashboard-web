import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_theme.dart';
import '../models/shift_models.dart';
import '../services/shift_store.dart';
import '../services/industrial_store.dart';
import '../models/industrial_models.dart';

class ShiftCloseScreen extends StatefulWidget {
  const ShiftCloseScreen({super.key});

  @override
  State<ShiftCloseScreen> createState() => _ShiftCloseScreenState();
}

class _ShiftCloseScreenState extends State<ShiftCloseScreen> {
  final _area = TextEditingController(text: '');
  final _high = TextEditingController(text: '');
  String _shift = 'A';

  String _code = '';
  ShiftSummary? _summary;

  Future<String> _getTechName() async {
    final sp = await SharedPreferences.getInstance();
    // tenta reaproveitar chave comum que você já usa; se não existir, cai pra “Eletricista”
    final name =
        (sp.getString('user_name') ?? sp.getString('nome_usuario') ?? '')
            .trim();
    return name.isEmpty ? 'Eletricista' : name;
  }

  int _calcPoints({required int lineStops, required int checklistsDone}) {
    // pontuação simples mas “cara de sistema”
    // +20 por checklist (disciplina), +30 por fechamento de linha (registro)
    // (depois a gente refina com downtime, reincidência, etc)
    return (checklistsDone * 20) + (lineStops * 30);
  }

  Future<void> _generate() async {
    final tech = await _getTechName();

    final lineStops = await IndustrialStore.listLineStops(limit: 200);
    final checkRuns = await IndustrialStore.listChecklistRuns(limit: 300);

    final now = DateTime.now();

    // pega só os do “turno atual” por data (mesmo dia) — simples e útil
    bool sameDay(int ts) {
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }

    final todayStops = lineStops.where((e) => sameDay(e.ts)).toList();
    final todayChecks = checkRuns.where((e) => sameDay(e.ts)).toList();

    final pts = _calcPoints(
        lineStops: todayStops.length, checklistsDone: todayChecks.length);

    final sum = ShiftSummary(
      techName: tech,
      shift: _shift,
      area: _area.text.trim(),
      lineStops: todayStops.length,
      checklistsDone: todayChecks.length,
      points: pts,
      highlights: _high.text.trim(),
    );

    // pacotes resumidos (pra não ficar gigante)
    List<Map<String, dynamic>> stopsMini = todayStops.take(10).map((e) {
      return {
        'ts': e.ts,
        'area': e.area,
        'machine': e.machine,
        'shift': e.shift,
        'symptom': e.symptom,
        'downtimeMin': e.downtimeMin,
      };
    }).toList();

    List<Map<String, dynamic>> checksMini = todayChecks.take(10).map((e) {
      final done = e.items.values.where((v) => v).length;
      return {
        'ts': e.ts,
        'title': e.checklistTitle,
        'shift': e.shift,
        'done': '$done/${e.items.length}',
      };
    }).toList();

    final pack = ShiftPackage(
        summary: sum, lastLineStops: stopsMini, lastChecklists: checksMini);
    final code = pack.toCode();

    await ShiftStore.addSummary(sum);

    if (!mounted) return;
    setState(() {
      _summary = sum;
      _code = code;
    });
  }

  Future<void> _copy() async {
    if (_code.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _code));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Código copiado 📋')));
  }

  @override
  void dispose() {
    _area.dispose();
    _high.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
          backgroundColor: AppTheme.bg, title: const Text('Encerrar turno')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border.withOpacity(.35)),
            ),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _shift,
                  decoration: const InputDecoration(labelText: 'Turno'),
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('Turno A')),
                    DropdownMenuItem(value: 'B', child: Text('Turno B')),
                    DropdownMenuItem(value: 'C', child: Text('Turno C')),
                    DropdownMenuItem(value: 'D', child: Text('Turno D')),
                  ],
                  onChanged: (v) => setState(() => _shift = v ?? 'A'),
                ),
                const SizedBox(height: 10),
                TextField(
                    controller: _area,
                    decoration: const InputDecoration(
                        labelText: 'Área/Linha principal (texto livre)')),
                const SizedBox(height: 10),
                TextField(
                    controller: _high,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText:
                            'Destaques do turno (o que você quer que o supervisor veja)')),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _generate,
                    child: const Text('Gerar resumo + ranking'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (s != null) ...[
            _cardTitle('Resumo'),
            _kv('Eletricista', s.techName),
            _kv('Turno', s.shift),
            _kv('Área', s.area.isEmpty ? '—' : s.area),
            _kv('Linha parou', '${s.lineStops}'),
            _kv('Checklists', '${s.checklistsDone}'),
            _kv('Pontuação', '${s.points}'),
            if (s.highlights.trim().isNotEmpty) _kv('Destaques', s.highlights),
            const SizedBox(height: 14),
            _cardTitle('Código do turno (colar no modo supervisor)'),
            SelectableText(_code,
                style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _copy,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar código'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Dica: você pode gerar um QR com esse código (a gente liga depois com o pacote qr_flutter).',
              style: TextStyle(color: Colors.white.withOpacity(.6)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontWeight: FontWeight.w900)),
      );

  Widget _kv(String k, String v) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border.withOpacity(.25)),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(k,
                    style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                        fontWeight: FontWeight.w800))),
            const SizedBox(width: 10),
            Expanded(
                child: Text(v,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900))),
          ],
        ),
      );
}
