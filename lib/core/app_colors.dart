import 'package:flutter/material.dart';

/// Authoritative color tokens — Terminal Precision palette.
/// Values come from the token table; they override any Stitch CSS values that differ.
abstract final class AppColors {
  // ── Background ─────────────────────────────────────────────────────────────
  /// Base page background.
  static const Color backgroundBase = Color(0xFF131313);

  /// Vignette edge color (radial gradient corners, ~5% darker).
  static const Color backgroundVignette = Color(0xFF0E0E0E);

  // ── Surfaces (tonal elevation) ───────────────────────────────────────────
  static const Color surfaceLow = Color(0xFF1C1B1B);
  static const Color surface = Color(0xFF201F1F);
  static const Color surfaceHigh = Color(0xFF2A2A2A);
  static const Color surfaceHighest = Color(0xFF353534);

  // ── Foreground ───────────────────────────────────────────────────────────
  static const Color foregroundPrimary = Color(0xFFE5E2E1);
  static const Color foregroundMuted = Color(0xFFBDCAC0);
  static const Color foregroundSubtle = Color(0xFF87948B);

  // ── Accent ───────────────────────────────────────────────────────────────
  /// The ONE accent — Matrix Emerald. Use this only.
  static const Color accent = Color(0xFF6BDBAB);
  static const Color accentBright = Color(0xFF88F8C6);
  static const Color accentDim = Color(0xFF41B487);

  /// Text drawn on top of an accent-filled surface.
  static const Color onAccent = Color(0xFF003826);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color borderDefault = Color(0xFF3D4943);
  static const Color borderHover = Color(0xFF6BDBAB); // same as accent
  static const Color borderStrong = Color(0xFF87948B);

  // ── Scrim ────────────────────────────────────────────────────────────────
  /// Modal backdrop — use ONLY for modal-scrim. No other backdrop-blur / glass.
  static const Color modalScrim = Color.fromRGBO(8, 8, 8, 0.85);

  // ── Semantic helpers ─────────────────────────────────────────────────────
  /// Warm inline error color (form validation). NOT the accent.
  static const Color error = Color(0xFFFFB4AB);

  // ── Vignette decoration ──────────────────────────────────────────────────
  /// Subtle radial gradient applied to the page background (center → edges).
  /// Use as a [BoxDecoration] on the root container.
  static BoxDecoration get vignetteDecoration => const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            backgroundBase,       // #131313 at center
            backgroundVignette,   // #0E0E0E at ~5% darker at edges
          ],
          stops: [0.0, 1.0],
        ),
      );
}
