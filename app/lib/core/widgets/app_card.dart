import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppCardVariant { raised, inset }

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.radius = AppRadius.card,
    this.variant = AppCardVariant.raised,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final AppCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final raised = variant == AppCardVariant.raised;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: raised
              ? [palette.raisedStart, palette.raisedEnd]
              : [
                  Color.alphaBlend(
                    Colors.black.withValues(
                      alpha: palette.isDark ? 0.18 : 0.03,
                    ),
                    palette.surface2,
                  ),
                  palette.surface2,
                ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.borderSubtle),
        boxShadow: raised ? palette.raisedShadow : null,
      ),
      child: child,
    );
  }
}
