import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: filled ? palette.primary : palette.surface3,
          shape: BoxShape.circle,
          border: Border.all(color: palette.borderSubtle),
          boxShadow: filled ? palette.primaryGlow : palette.raisedShadow,
        ),
        child: IconButton(
          onPressed: onPressed,
          tooltip: label,
          icon: Icon(icon),
          color: filled ? Colors.white : palette.textPrimary,
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }
}
