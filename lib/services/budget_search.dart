import '../models/budget_models.dart';

class BudgetSearch {
  static List<BudgetDoc> byClient(List<BudgetDoc> list, String query) {
    return list
        .where((b) => b.clientName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<BudgetDoc> byMinValue(List<BudgetDoc> list, double min) {
    return list.where((b) => b.total >= min).toList();
  }
}
