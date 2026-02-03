import 'package:flutter/material.dart';
import 'history_export_screen.dart';

/// Wrapper pra não existir 2 telas diferentes com o mesmo título.
/// Qualquer rota antiga que aponte pra IndustrialReportsScreen vai cair na tela nova.
class IndustrialReportsScreen extends StatelessWidget {
  const IndustrialReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryExportScreen();
  }
}
