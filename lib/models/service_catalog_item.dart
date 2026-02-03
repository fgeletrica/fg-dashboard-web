class ServiceCatalogItem {
  final String name;
  double price;
  bool favorite;

  ServiceCatalogItem({
    required this.name,
    required this.price,
    this.favorite = false,
  });
}
