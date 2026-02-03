import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        leading: const BackButton(),
      ),
      body: const Center(
        child: Text('Área de orçamentos (em desenvolvimento)'),
      ),
    );
  }
}
