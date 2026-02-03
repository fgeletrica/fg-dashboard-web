import 'package:flutter/material.dart';
import '../services/marketplace_service.dart';

class ServiceFeedScreen extends StatefulWidget {
  const ServiceFeedScreen({super.key});

  @override
  State<ServiceFeedScreen> createState() => _ServiceFeedScreenState();
}

class _ServiceFeedScreenState extends State<ServiceFeedScreen> {
  final city = 'São Paulo';

  @override
  Widget build(BuildContext context) {
    final items = MarketplaceService.feed(city);

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos de serviço')),
      body: items.isEmpty
          ? const Center(child: Text('Nenhum pedido disponível'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final r = items[i];
                return Card(
                  child: ListTile(
                    title: Text(r.title),
                    subtitle: Text(r.description),
                    trailing: ElevatedButton(
                      child: const Text('Conversar'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chat (mock) aberto')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
