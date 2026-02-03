import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_theme.dart';
import '../models/industrial_models.dart';
import '../services/industrial_store.dart';
import 'line_stop_history_screen.dart';

class LineStopScreen extends StatefulWidget {
  const LineStopScreen({super.key});

  @override
  State<LineStopScreen> createState() => _LineStopScreenState();
}

class _LineStopScreenState extends State<LineStopScreen> {
  int _step = 0;

  final _area = TextEditingController();
  final _machine = TextEditingController();
  final _symptom = TextEditingController();
  final _desc = TextEditingController();
  String _shift = 'A';

  final List<String> _tests = [];
  final _testCtrl = TextEditingController();

  final _cause = TextEditingController();
  final _action = TextEditingController();
  final _downtime = TextEditingController(); // min
  final _prev = TextEditingController();

  // ===== Cronômetro =====
  Timer? _ticker;
  int? _startMs; // quando começou
  int _elapsedSec = 0;

  bool get _running => _startMs != null;

  String _fmtElapsed() {
    final s = _elapsedSec;
    final m = s ~/ 60;
    final r = s % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(m)}:${two(r)}';
  }

  void _startTimer() {
    if (_running) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      _startMs = now;
      _elapsedSec = 0;
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startMs == null) return;
      final diff = DateTime.now().millisecondsSinceEpoch - _startMs!;
      setState(() => _elapsedSec = (diff / 1000).floor());
    });
  }

  void _stopTimer() {
    if (!_running) return;
    _ticker?.cancel();
    _ticker = null;

    // arredonda pra cima (1s vira 1min? não. 1..60s => 1min)
    final minutes = (_elapsedSec <= 0) ? 0 : ((_elapsedSec + 59) ~/ 60);

    setState(() {
      _startMs = null;
      _downtime.text = minutes.toString();
    });
  }

  void _resetTimer() {
    _ticker?.cancel();
    _ticker = null;
    setState(() {
      _startMs = null;
      _elapsedSec = 0;
    });
  }

  String _reportText(LineStopReport r) {
    final dt = DateTime.fromMillisecondsSinceEpoch(r.ts);
    final tests =
        r.testsDone.isEmpty ? '—' : r.testsDone.map((e) => '• $e').join('\n');
    return ''
        'FG Elétrica • LINHA PAROU 🚨\n'
        'Data: ${dt.toString()}\n'
        'Área: ${r.area}\n'
        'Máquina: ${r.machine}\n'
        'Turno: ${r.shift}\n'
        'Sintoma: ${r.symptom}\n\n'
        'Descrição:\n${r.description.isEmpty ? '—' : r.description}\n\n'
        'Testes realizados:\n$tests\n\n'
        'Causa provável:\n${r.probableCause.isEmpty ? '—' : r.probableCause}\n\n'
        'Ação tomada:\n${r.actionTaken.isEmpty ? '—' : r.actionTaken}\n\n'
        'Tempo parado (min): ${r.downtimeMin.isEmpty ? '—' : r.downtimeMin}\n\n'
        'Prevenção:\n${r.prevention.isEmpty ? '—' : r.prevention}\n';
  }

  bool _isValidInt(String s) {
    final t = s.trim();
    if (t.isEmpty) return false;
    final v = int.tryParse(t);
    return v != null && v >= 0 && v <= 1440;
  }

  Future<void> _save() async {
    // validações rápidas (pra virar padrão de fábrica)
    if (_area.text.trim().isEmpty ||
        _machine.text.trim().isEmpty ||
        _symptom.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha Área, Máquina e Sintoma.')),
      );
      return;
    }

    if (!_isValidInt(_downtime.text)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Informe o tempo parado em minutos (ex: 5).')),
      );
      return;
    }

    final r = LineStopReport(
      area: _area.text.trim(),
      machine: _machine.text.trim(),
      shift: _shift,
      symptom: _symptom.text.trim(),
      description: _desc.text.trim(),
      testsDone: List<String>.from(_tests),
      probableCause: _cause.text.trim(),
      actionTaken: _action.text.trim(),
      downtimeMin: _downtime.text.trim(),
      prevention: _prev.text.trim(),
    );

    await IndustrialStore.addLineStop(r);
    final txt = _reportText(r);

    if (!mounted) return;
    await Clipboard.setData(ClipboardData(text: txt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Relatório salvo e copiado 📋')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _area.dispose();
    _machine.dispose();
    _symptom.dispose();
    _desc.dispose();
    _testCtrl.dispose();
    _cause.dispose();
    _action.dispose();
    _downtime.dispose();
    _prev.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = <Step>[
      Step(
        title: const Text('Contexto'),
        isActive: _step >= 0,
        content: Column(
          children: [
            TextField(
              controller: _area,
              decoration: const InputDecoration(
                labelText: 'Área (ex: Enchedora, Rotuladora...)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _machine,
              decoration: const InputDecoration(
                labelText: 'Máquina/Linha (ex: Rotuladora, Enchedora...)',
              ),
            ),
            const SizedBox(height: 10),
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
              controller: _symptom,
              decoration: const InputDecoration(labelText: 'Sintoma (o que aconteceu)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _desc,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Descrição (detalhes)'),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Testes'),
        isActive: _step >= 1,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _testCtrl,
              decoration: const InputDecoration(
                labelText: 'Adicionar teste realizado (ex: reset, sensor limpo...)',
              ),
              onSubmitted: (v) {
                final t = v.trim();
                if (t.isEmpty) return;
                setState(() {
                  _tests.add(t);
                  _testCtrl.clear();
                });
              },
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tests
                  .map((t) => Chip(
                        label: Text(t),
                        onDeleted: () => setState(() => _tests.remove(t)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                final t = _testCtrl.text.trim();
                if (t.isEmpty) return;
                setState(() {
                  _tests.add(t);
                  _testCtrl.clear();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Conclusão'),
        isActive: _step >= 2,
        content: Column(
          children: [
            TextField(
              controller: _cause,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Causa provável (se souber)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _action,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ação tomada'),
            ),
            const SizedBox(height: 12),

            // ===== Cronômetro UI =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border.withOpacity(.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cronômetro de parada',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _fmtElapsed(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!_running)
                        ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Iniciar'),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _stopTimer,
                          icon: const Icon(Icons.stop),
                          label: const Text('Parar'),
                        ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: _resetTimer,
                        child: const Text('Zerar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _downtime,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tempo parado (min) — obrigatório',
                      hintText: 'Ex: 5',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _prev,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Prevenção (o que evitar no futuro)'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Salvar e copiar relatório'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LineStopHistoryScreen()),
                );
              },
              child: const Text('Ver histórico de paradas'),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Linha Parou'),
      ),
      body: Stepper(
        currentStep: _step,
        steps: steps,
        onStepContinue: () {
          if (_step < steps.length - 1) setState(() => _step += 1);
        },
        onStepCancel: () {
          if (_step > 0) setState(() => _step -= 1);
        },
        controlsBuilder: (context, details) {
          return Row(
            children: [
              if (_step > 0)
                TextButton(onPressed: details.onStepCancel, child: const Text('Voltar')),
              const Spacer(),
              if (_step < steps.length - 1)
                ElevatedButton(onPressed: details.onStepContinue, child: const Text('Próximo')),
            ],
          );
        },
      ),
    );
  }
}
