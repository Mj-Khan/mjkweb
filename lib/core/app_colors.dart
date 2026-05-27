import 'package:flutter/material.dart';

/// Authoritative color tokens — Terminal Precision palette.
/// Values come from the token table; they override any Stitch CSS values that differ.
abstract final class AppColors {
  // ── Background ─────────────────────────────────────────────────────────────
  /// Base page background — deep near-black canvas.
  static const Color backgroundBase = Color(0xFF0A0A0A);

  /// Vignette edge color (radial gradient corners, deeper than base).
  static const Color backgroundVignette = Color(0xFF060606);

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

  /// Secondary accent — Teal-Cyan. Used for gradient endpoints alongside [accent].
  /// Appears in: headline gradients, aurora background, gradient text.
  static const Color accentSecondary = Color(0xFF3FC9E0);

  /// Text drawn on top of an accent-filled surface.
  static const Color onAccent = Color(0xFF003826);

  // ── Accent-tinted surfaces ────────────────────────────────────────────────
  /// Dim emerald-tinted surface — e.g. timeline connector line.
  static const Color accentSurfaceLow = Color(0xFF2E3D35);

  /// Mid emerald-tinted surface — e.g. inactive timeline marker dot.
  static const Color accentSurfaceMid = Color(0xFF384C42);

  // ── Card sheen gradient stops ─────────────────────────────────────────────
  /// Top stop — light grazing the card surface (~0%). Brightest sheen peak.
  static const Color cardSheenTop = Color(0xFF2E2E2C);

  /// Mid stop — base card surface value (~28%). Clearly lighter than page bg.
  static const Color cardSheenMid = Color(0xFF272725);

  /// Bottom stop — shadow corner depth (~100%). Deepest surface tonal.
  static const Color cardSheenBase = Color(0xFF1E1E1C);

  // ── Decorative chrome dots (window title-bar mockup) ─────────────────────
  /// macOS-style close dot — soft red.
  static const Color chromeDotRed = Color(0xFFEF5350);

  /// macOS-style minimize dot — soft yellow/amber.
  static const Color chromeDotYellow = Color(0xFFFFCA28);

  /// macOS-style expand dot — soft green.
  static const Color chromeDotGreen = Color(0xFF9CCC65);

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
