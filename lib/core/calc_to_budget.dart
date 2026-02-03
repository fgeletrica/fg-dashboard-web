import 'electrical_calc.dart';
import 'budget_item.dart';

class CalcToBudget {
  static List<BudgetItem> gerar({
    required ElectricalResult r,
    required double distancia,
  }) {
    return [
      BudgetItem(
        nome: 'Cabo flex cobre ${r.bitola.toStringAsFixed(1)} mm²',
        quantidade: distancia * 2,
        unidade: 'm',
      ),
      BudgetItem(
        nome: 'Disjuntor ${r.disjuntor} A',
        quantidade: 1,
        unidade: 'un',
      ),
      BudgetItem(
        nome: 'DR 30mA',
        quantidade: 1,
        unidade: 'un',
      ),
      BudgetItem(
        nome: 'DPS Classe II',
        quantidade: 1,
        unidade: 'un',
      ),
    ];
  }
}
