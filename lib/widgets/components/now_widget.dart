import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../data/app_data.dart';
import 'lit_edge_card.dart';

/// The high-fidelity "/ now" module card.
/// Displays what the developer is currently up to, based on site_config.now values.
class NowWidget extends StatelessWidget {
  const NowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final nowConfig = appData.siteConfig.now;

    // Reading fallback for null values
    final readingValue = nowConfig.reading ?? '—';

    return LitEdgeCard(
      padding: const EdgeInsets.all(24.0),
      isClickable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Heading "/ now" ───────────────────────────────────────────────
          RichText(
            text: TextSpan(
              style: AppTypography.subsection,
              children: const [
                TextSpan(
                  text: '/ ',
                  style: TextStyle(color: AppColors.accent),
                ),
                TextSpan(text: 'now'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Data Rows ─────────────────────────────────────────────────────
          _buildNowRow('WORKING', nowConfig.working),
          const SizedBox(height: 20),
          _buildNowRow('LEARNING', nowConfig.learning),
          const SizedBox(height: 20),
          _buildNowRow('READING', readingValue),
          const SizedBox(height: 20),
          _buildNowRow('OPEN TO', nowConfig.openTo),
          const SizedBox(height: 32),

          // ── Bottom Comment ────────────────────────────────────────────────
          Text(
            '// last updated: ${nowConfig.lastUpdated}',
            style: AppTypography.monoMeta.copyWith(
              color: AppColors.foregroundSubtle,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.monoLabel.copyWith(
            fontSize: 9.0,
            color: AppColors.foregroundSubtle,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.withColor(
            AppTypography.body,
            AppColors.foregroundPrimary,
          ),
        ),
      ],
    );
  }
}
