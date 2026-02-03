import '../models/material_catalog.dart';

class MaterialsCatalog {
  /// 🔓 FREE – básico e fixo
  static List<MaterialCatalog> basic() {
    return const [
      MaterialCatalog(
        id: 'fio_25',
        name: 'Fio 2,5 mm²',
        unit: 'm',
        price: 3.50,
        icon: '🧵',
      ),
      MaterialCatalog(
        id: 'fio_4',
        name: 'Fio 4 mm²',
        unit: 'm',
        price: 5.90,
        icon: '🧵',
      ),
      MaterialCatalog(
        id: 'disj_20',
        name: 'Disjuntor 20A',
        unit: 'un',
        price: 28.00,
        icon: '🔌',
      ),
      MaterialCatalog(
        id: 'tomada',
        name: 'Tomada 10A',
        unit: 'un',
        price: 12.00,
        icon: '🔲',
      ),
    ];
  }

  /// 💎 PRO – por enquanto igual ao FREE
  /// depois liberamos edição e salvar preço
  static List<MaterialCatalog> pro() {
    return [...basic()];
  }
}
