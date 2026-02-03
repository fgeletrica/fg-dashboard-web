class ServiceCatalogItem {
  final String id;
  final String name;
  final double price;
  final String icon;
  final bool proOnly;

  const ServiceCatalogItem({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    this.proOnly = false,
  });
}
