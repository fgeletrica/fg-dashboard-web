import 'electrical_calc.dart';
import 'calc_to_budget.dart';
import 'budget_item.dart';

List<BudgetItem> gerarOrcamentoAutomatico({
  required double potencia,
  required double tensao,
  required double distancia,
  bool incluirConduite = true,
}) {
  final result = ElectricalCalc.calcular(
    potenciaW: potencia,
    tensaoV: tensao,
    distanciaM: distancia,
  );

  final itens = CalcToBudget.gerar(
    r: result,
    distancia: distancia,
  );

  if (incluirConduite) {
    itens.add(
      BudgetItem(
        nome: 'Conduíte corrugado',
        quantidade: distancia,
        unidade: 'm',
      ),
    );
  }

  return itens;
}
