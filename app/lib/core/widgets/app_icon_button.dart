import 'package:flutter/material.dart';

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
    final foreground = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        icon: Icon(icon),
        color: filled ? Theme.of(context).colorScheme.onPrimary : foreground,
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: filled
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
