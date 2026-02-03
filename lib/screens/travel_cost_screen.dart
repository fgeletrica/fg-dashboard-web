import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class TravelCostScreen extends StatefulWidget {
  const TravelCostScreen({super.key});

  @override
  State<TravelCostScreen> createState() => _TravelCostScreenState();
}

class _TravelCostScreenState extends State<TravelCostScreen> {
  final distCtrl = TextEditingController();
  final consCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  String res = "R\$ --,--";

  @override
  void dispose() {
    distCtrl.dispose();
    consCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  double _d(String s) => double.tryParse(s.replaceAll(",", ".").trim()) ?? 0.0;

  void calc() {
    final dist = _d(distCtrl.text);
    final cons = _d(consCtrl.text);
    final price = _d(priceCtrl.text);

    if (dist <= 0 || cons <= 0 || price <= 0) {
      setState(() => res = "R\$ --,--");
      return;
    }
    final litros = dist / cons;
    final total = litros * price;
    setState(() => res = "R\$ ${total.toStringAsFixed(2)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text("Cálculo de Deslocamento"),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.gold.withOpacity(.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Dica: O consumo (Km/L) é quantos km seu carro anda com 1 litro.\n"
                          "Consulte o manual, computador de bordo ou a etiqueta do INMETRO.\n"
                          "Carros populares costumam fazer entre 10 e 15 km/l.",
                          style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _boxField("Distância (Km):", distCtrl),
                const SizedBox(height: 10),
                _boxField("Consumo (Km/L):", consCtrl),
                const SizedBox(height: 10),
                _boxField("Preço Gasolina (R\$):", priceCtrl),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(.18),
                      foregroundColor: Colors.white.withOpacity(.85),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: calc,
                    child: const Text("Calcular Custo",
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.28),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border.withOpacity(.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Custo total do deslocamento:",
                          style: TextStyle(
                              color: Colors.white.withOpacity(.8),
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(res,
                          style: TextStyle(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.w900,
                              fontSize: 26)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxField(String label, TextEditingController c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(.9),
                    fontWeight: FontWeight.w800))),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          child: TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black.withOpacity(.18),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (_) => calc(),
          ),
        ),
      ],
    );
  }
}
