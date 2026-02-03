import 'package:flutter/material.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ferramentas')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Tela de Ferramentas em manutenção.\n'
          'Se precisar, eu reconstruo ela igual estava (sem quebrar o projeto).',
        ),
      ),
    );
  }
}
