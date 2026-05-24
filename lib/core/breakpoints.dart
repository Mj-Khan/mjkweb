import 'package:flutter/material.dart';

/// Breakpoint constants and BuildContext extensions for responsive layout.
///
/// Breakpoints (token table — authoritative):
///   mobile  : width < 768
///   tablet  : 768 ≤ width ≤ 1024
///   desktop : width > 1024
abstract final class Breakpoints {
  static const double mobile = 768.0;
  static const double desktop = 1024.0;
}

/// Responsive helpers attached to [BuildContext].
extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.of(this).size.width;

  bool get isMobile  => _width < Breakpoints.mobile;
  bool get isTablet  => _width >= Breakpoints.mobile && _width <= Breakpoints.desktop;
  bool get isDesktop => _width > Breakpoints.desktop;

  /// Returns [mobile], [tablet], or [desktop] value based on current width.
  T responsive<T>({
    required T mobile,
    required T tablet,
    required T desktop,
  }) {
    if (isDesktop) return desktop;
    if (isTablet) return tablet;
    return mobile;
  }

  /// Shorthand: [mobile] for mobile/tablet, [desktop] for desktop.
  T responsiveSimple<T>({
    required T mobile,
    required T desktop,
  }) {
    return isDesktop ? desktop : mobile;
  }

  /// Returns true if the platform has a pointer (mouse/stylus).
  /// Used to conditionally enable hover effects.
  bool get hasPointer =>
      MediaQuery.of(this).navigationMode == NavigationMode.traditional;

  /// True if the user has requested reduced motion.
  bool get prefersReducedMotion => MediaQuery.of(this).disableAnimations;
}
