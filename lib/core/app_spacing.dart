import 'package:flutter/material.dart';

/// Authoritative spacing tokens — base-4px grid.
/// All values come from the token table.
abstract final class AppSpacing {
  // ── Base scale ────────────────────────────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 40.0;
  static const double twoXl = 64.0;
  static const double threeXl = 120.0;

  // ── Layout ────────────────────────────────────────────────────────────────
  /// Max content width for the centred container.
  static const double containerMaxWidth = 1320.0;

  /// Desktop horizontal gutter (inside the container).
  static const double gutterDesktop = 32.0;

  /// Mobile horizontal gutter.
  static const double gutterMobile = 20.0;

  // ── Section padding (vertical) ────────────────────────────────────────────
  static const double sectionVerticalDesktop = 120.0;
  static const double sectionVerticalMobile = 88.0;

  // ── Card padding ──────────────────────────────────────────────────────────
  static const double cardPaddingDesktop = 32.0;
  static const double cardPaddingMobile = 20.0;

  // ── Modal padding ─────────────────────────────────────────────────────────
  static const double modalPaddingDesktop = 48.0;
  static const double modalPaddingMobile = 24.0;

  // ── Side rail / top bar ───────────────────────────────────────────────────
  static const double sideRailWidth = 220.0;
  static const double topBarHeight = 56.0;

  // ── Convenience EdgeInsets ────────────────────────────────────────────────

  static EdgeInsets sectionPadding({required bool isMobile}) => EdgeInsets.symmetric(
        vertical: isMobile ? sectionVerticalMobile : sectionVerticalDesktop,
        horizontal: isMobile ? gutterMobile : gutterDesktop,
      );

  static EdgeInsets cardPadding({required bool isMobile}) => EdgeInsets.all(
        isMobile ? cardPaddingMobile : cardPaddingDesktop,
      );

  static EdgeInsets modalPadding({required bool isMobile}) => EdgeInsets.all(
        isMobile ? modalPaddingMobile : modalPaddingDesktop,
      );
}
