import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Ambient background: two distinct smaller radial glow orbs matching the hero
/// gradient palette — emerald (#6BDBAB) upper-left and teal-cyan (#3FC9E0)
/// lower-center-right. Both drift slowly on independent paths, feathered to
/// transparent at edges. No particles, no blur filters — pure CustomPainter
/// radial gradients.
///
/// Reduced-motion: controller stops at mid-point static frame (both orbs at
/// their rest positions, no drift).
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26), // slow, barely-perceptible drift
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      _controller.stop();
      _controller.value = 0.5; // static mid-point frame
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _TwoOrbPainter(progress: _animation.value),
        );
      },
    );
  }
}

class _TwoOrbPainter extends CustomPainter {
  final double progress;

  _TwoOrbPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress; // 0.0 → 1.0 → 0.0 (reversed)

    // ── ORB 1 — Emerald (AppColors.accent) ──────────────────────────────────
    // Anchored: upper region, left-of-center (near hero headline).
    // Drift: gentle horizontal + slight vertical float, stays in upper-left zone.
    // Radius: ~38% of viewport width — a distinct pool, not a full-screen wash.
    final x1 = size.width * (0.22 + 0.07 * math.sin(t * 2 * math.pi));
    final y1 = size.height * 0.18 + 35.0 * math.cos(t * 2 * math.pi);
    final r1 = size.width * 0.38;

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accent.withValues(alpha: 0.22), // raised: clearly visible emerald pool
          AppColors.accent.withValues(alpha: 0.07),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x1, y1), radius: r1));
    canvas.drawCircle(Offset(x1, y1), r1, paint1);

    // ── ORB 2 — Teal-Cyan (AppColors.accentSecondary) ───────────────────────
    // Anchored: lower region, center-right (below mid-page, toward contact area).
    // Drift: independent phase (+ pi offset) so orbs move counter to each other,
    //        keeping separation and avoiding muddy overlap.
    // Radius: ~42% of viewport width — slightly larger, covers lower-right area.
    final x2 = size.width * (0.68 - 0.07 * math.cos(t * 2 * math.pi + math.pi));
    final y2 = size.height * 0.62 + 40.0 * math.sin(t * 2 * math.pi + math.pi);
    final r2 = size.width * 0.42;

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentSecondary.withValues(alpha: 0.28), // raised: teal needs more alpha to read
          AppColors.accentSecondary.withValues(alpha: 0.10), // visible mid feather
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x2, y2), radius: r2));
    canvas.drawCircle(Offset(x2, y2), r2, paint2);
  }

  @override
  bool shouldRepaint(covariant _TwoOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
