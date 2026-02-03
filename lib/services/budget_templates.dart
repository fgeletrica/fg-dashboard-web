import '../models/budget_models.dart';

class BudgetTemplates {
  static BudgetDoc obraPadrao() {
    return BudgetDoc(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: '',
      createdAt: DateTime.now(),
      materials: [],
      services: [
        BudgetServiceLine(name: 'Mão de obra (obra padrão)', price: 150.0),
      ],
      marginPercent: true,
      marginValue: 0,
    );
  }

  static BudgetDoc manutencao() {
    return BudgetDoc(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: '',
      createdAt: DateTime.now(),
      materials: [],
      services: [
        BudgetServiceLine(name: 'Visita técnica / manutenção', price: 80.0),
      ],
      marginPercent: true,
      marginValue: 0,
    );
  }
}
