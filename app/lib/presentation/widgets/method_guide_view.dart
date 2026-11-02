import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/primary_button.dart';

class MethodGuideView extends StatelessWidget {
  const MethodGuideView({super.key, this.onContinue});

  final VoidCallback? onContinue;

  static const steps = [
    'Pilih apa yang mau kamu hafal.',
    'Jika sudah hafal, tandai "Sudah hafal".',
    'Jika belum hafal, tandai "Susah" (maksimal 20 kartu susah per sesi).',
    'Setelah menandai 20 kartu susah, pilih filter "Susah" supaya flashcard hanya menampilkan kartu yang susah.',
    'Hafalkan 20 kartu susah itu. Jika sudah hafal, tandai "Sudah hafal"; tanda "Susah" otomatis dilepas.',
    'Lakukan langkah ini berulang kali untuk kotoba yang belum hafal.',
    'Setelah semua hafal, ulangi semua hafalan untuk mengecek apakah ada yang lupa.',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        AppCard(
          variant: AppCardVariant.inset,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: palette.warning,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Jangan skip ini, ini method belajarnya.',
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == steps.length - 1 ? 0 : 16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(steps[i], style: textTheme.bodyMedium),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (onContinue != null) ...[
          const SizedBox(height: 20),
          PrimaryButton(onPressed: onContinue, label: 'Mengerti, lanjut'),
        ],
      ],
    );
  }
}
