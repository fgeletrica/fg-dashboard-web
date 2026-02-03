// === CÁLCULO SIMPLES DE ORÇAMENTO ===
double _maoDeObra(double totalMateriais) {
  return totalMateriais * 0.20; // 20%
}

double _totalGeral(double totalMateriais) {
  return totalMateriais + _maoDeObra(totalMateriais);
}
