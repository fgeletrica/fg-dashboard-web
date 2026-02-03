class BudgetItem {
  final String nome;
  final double quantidade;
  final String unidade;
  double precoUnitario;

  BudgetItem({
    required this.nome,
    required this.quantidade,
    required this.unidade,
    this.precoUnitario = 0,
  });

  double get total => quantidade * precoUnitario;
}
