import 'package:flutter/material.dart';

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({super.key});

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  // Respostas (sim/não)
  bool qDisjuntorDesarma = false;
  bool qCheiroQueimado = false;
  bool qAquecimentoTomada = false;
  bool qPiscaLuz = false;
  bool qChoqueAoTocar = false;
  bool qQuedaTensao = false;

  int _scoreRisco() {
    int s = 0;
    if (qChoqueAoTocar) s += 4;
    if (qCheiroQueimado) s += 4;
    if (qAquecimentoTomada) s += 3;
    if (qDisjuntorDesarma) s += 2;
    if (qPiscaLuz) s += 2;
    if (qQuedaTensao) s += 2;
    return s;
  }

  String _nivel(int s) {
    if (s >= 8) return "ALTO";
    if (s >= 4) return "MÉDIO";
    return "BAIXO";
  }

  List<String> _acoes(int s) {
    final a = <String>[];

    if (qChoqueAoTocar) {
      a.add(
          "⚠️ Suspeita de fuga/aterramento ruim: teste isolação, continuidade PE e DR.");
      a.add("✅ Recomenda: instalar/validar DR 30mA e revisar aterramento.");
    }
    if (qCheiroQueimado) {
      a.add(
          "⚠️ Possível sobreaquecimento/curto/contato ruim: desligar circuito e inspecionar conexões.");
      a.add("✅ Verificar aperto de bornes, emendas, disjuntor e barramentos.");
    }
    if (qAquecimentoTomada) {
      a.add("⚠️ Tomada aquecendo: contato frouxo ou sobrecarga.");
      a.add("✅ Trocar tomada, revisar bitola e disjuntor do circuito.");
    }
    if (qDisjuntorDesarma) {
      a.add(
          "⚠️ Disjuntor desarmando: sobrecarga, curto intermitente ou disjuntor subdimensionado.");
      a.add("✅ Medir corrente (alicate), revisar cargas e dimensionamento.");
    }
    if (qPiscaLuz) {
      a.add("⚠️ Pisca: mau contato/neutro solto/queda de tensão.");
      a.add("✅ Revisar conexões do neutro e emendas.");
    }
    if (qQuedaTensao) {
      a.add("⚠️ Queda de tensão: cabo longo/bitola baixa/conexões ruins.");
      a.add("✅ Calcular queda e ajustar bitola/rota.");
    }

    if (a.isEmpty) {
      a.add(
          "✅ Sem indícios fortes. Faça inspeção visual + teste básico de tensão e aperto de conexões.");
    }

    if (s >= 8) {
      a.insert(0,
          "🚨 Prioridade: desenergizar circuito suspeito e atuar com segurança.");
    }

    return a;
  }

  Widget _q(String text, bool v, void Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(text),
      value: v,
      onChanged: (b) => setState(() => onChanged(b)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = _scoreRisco();
    final nivel = _nivel(score);
    final acoes = _acoes(score);

    return Scaffold(
      appBar: AppBar(title: const Text("Diagnóstico guiado")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Responda rápido. No final eu te dou uma hipótese provável + checklist de ação.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _q("Disjuntor desarma sozinho?", qDisjuntorDesarma,
                    (b) => qDisjuntorDesarma = b),
                _q("Cheiro de queimado / aquecimento no quadro?",
                    qCheiroQueimado, (b) => qCheiroQueimado = b),
                _q("Tomada/plugue esquenta?", qAquecimentoTomada,
                    (b) => qAquecimentoTomada = b),
                _q("Luz piscando ou varia brilho?", qPiscaLuz,
                    (b) => qPiscaLuz = b),
                _q("Dá choque ao tocar carcaça/metais?", qChoqueAoTocar,
                    (b) => qChoqueAoTocar = b),
                _q("Sente queda de tensão (equipamento fraco)?", qQuedaTensao,
                    (b) => qQuedaTensao = b),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text("Risco: $nivel"),
              subtitle: Text("Pontuação: $score"),
              trailing: Icon(
                nivel == "ALTO"
                    ? Icons.warning_amber
                    : (nivel == "MÉDIO" ? Icons.report : Icons.check_circle),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Checklist sugerido",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...acoes.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(t),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.restart_alt),
            label: const Text("Zerar respostas"),
            onPressed: () {
              setState(() {
                qDisjuntorDesarma = false;
                qCheiroQueimado = false;
                qAquecimentoTomada = false;
                qPiscaLuz = false;
                qChoqueAoTocar = false;
                qQuedaTensao = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
