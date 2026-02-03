import 'package:flutter/material.dart';

class ServiceCatalogItem {
  final String name;
  final double price;
  final IconData icon;
  const ServiceCatalogItem({
    required this.name,
    required this.price,
    required this.icon,
  });
}

// ✅ Catálogo BASE (FREE). Depois a gente coloca favoritos/editar preço/PRO.
const List<ServiceCatalogItem> serviceCatalog = <ServiceCatalogItem>[
  ServiceCatalogItem(
      name: 'Visita técnica', price: 50, icon: Icons.room_outlined),
  ServiceCatalogItem(
      name: 'Troca de tomada', price: 35, icon: Icons.power_outlined),
  ServiceCatalogItem(
      name: 'Troca de disjuntor',
      price: 90,
      icon: Icons.electrical_services_outlined),
  ServiceCatalogItem(
      name: 'Instalação de chuveiro', price: 120, icon: Icons.shower_outlined),
  ServiceCatalogItem(
      name: 'Instalação de ventilador', price: 150, icon: Icons.toys_outlined),
  ServiceCatalogItem(
      name: 'Ponto de luz (simples)', price: 80, icon: Icons.lightbulb_outline),
  ServiceCatalogItem(
      name: 'Passar fio (por metro)', price: 6, icon: Icons.cable_outlined),
  ServiceCatalogItem(
      name: 'Quadro: organização', price: 180, icon: Icons.dashboard_outlined),
  ServiceCatalogItem(
      name: 'Padrão/entrada (avaliar)',
      price: 250,
      icon: Icons.apartment_outlined),
];
