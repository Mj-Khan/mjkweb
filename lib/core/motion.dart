import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Authoritative motion helpers for the Terminal Precision Portfolio.
/// 
/// Respects reduced motion settings [MediaQuery.disableAnimationsOf(context)]
/// by bypassing animation effects and returning immediate final layout states.
class RevealAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;

  const RevealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      return child;
    }

    return child
        .animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: slideOffset / 100, // Normalized slide distance (0.2 for 20px)
          end: 0,
          delay: delay,
          duration: duration,
          curve: Curves.easeOut,
        );
  }
}

/// Helper that wraps children in staggered page-load animations.
/// 
/// Staggers children entrances sequentially by [interval] delay increments.
class StaggeredRevealList extends StatelessWidget {
  final List<Widget> children;
  final Duration initialDelay;
  final Duration interval;
  final Duration duration;
  final double slideOffset;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggeredRevealList({
    super.key,
    required this.children,
    this.initialDelay = Duration.zero,
    this.interval = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = 20.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: AnimateList(
        interval: interval,
        effects: [
          FadeEffect(
            delay: initialDelay,
            duration: duration,
            curve: Curves.easeOut,
          ),
          SlideEffect(
            begin: Offset(0, slideOffset / 100),
            end: Offset.zero,
            delay: initialDelay,
            duration: duration,
            curve: Curves.easeOut,
          ),
        ],
        children: children,
      ),
    );
  }
}
