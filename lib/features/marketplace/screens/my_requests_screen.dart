import 'package:flutter/material.dart';
import '../services/marketplace_service.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final items = MarketplaceService.myRequests();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus pedidos')),
      body: ListView(
        children: items.map((r) {
          return Card(
            child: ListTile(
              title: Text(r.title),
              subtitle: Text(r.done ? 'Concluído' : r.description),
              trailing: r.done
                  ? const Icon(Icons.check, color: Colors.green)
                  : TextButton(
                      child: const Text('Concluir'),
                      onPressed: () {
                        MarketplaceService.markDone(r.id);
                        setState(() {});
                      },
                    ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
