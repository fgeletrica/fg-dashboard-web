import 'package:flutter/material.dart';
import '../utils/money.dart';
import '../core/app_theme.dart';

class ToolsPlusScreen extends StatefulWidget {
  const ToolsPlusScreen({super.key});

  @override
  State<ToolsPlusScreen> createState() => _ToolsPlusScreenState();
}

class _ToolsPlusScreenState extends State<ToolsPlusScreen> {
  final _wCtrl = TextEditingController();
  final _vCtrl = TextEditingController(text: '220');
  String _res = '';

  @override
  void dispose() {
    _wCtrl.dispose();
    _vCtrl.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

  void _calcA() {
    final w = _d(_wCtrl);
    final v = _d(_vCtrl);
    if (w <= 0 || v <= 0) {
      setState(() => _res = 'Preencha W e V.');
      return;
    }
    final a = w / v;
    setState(() => _res = 'Corrente aproximada: ${a.toStringAsFixed(2)} A');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.bolt, color: AppTheme.gold, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Ferramentas+'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('W → A (monofásico)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _wCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: _dec('Potência (W)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _vCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: _dec('Tensão (V)'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _calcA,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: const Text('Calcular',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(_res,
                    style: TextStyle(color: Colors.white.withOpacity(.85))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AWG ⇄ mm² (tabela rápida)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '14 AWG ≈ 2,08 mm²\n'
                  '12 AWG ≈ 3,31 mm²\n'
                  '10 AWG ≈ 5,26 mm²\n'
                  '8 AWG ≈ 8,37 mm²\n'
                  '6 AWG ≈ 13,30 mm²\n'
                  '4 AWG ≈ 21,15 mm²\n',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.8), height: 1.25),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Curvas B/C/D (atalho)',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'B: resistivo/iluminação\n'
                  'C: uso geral (tomadas) — mais comum\n'
                  'D: motores/alta partida\n',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.8), height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: child,
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withOpacity(.75), fontWeight: FontWeight.w700),
        filled: true,
        fillColor: AppTheme.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.gold.withOpacity(.65))),
      );
}
