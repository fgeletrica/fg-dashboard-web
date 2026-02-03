import 'industrial_catalog_l2.dart';

class IndustrialCatalog {
  // Linhas disponíveis no seletor
  static const lines = <String>[
    'Linha 1',
    'Linha 2',
    'Linha 3',
    'Linha 4',
    'Linha 5',
    'Linha 6',
  ];

  /// Retorna os grupos por linha.
  /// Por enquanto (hardcoded), só Linha 2 tem grupos/máquinas (como você pediu).
  static List<String> groupNamesForLine(String line) {
    if (line.trim() == 'Linha 2') {
      return IndustrialCatalogL2.groupNames();
    }
    // placeholder (evita ficar vazio)
    return <String>['GERAL'];
  }

  /// Retorna as máquinas (itens) por (linha, grupo).
  /// Se não tiver itens, a seleção final vira só o grupo.
  static List<String> itemsFor(String line, String group) {
    if (line.trim() == 'Linha 2') {
      return IndustrialCatalogL2.itemsForGroup(group);
    }
    return const <String>[];
  }

  /// Sugere o turno automaticamente pelo horário local.
  /// (Ajustamos depois se a Coca usa janela diferente.)
  static String shiftAuto(DateTime now) {
    final h = now.hour;
    if (h >= 6 && h < 14) return 'Manhã';
    if (h >= 14 && h < 22) return 'Tarde';
    return 'Noite';
  }
}
