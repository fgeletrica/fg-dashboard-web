import 'package:flutter/material.dart';
import '../../industrial/services/industrial_store.dart';
import '../../../core/app_theme.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});
  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final _q = TextEditingController();
  String _filter = '';

  final Map<String, List<String>> _trees = {
    'Motor não parte': [
      '1) Confere LOTO/segurança e permissivos (portas, E-Stop, chaves).',
      '2) Confere tensão de comando (24V) e potência (3F).',
      '3) Contator/relé térmico: bobina energiza? contato colado? térmico desarmado?',
      '4) Proteções: disjuntor/motor-protector, fusível, falha de rede.',
      '5) Sinal do PLC: saída acionando? intertravamento ativo?',
    ],
    'Inversor em falha': [
      '1) Lê código de falha e registra.',
      '2) Mede tensão de entrada, aperto de bornes, aterramento.',
      '3) Confere motor: curto/isolação (megômetro se disponível).',
      '4) Corrente de saída comparada com placa do motor.',
      '5) Reseta e testa: se volta na hora → provável carga mecânica/travamento.',
    ],
    'Sensor não detecta': [
      '1) Alimentação 24V ok? (mede no sensor).',
      '2) Tipo PNP/NPN e ligação correta no I/O.',
      '3) LED de comutação acende? Se não, limpeza/alinhamento.',
      '4) Teste rápido: aproxima alvo / muda refletor / troca por sensor reserva.',
      '5) Entrada no PLC muda? Se não, cabo/borne/módulo I/O.',
    ],
    'Esteira parando do nada': [
      '1) Verifica E-Stop/intertravamentos e falhas intermitentes.',
      '2) Olha corrente/temperatura do motor (sobrecarga).',
      '3) Sensor de garrafa/palete bloqueando (sujeira/cola).',
      '4) Rede/PLC: perda de comunicação? alarmes na HMI?',
      '5) Vibração/cabo partido: mexe chicote e observa falha.',
    ],
  };

  @override
  void initState() {
    super.initState();
    _q.addListener(
        () => setState(() => _filter = _q.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys =
        _trees.keys.where((k) => k.toLowerCase().contains(_filter)).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: const Text('Diagnóstico por sintoma'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _q,
            decoration: InputDecoration(
              hintText: 'Buscar sintoma (ex: motor, sensor, inversor)...',
              filled: true,
              fillColor: AppTheme.card,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(.12))),
            ),
          ),
          const SizedBox(height: 14),
          ...keys.map((k) {
            final steps = _trees[k]!;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border.withOpacity(.35)),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                collapsedIconColor: Colors.white.withOpacity(.7),
                iconColor: Colors.white,
                title: Text(k,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900)),
                children: steps
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(.85),
                                      fontWeight: FontWeight.w900)),
                              Expanded(
                                  child: Text(s,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(.8),
                                          fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            );
          }),
          if (keys.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Nada encontrado. Tenta outra palavra.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
