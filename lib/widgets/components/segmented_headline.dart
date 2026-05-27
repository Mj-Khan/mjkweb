import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../models/site_config.dart';
import 'gradient_text.dart';

/// Renders a headline as a series of plain and gradient text segments inline.
///
/// Each [HeadlineSegment] with [gradient: false] renders in [style] (white),
/// each [gradient: true] segment gets the emerald→teal gradient treatment
/// via [GradientText]. Segments wrap naturally inside a [Wrap].
///
/// Falls back to a plain white [Text] if [segments] is empty.
class SegmentedHeadline extends StatelessWidget {
  final List<HeadlineSegment> segments;

  /// Base style applied to ALL segments. GradientText forces color to white
  /// internally, so you don't need to set color here.
  final TextStyle style;

  /// Fallback plain text when [segments] is empty.
  final String? fallbackText;

  /// The gradient to apply to gradient segments.
  final Gradient gradient;

  /// Max width fed into [GradientText.maxGradientWidth] for each gradient span.
  final double? maxGradientWidth;

  const SegmentedHeadline({
    super.key,
    required this.segments,
    required this.style,
    this.fallbackText,
    this.gradient = const LinearGradient(
      colors: [AppColors.accent, AppColors.accentSecondary],
    ),
    this.maxGradientWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback: no segments defined
    if (segments.isEmpty) {
      return Text(
        fallbackText ?? '',
        style: style.copyWith(color: AppColors.foregroundPrimary),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: segments.map((seg) {
        if (seg.gradient) {
          return GradientText(
            seg.text,
            style: style,
            gradient: gradient,
            maxGradientWidth: maxGradientWidth,
          );
        } else {
          return Text(
            seg.text,
            style: style.copyWith(color: AppColors.foregroundPrimary),
          );
        }
      }).toList(),
    );
  }
}
