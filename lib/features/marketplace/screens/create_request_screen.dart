import 'package:flutter/material.dart';
import '../services/marketplace_service.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo pedido')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Serviço'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                MarketplaceService.addRequest(
                  titleCtrl.text,
                  descCtrl.text,
                  'São Paulo',
                );
                Navigator.pop(context);
              },
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}
