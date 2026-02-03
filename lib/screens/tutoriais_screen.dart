import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class TutoriaisScreen extends StatefulWidget {
  const TutoriaisScreen({super.key});

  @override
  State<TutoriaisScreen> createState() => _TutoriaisScreenState();
}

class _TutoriaisScreenState extends State<TutoriaisScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  List<_Topic> get _topics => const [
        _Topic(
          'Como usar o app (fluxo rápido)',
          [
            'Equipamentos: toque em um item para preencher potência/tensão automaticamente.',
            'Cálculo Elétrico: preencha Potência, Tensão e Distância (o resto é opcional).',
            'Orçamento: adicione serviços/materiais, aplique margem e gere PDF.',
            'PDF: no FREE sai com marca d’água. No PRO sai limpo.',
            'Tutoriais: use esta tela para entender cada conceito técnico.',
          ],
          icon: Icons.route,
        ),
        _Topic(
          'Cálculo Elétrico (como usar)',
          [
            'Obrigatório: Potência (W), Tensão (127/220) e Distância (m).',
            'O app calcula Ib (corrente) e sugere cabo + disjuntor.',
            'Se a queda de tensão ficar acima do limite, o app aumenta a seção do cabo.',
            'Opcional: FP e rendimento (η) — útil para motores e ar-condicionado.',
          ],
          icon: Icons.calculate_outlined,
        ),
        _Topic(
          'O que significa cada resultado',
          [
            'Ib: corrente do circuito (A).',
            'Cabo (mm²): seção sugerida para suportar corrente e queda de tensão.',
            'Iz: capacidade de condução do cabo (referência).',
            'Disjuntor (A): proteção do circuito (deve ser compatível com o cabo).',
            'Queda de tensão (%): perda aproximada até a carga.',
          ],
          icon: Icons.analytics_outlined,
        ),
        _Topic(
          'DPS (Dispositivo de Proteção contra Surtos)',
          [
            'Protege contra surtos (raios indiretos, manobras na rede).',
            'Onde instalar: no QDC/entrada, o mais próximo possível do barramento.',
            'Precisa de aterramento bom: DPS sem terra não trabalha direito.',
            'DPS ideal: Classe I (quando aplicável), Classe II (quadros), Classe III (próximo ao equipamento).',
            'Use disjuntor/fusível de proteção do DPS conforme fabricante.',
            'Condutores do DPS curtos e diretos (evitar laços).',
          ],
          icon: Icons.flash_on_outlined,
        ),
        _Topic(
          'DR (Dispositivo Diferencial Residual)',
          [
            'Protege pessoas contra choque (fuga de corrente).',
            'O mais comum residencial: 30 mA.',
            'Instalação típica: após o disjuntor geral, alimentando circuitos.',
            'Evite misturar neutros depois do DR (neutros devem ser separados por DR).',
            'DR pode desarmar por fuga real, umidade, equipamento defeituoso ou neutro compartilhado.',
            'DR não substitui disjuntor: DR é diferencial; disjuntor é sobrecorrente/curto.',
          ],
          icon: Icons.health_and_safety_outlined,
        ),
        _Topic(
          'Aterramento (o básico que funciona)',
          [
            'Objetivo: segurança (choque) + melhor desempenho de DPS/DR.',
            'Use haste(s) + condutor de aterramento + barramento de terra.',
            'Conexões firmes e protegidas contra corrosão.',
            'Quanto menor a resistência de terra, melhor (especialmente para DPS).',
            'Interligue massas metálicas e carcaças ao terra.',
            'Sistema TT/TN: regras mudam; siga padrão local e concessionária quando aplicável.',
          ],
          icon: Icons.public,
        ),
        _Topic(
          'Disjuntor: curva B, C, D (resumo prático)',
          [
            'Curva B: cargas resistivas/iluminação (desarma mais rápido).',
            'Curva C: uso geral (tomadas e cargas comuns) — a mais usada.',
            'Curva D: motores/cargas com alta corrente de partida (evita disparo na partida).',
            'Dimensionamento: não é só corrente — tem cabo (Iz), instalação e curto-circuito.',
          ],
          icon: Icons.tune,
        ),
        _Topic(
          'Bitola do cabo: por que não é só corrente',
          [
            'Além da corrente, tem: queda de tensão, aquecimento, agrupamento, temperatura e método de instalação.',
            'Distância grande → queda de tensão aumenta → cabo pode subir.',
            'Vários cabos juntos em eletroduto → reduz capacidade (derating).',
            'O app usa regra prática; em casos críticos, faça projeto detalhado.',
          ],
          icon: Icons.cable,
        ),
        _Topic(
          'Queda de tensão (dica prática)',
          [
            'Quanto maior a distância e corrente, maior a queda.',
            'Motores/ar: queda alta pode prejudicar partida e vida útil.',
            'Se a queda estourar, aumente a seção do cabo ou reduza o comprimento.',
          ],
          icon: Icons.trending_down,
        ),
        _Topic(
          'Equipamentos (FREE e PRO)',
          [
            'Itens PRO aparecem com selo PRO.',
            'Ao tocar em um item, o app preenche potência/tensão no cálculo.',
            'BTU → W é aproximação: se souber a potência real, use a real.',
          ],
          icon: Icons.devices_other,
        ),
        _Topic(
          'Orçamento (como deixar profissional)',
          [
            'Preencha cliente e descreva serviços com clareza.',
            'Serviços PRO (IA): sugere valores comuns — você pode ajustar.',
            'Materiais: use “Aplicar preços” se tiver seu banco cadastrado.',
            'Margem: % para facilitar ou valor fixo quando for pacote.',
            'PDF: revise antes de enviar (condições, prazo, garantia).',
          ],
          icon: Icons.receipt_long_outlined,
        ),
        _Topic(
          'Boas práticas (cliente / Play Store)',
          [
            'Evite prometer “100%” sem revisão em campo.',
            'Inclua observação: app auxilia, não substitui projeto/ART.',
            'Use linguagem simples + detalhes técnicos quando necessário.',
          ],
          icon: Icons.verified_outlined,
        ),
      ];

  List<_Topic> _filtered() {
    final query = _q.text.trim().toLowerCase();
    if (query.isEmpty) return _topics;

    return _topics.where((t) {
      final inTitle = t.title.toLowerCase().contains(query);
      if (inTitle) return true;
      // busca também dentro das linhas
      for (final line in t.items) {
        if (line.toLowerCase().contains(query)) return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered();

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
            const Text('Tutoriais'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _intro(),
          const SizedBox(height: 12),
          TextField(
            controller: _q,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Buscar (ex: DPS, DR, aterramento, disjuntor...)',
              filled: true,
              fillColor: AppTheme.card,
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(.7)),
              suffixIcon: _q.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _q.clear();
                        setState(() {});
                      },
                      icon: Icon(Icons.close,
                          color: Colors.white.withOpacity(.7)),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppTheme.gold.withOpacity(.7)),
              ),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            _empty()
          else
            ...list.map((t) => _section(topic: t)),
        ],
      ),
    );
  }

  Widget _intro() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Text(
        'Aqui tem explicação de cada tela e conceitos técnicos.\n'
        'Use a busca pra achar “DPS”, “DR”, “Aterramento”, etc.',
        style: TextStyle(
          color: Colors.white.withOpacity(.85),
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _empty() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Text(
        'Nada encontrado. Tenta outra palavra.\nEx: "DPS", "DR", "aterramento", "curva C"...',
        style: TextStyle(color: Colors.white.withOpacity(.80), height: 1.25),
      ),
    );
  }

  Widget _section({required _Topic topic}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: AppTheme.gold,
        title: Row(
          children: [
            Icon(topic.icon ?? Icons.book_outlined,
                color: AppTheme.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                topic.title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: topic.items
            .map((t) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '• $t',
                    style: TextStyle(
                        color: Colors.white.withOpacity(.80), height: 1.25),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Topic {
  final String title;
  final List<String> items;
  final IconData? icon;
  const _Topic(this.title, this.items, {this.icon});
}
