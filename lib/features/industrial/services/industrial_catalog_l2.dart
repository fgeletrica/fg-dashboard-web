class IndustrialCatalogL2 {
  static const lines = <String>['Linha 2'];

  static const Map<String, List<String>> machineGroups = {
    'PALETEIRAS': [
      'Transporte de Pallets - Linha 2',
      'Despaletização - Linha 2',
      'Despaletizadora - Robogrip',
      "Despaletizadora de Bulk's de Grf's",
      'Paletização - Linha 2',
      'Transporte de Caixas - Linha 2',
      "Desencaixamento de Grf's - Linha 2",
      'Desencaixotadora - Knickarm Roboter',
      'Lavagem de Caixas - Linha 2',
      'Encaixotamento - Linha 2',
    ],
    'ENVASE / ENCHEDORA L2': [
      'Enchedora Modulfill - L2',
      'Selecionador de tampas - L2',
      'Painel elétrico - Enchedora L2 - KI31A71',
      'Instrumentos Enchedora L2',
      'Cavitus - Enchedora L2',
      'Secador de ar comprimido - Enchedora L2',
      'Bateria de filtros entrada CO2',
      'Bateria de filtros entrada AR / N2',
      'Central de espuma Diversey',
    ],
    'CAPSULADOR / DESCAPSULADOR': [
      'Capsulador',
      'Descapsulador',
      'Elevador de Tampas - Linha 2'
    ],
    'PASTEURIZAÇÃO / UTILIDADES': [
      'Pasteurização - Linha 2',
      'Warmer - Linatherm (AQL0002)',
      'Trocador de calor - Linha 2',
      'Climatizadores e Insufladores - Linha 2',
      'Sistema Multistage - Linha 02',
      'Carbonatação - Linha 2',
    ],
    'ROTULAGEM / CODIFICAÇÃO': [
      'Rotulagem - Linha 2',
      'Codificação - Linha 2',
      'Envolvedora - Linha 2',
      'Etiquetagem - Linha 2',
    ],
    'INSPEÇÕES ELETRÔNICAS': [
      'Inspeções Eletrônicas - Linha 2',
    ],
    'TRANSPORTE DE GARRAFAS': [
      'Transporte de Garrafas - Linha 2',
    ],
    'LAVAGEM / RINSAGEM': [
      'Lavagem de Garrafas - Linha 2',
      'Lavadora de Garrafas (Linha 2)',
      'Rinsagem - Linha 2',
      'Rinser de Garrafas Usadas',
      'Rinser de Garrafas Novas',
      'Instrumentos Rinser L2',
    ],
    'DETECTOR DE MATÉRIA': [
      'Detector de matéria - Linha 2',
      'Aircotronic',
      'Módulo SAM',
      'Misturador de carbonato de sódio'
    ],
    'DISTRIBUIÇÃO / PAINÉIS': [
      'Painel Elétrico de Distribuição - Linha 2',
    ],
  };

  static List<String> groupNames() => machineGroups.keys.toList()..sort();

  static List<String> itemsForGroup(String group) {
    final items = machineGroups[group] ?? const <String>[];
    final list = List<String>.from(items);
    list.sort();
    return list;
  }
}
