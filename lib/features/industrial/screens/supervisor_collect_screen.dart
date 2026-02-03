import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/app_theme.dart';
import '../models/shift_models.dart';
import '../services/shift_store.dart';

class SupervisorCollectScreen extends StatefulWidget {
  const SupervisorCollectScreen({super.key});

  @override
  State<SupervisorCollectScreen> createState() =>
      _SupervisorCollectScreenState();
}

class _SupervisorCollectScreenState extends State<SupervisorCollectScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = true;
  List<ShiftPackage> _packs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ShiftStore.listSupervisorPackages();
    if (!mounted) return;
    setState(() {
      _packs = list;
      _loading = false;
    });
  }

  Future<void> _addByCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    try {
      final pack = ShiftPackage.fromCode(code);
      await ShiftStore.addSupervisorPackage(pack);
      _codeCtrl.clear();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Turno coletado ✅')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Código inválido ❌')));
    }
  }

  Future<void> _clearAll() async {
    await ShiftStore.clearAllShiftData();
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Tudo apagado 🧹')));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ranking geral por pontos (somando por eletricista)
    final Map<String, int> score = {};
    for (final p in _packs) {
      final name = p.summary.techName.trim().isEmpty
          ? 'Eletricista'
          : p.summary.techName.trim();
      score[name] = (score[name] ?? 0) + p.summary.points;
    }
    final ranking = score.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Modo Supervisor'),
        actions: [
          IconButton(
            tooltip: 'Apagar tudo',
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_forever),
          )
        ],
      ),
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
                Text(
                    'Cole o código do turno do eletricista (pode vir do WhatsApp/QR leitor).',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.8),
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Código do turno (base64)'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _addByCode,
                    icon: const Icon(Icons.add),
                    label: const Text('Coletar turno'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    'Dica: use qualquer leitor QR no celular e copie o texto do QR.',
                    style: TextStyle(color: Colors.white.withOpacity(.6))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Ranking geral (soma de pontos)',
              style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (_loading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()))
          else if (ranking.isEmpty)
            Text('Ainda sem coletas.',
                style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontWeight: FontWeight.w700))
          else
            ...List.generate(ranking.length, (i) {
              final e = ranking[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border.withOpacity(.25)),
                ),
                child: Row(
                  children: [
                    Text('#${i + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(e.key,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900))),
                    Text('${e.value} pts',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontWeight: FontWeight.w900)),
                  ],
                ),
              );
            }),
          const SizedBox(height: 14),
          Text('Turnos coletados',
              style: TextStyle(
                  color: Colors.white.withOpacity(.9),
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (!_loading)
            ..._packs.take(30).map((p) {
              final dt = DateTime.fromMillisecondsSinceEpoch(p.summary.ts)
                  .toString()
                  .substring(0, 16);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border.withOpacity(.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p.summary.techName} • Turno ${p.summary.shift}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                        '$dt • Área: ${p.summary.area.isEmpty ? "—" : p.summary.area}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.7),
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                        'Linha parou: ${p.summary.lineStops} • Checklists: ${p.summary.checklistsDone} • Pontos: ${p.summary.points}',
                        style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontWeight: FontWeight.w800)),
                    if (p.summary.highlights.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Destaques: ${p.summary.highlights}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(.75),
                              fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
