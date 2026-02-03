import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class CableTableScreen extends StatelessWidget {
  const CableTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = const [
      ["1,5 mm²", "15–18A", "Iluminação / tomadas leves"],
      ["2,5 mm²", "20–25A", "Tomadas gerais"],
      ["4 mm²", "28–32A", "Cargas médias"],
      ["6 mm²", "36–41A", "Chuveiro médio / ar"],
      ["10 mm²", "50–57A", "Chuveiro forte"],
      ["16 mm²", "68–76A", "Entrada / cargas altas"],
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text("Tabela de cabos (demo)"),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Referência rápida (ajustamos depois pela NBR)",
                    style: TextStyle(color: Colors.white.withOpacity(.8))),
                const SizedBox(height: 12),
                ...rows.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.20),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppTheme.border.withOpacity(.25)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(r[0],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900))),
                          Expanded(
                              child: Text(r[1],
                                  style: TextStyle(
                                      color: AppTheme.gold,
                                      fontWeight: FontWeight.w900))),
                          Expanded(
                              child: Text(r[2],
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.7)))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
