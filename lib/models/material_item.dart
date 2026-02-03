class MaterialItem {
  String nome;
  double quantidade;
  String unidade;
  double precoUnitario;

  MaterialItem({
    required this.nome,
    required this.quantidade,
    required this.unidade,
    required this.precoUnitario,
  });

  double get total => quantidade * precoUnitario;
}
