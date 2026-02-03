class OrcamentoItem {
  final String nome;
  final double quantidade;
  final String unidade;
  final double precoUnitario;

  OrcamentoItem({
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.precoUnitario,
  });

  double get total => quantidade * precoUnitario;
}

List<OrcamentoItem> gerarOrcamentoAutomatico({
  required double potencia,
  required double tensao,
  required double distancia,
}) {
  final corrente = potencia / tensao;

  // regras simples (não complica)
  final cabo = corrente <= 20 ? 'Cabo 2,5mm²' : 'Cabo 4mm²';
  final disjuntor = corrente <= 20 ? 'Disjuntor 20A' : 'Disjuntor 32A';

  return [
    OrcamentoItem(
      nome: cabo,
      quantidade: distancia,
      unidade: 'm',
      precoUnitario: corrente <= 20 ? 4.50 : 6.80,
    ),
    OrcamentoItem(
      nome: disjuntor,
      quantidade: 1,
      unidade: 'un',
      precoUnitario: corrente <= 20 ? 28.00 : 42.00,
    ),
  ];
}

// === Orçamento automático a partir do cálculo ===
Map<String, dynamic> gerarOrcamentoDoCalculo({
  required double potencia,
  required double tensao,
  required double corrente,
  required String cabo,
  required int disjuntor,
}) {
  return {
    "descricao": "Instalação elétrica ${potencia.toStringAsFixed(0)}W",
    "itens": [
      {
        "nome": "Cabo $cabo",
        "quantidade": 1,
        "unidade": "metro",
        "preco": 0,
      },
      {
        "nome": "Disjuntor $disjuntor A",
        "quantidade": 1,
        "unidade": "un",
        "preco": 0,
      },
    ],
  };
}
