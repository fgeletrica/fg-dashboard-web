import 'package:flutter/material.dart';
import 'test_utils.dart';
import 'test_result_model.dart';

class DrTestScreen extends StatefulWidget {
  const DrTestScreen({super.key});

  @override
  State<DrTestScreen> createState() => _DrTestScreenState();
}

class _DrTestScreenState extends State<DrTestScreen> {
  bool? _disparou;
  final _tempoCtrl = TextEditingController();
  TestResult? _result;

  void _avaliar() {
    if (_disparou == null) return;

    final tempo = double.tryParse(_tempoCtrl.text) ?? 0;

    final res = TestUtils.avaliarDR(
      disparou: _disparou!,
      tempoMs: tempo,
    );

    setState(() => _result = res);
  }

  Color _statusColor(String s) {
    if (s == 'OK') return Colors.green;
    if (s == 'ATENCAO') return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de DR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'O DR disparou ao pressionar o botão de teste?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RadioListTile<bool>(
              title: const Text('Sim'),
              value: true,
              groupValue: _disparou,
              onChanged: (v) => setState(() => _disparou = v),
            ),
            RadioListTile<bool>(
              title: const Text('Não'),
              value: false,
              groupValue: _disparou,
              onChanged: (v) => setState(() => _disparou = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tempoCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo de disparo (ms)',
                hintText: 'Ex: 180',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Avaliar teste'),
              onPressed: _avaliar,
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Text(
                _result!.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _result!.status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _statusColor(_result!.status),
                ),
              ),
              const SizedBox(height: 8),
              Text(_result!.description),
            ],
          ],
        ),
      ),
    );
  }
}
