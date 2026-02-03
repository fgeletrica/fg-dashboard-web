import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/fg_appbar.dart';

class SimplePage extends StatelessWidget {
  final String title;
  final String body;
  const SimplePage({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: FGAppBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(body,
                style: const TextStyle(color: AppTheme.muted, height: 1.35)),
          ),
        ),
      ),
    );
  }
}
