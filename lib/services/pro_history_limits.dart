import '../models/budget_models.dart';

/// Regras simples:
/// - FREE: mostra só os últimos [freeLimit] itens (mais recentes)
/// - PRO: mostra tudo
class ProHistoryLimits {
  static const int freeLimit = 8;

  static List<BudgetDoc> apply(List<BudgetDoc> items, {required bool hasPro}) {
    if (hasPro) return items;
    if (items.length <= freeLimit) return items;
    // garante ordem por createdAt desc (mais novo primeiro)
    final sorted = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(freeLimit).toList();
  }

  static bool isLocked(List<BudgetDoc> items, {required bool hasPro}) {
    if (hasPro) return false;
    return items.length > freeLimit;
  }
}
