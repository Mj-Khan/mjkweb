import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium, reusable text gradient wrapper using [ShaderMask].
///
/// Applies a smooth color gradient across a text block.
/// The child [Text] color is forced to [Colors.white] to ensure correct shader blending.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? maxGradientWidth;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    required this.gradient,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.maxGradientWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        // Fallback or cap the gradient width to ensure the gradient completes
        // its transition across the actual visible text span, preventing
        // flat colors caused by oversized parent layout bounds.
        final double textWidth = bounds.width > 0 ? bounds.width : 500.0;
        final double targetWidth = maxGradientWidth != null
            ? math.min(textWidth, maxGradientWidth!)
            : textWidth;

        return gradient.createShader(
          Rect.fromLTWH(0, 0, targetWidth, bounds.height > 0 ? bounds.height : 100.0),
        );
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
