import '../models/service_catalog.dart';

class ServicesCatalog {
  /// FREE — serviços simples e comuns
  static List<ServiceCatalogItem> basic() {
    return const [
      ServiceCatalogItem(
        id: 'inst_tomada',
        name: 'Instalação de tomada',
        price: 60,
        icon: '🔌',
      ),
      ServiceCatalogItem(
        id: 'inst_interruptor',
        name: 'Instalação de interruptor',
        price: 55,
        icon: '🔘',
      ),
      ServiceCatalogItem(
        id: 'inst_luminaria',
        name: 'Instalação de luminária',
        price: 120,
        icon: '💡',
      ),
      ServiceCatalogItem(
        id: 'inst_chuveiro',
        name: 'Instalação de chuveiro',
        price: 150,
        icon: '🚿',
      ),
    ];
  }

  /// PRO — serviços mais técnicos
  static List<ServiceCatalogItem> pro() {
    return [
      ...basic(),
      const ServiceCatalogItem(
        id: 'quadro_distrib',
        name: 'Montagem de quadro de distribuição',
        price: 450,
        icon: '📦',
        proOnly: true,
      ),
      const ServiceCatalogItem(
        id: 'padrao_entrada',
        name: 'Instalação padrão de entrada',
        price: 800,
        icon: '⚡',
        proOnly: true,
      ),
    ];
  }
}
