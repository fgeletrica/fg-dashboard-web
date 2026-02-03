class ServiceTemplate {
  final String id;
  final String title;
  final String description;
  final double priceSuggested;

  const ServiceTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.priceSuggested,
  });
}

class ServiceTemplates {
  // Ajusta esses preços depois do seu jeito.
  static const List<ServiceTemplate> residential = [
    ServiceTemplate(
      id: 'inst_tomada',
      title: 'Instalar tomada (simples)',
      description: 'Ponto novo ou troca • sem quebra pesada',
      priceSuggested: 80,
    ),
    ServiceTemplate(
      id: 'inst_interruptor',
      title: 'Instalar interruptor',
      description: 'Simples/duplo • troca/instalação',
      priceSuggested: 70,
    ),
    ServiceTemplate(
      id: 'chuveiro',
      title: 'Instalar chuveiro',
      description: 'Fixação + ligação + teste',
      priceSuggested: 120,
    ),
    ServiceTemplate(
      id: 'disjuntor',
      title: 'Troca de disjuntor',
      description: 'Trocar disjuntor no quadro + reaperto',
      priceSuggested: 90,
    ),
    ServiceTemplate(
      id: 'quadro_reaperto',
      title: 'Reaperto/organização de quadro',
      description: 'Aperto + identificação básica + teste',
      priceSuggested: 180,
    ),
    ServiceTemplate(
      id: 'circuito_novo',
      title: 'Circuito novo (tomadas/iluminação)',
      description: 'Lançamento + ligação + teste (sem drywall pesado)',
      priceSuggested: 250,
    ),
    ServiceTemplate(
      id: 'dr_dps',
      title: 'Instalar DR + DPS',
      description: 'Montagem no quadro + testes',
      priceSuggested: 320,
    ),
    ServiceTemplate(
      id: 'visita',
      title: 'Visita técnica',
      description: 'Avaliação + diagnóstico + orçamento',
      priceSuggested: 60,
    ),
  ];
}
