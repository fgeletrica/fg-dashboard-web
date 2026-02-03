import 'package:flutter/material.dart';
import '../services/pro_guard.dart';

class ProLockTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onProTap;

  const ProLockTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
    required this.onProTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ProGuard.hasPro(),
      builder: (context, snap) {
        final isPro = snap.data == true;

        return ListTile(
          leading: Icon(
            isPro ? icon : Icons.lock,
            color: isPro ? null : Colors.orange,
          ),
          title: Text(title),
          subtitle: !isPro
              ? const Text('Recurso PRO')
              : (subtitle.isNotEmpty ? Text(subtitle) : null),
          trailing: !isPro
              ? const Icon(Icons.chevron_right, color: Colors.orange)
              : null,
          onTap: () {
            ProGuard.requirePro(context, onProTap);
          },
        );
      },
    );
  }
}
