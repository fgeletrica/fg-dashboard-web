import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  static const tips = [
    {
      't': 'Como escolher disjuntor',
      'd':
          'Regra rápida: corrente do circuito + margem. Depois valida por método de instalação e NBR.'
    },
    {
      't': 'Queda de tensão',
      'd':
          'Quanto maior a distância e corrente, maior a queda. Ajuste bitola pra manter dentro do recomendado.'
    },
    {
      't': 'Aterramento',
      'd':
          'Use condutor de proteção adequado e garanta continuidade. Nunca “economize” no terra.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriais e Dicas'),
        leading: const BackButton(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: tips.length,
        separatorBuilder: (_, __) => const Divider(height: 10),
        itemBuilder: (_, i) {
          final it = tips[i];
          return ListTile(
            title: Text(it['t']!),
            subtitle:
                Text(it['d']!, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _TipDetail(title: it['t']!, body: it['d']!),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TipDetail extends StatelessWidget {
  final String title;
  final String body;
  const _TipDetail({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), leading: const BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(body, style: const TextStyle(height: 1.4, fontSize: 16)),
      ),
    );
  }
}
