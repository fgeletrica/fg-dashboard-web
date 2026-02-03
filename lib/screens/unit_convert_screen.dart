import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class UnitConvertScreen extends StatefulWidget {
  const UnitConvertScreen({super.key});

  @override
  State<UnitConvertScreen> createState() => _UnitConvertScreenState();
}

class _UnitConvertScreenState extends State<UnitConvertScreen> {
  final aCtrl = TextEditingController();
  String from = "mm²";
  String to = "AWG";
  String result = "—";

  @override
  void dispose() {
    aCtrl.dispose();
    super.dispose();
  }

  double _toDouble(String s) =>
      double.tryParse(s.replaceAll(",", ".").trim()) ?? 0.0;

  // Conversão simples (demo): mm² -> AWG aproximado por tabela
  String _mm2ToAwg(double mm2) {
    final table = <double, String>{
      0.5: "20",
      0.75: "18",
      1.0: "17",
      1.5: "15",
      2.5: "13",
      4.0: "11",
      6.0: "9",
      10.0: "7",
      16.0: "5",
      25.0: "3",
      35.0: "2",
      50.0: "0",
      70.0: "00",
      95.0: "000",
    };

    double best = table.keys.first;
    for (final k in table.keys) {
      if ((mm2 - k).abs() < (mm2 - best).abs()) best = k;
    }
    return "≈ AWG ${table[best]} (ref: ${best}mm²)";
  }

  void calc() {
    final v = _toDouble(aCtrl.text);
    if (v <= 0) {
      setState(() => result = "—");
      return;
    }
    if (from == "mm²" && to == "AWG") {
      setState(() => result = _mm2ToAwg(v));
      return;
    }
    setState(() => result = "Conversão ainda não implementada (demo).");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text("Conversão de unidades"),
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: from,
                        items: const [
                          DropdownMenuItem(value: "mm²", child: Text("mm²")),
                        ],
                        onChanged: (v) => setState(() => from = v ?? "mm²"),
                        decoration: const InputDecoration(labelText: "De"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: to,
                        items: const [
                          DropdownMenuItem(value: "AWG", child: Text("AWG")),
                        ],
                        onChanged: (v) => setState(() => to = v ?? "AWG"),
                        decoration: const InputDecoration(labelText: "Para"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Valor"),
                  onChanged: (_) => calc(),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.gold.withOpacity(.35)),
                  ),
                  child: Text(
                    "Resultado: $result",
                    style: TextStyle(
                        color: AppTheme.gold, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: calc,
                    child: const Text("Converter",
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
