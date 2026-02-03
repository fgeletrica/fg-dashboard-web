import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class FGAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const FGAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.gold),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2),
        child: Container(height: 2, color: AppTheme.gold.withOpacity(0.30)),
      ),
    );
  }
}
