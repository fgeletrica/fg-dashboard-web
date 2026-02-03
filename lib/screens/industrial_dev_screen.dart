import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class IndustrialDevScreen extends StatelessWidget {
  const IndustrialDevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.industrial);
    });
    return const SizedBox.shrink();
  }
}
