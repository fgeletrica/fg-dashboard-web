import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      bottom: 10,
      child: Text(
        'PRO',
        style: TextStyle(
          color: AppTheme.gold,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
