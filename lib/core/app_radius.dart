import 'package:flutter/material.dart';

/// Authoritative radius tokens — Terminal Precision.
/// Values come from the token table.
abstract final class AppRadius {
  // ── Raw radius values ──────────────────────────────────────────────────────
  /// Buttons and input fields: 8px
  static const double radiusButton = 8.0;

  /// Cards, tiles, modals: 16px
  static const double radiusCard = 16.0;

  /// Status pills / tech-stack pills: 6px
  static const double radiusPill = 6.0;

  /// Accent dots, status pips, sharp decorative elements: 0px
  static const double radiusAccentDot = 0.0;

  // ── BorderRadius shortcuts ──────────────────────────────────────────────
  static BorderRadius get button =>
      BorderRadius.circular(radiusButton);

  static BorderRadius get card =>
      BorderRadius.circular(radiusCard);

  static BorderRadius get pill =>
      BorderRadius.circular(radiusPill);

  static BorderRadius get accentDot =>
      BorderRadius.circular(radiusAccentDot);

  // ── Convenience: Radius objects (for ClipRRect etc.) ────────────────────
  static Radius get buttonRadius => const Radius.circular(radiusButton);
  static Radius get cardRadius   => const Radius.circular(radiusCard);
  static Radius get pillRadius   => const Radius.circular(radiusPill);
  static Radius get dotRadius    => const Radius.circular(radiusAccentDot);
}
