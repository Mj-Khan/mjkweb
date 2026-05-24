import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Authoritative typography tokens — Terminal Precision.
/// All sizes and weights come from the token table; they override Stitch CSS.
///
/// Font families MUST match pubspec.yaml exactly:
///   - "Geist"          (400 / 600 / 700)
///   - "IBM Plex Mono"  (400 / 500)
abstract final class AppTypography {
  // ── Font family constants ─────────────────────────────────────────────────
  static const String _geist = 'Geist';
  static const String _mono = 'IBM Plex Mono';

  // ── Hero ─────────────────────────────────────────────────────────────────

  /// 80px desktop / 52px mobile · Geist 700 · lh 1.05 · -0.03em
  /// RULE: never render below 52px.
  static TextStyle heroHeadline({bool isMobile = false}) => TextStyle(
        fontFamily: _geist,
        fontSize: isMobile ? 52.0 : 80.0,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -0.03 * (isMobile ? 52.0 : 80.0),
        color: AppColors.foregroundPrimary,
      );

  // ── Section heading ───────────────────────────────────────────────────────

  /// 48px desktop / 34px mobile · Geist 600 · lh 1.10 · -0.02em
  static TextStyle sectionHeading({bool isMobile = false}) => TextStyle(
        fontFamily: _geist,
        fontSize: isMobile ? 34.0 : 48.0,
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: -0.02 * (isMobile ? 34.0 : 48.0),
        color: AppColors.foregroundPrimary,
      );

  // ── Subsection ────────────────────────────────────────────────────────────

  /// 28px · Geist 600 · lh 1.20
  static const TextStyle subsection = TextStyle(
    fontFamily: _geist,
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    height: 1.20,
    color: AppColors.foregroundPrimary,
  );

  // ── Card title ────────────────────────────────────────────────────────────

  /// 22px · Geist 600 · lh 1.30
  static const TextStyle cardTitle = TextStyle(
    fontFamily: _geist,
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 1.30,
    color: AppColors.foregroundPrimary,
  );

  // ── Modal title ───────────────────────────────────────────────────────────

  /// 40px desktop / 32px mobile · Geist 700 · lh 1.10
  static TextStyle modalTitle({bool isMobile = false}) => TextStyle(
        fontFamily: _geist,
        fontSize: isMobile ? 32.0 : 40.0,
        fontWeight: FontWeight.w700,
        height: 1.10,
        color: AppColors.foregroundPrimary,
      );

  // ── Body ──────────────────────────────────────────────────────────────────

  /// 18px · Geist 400 · lh 1.60
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _geist,
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 1.60,
    color: AppColors.foregroundPrimary,
  );

  /// 16px · Geist 400 · lh 1.60
  static const TextStyle body = TextStyle(
    fontFamily: _geist,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.60,
    color: AppColors.foregroundPrimary,
  );

  /// 14px · Geist 400 · lh 1.50
  static const TextStyle small = TextStyle(
    fontFamily: _geist,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.50,
    color: AppColors.foregroundPrimary,
  );

  // ── Mono (IBM Plex Mono) ──────────────────────────────────────────────────

  /// 12px · IBM Plex Mono 500 · 0.05em · UPPERCASE
  /// RULE: all uppercase labels must use this style.
  static const TextStyle monoLabel = TextStyle(
    fontFamily: _mono,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 12.0 * 0.05, // 0.05em converted to px
    color: AppColors.foregroundPrimary,
  );

  /// 13px · IBM Plex Mono 400
  static const TextStyle monoMeta = TextStyle(
    fontFamily: _mono,
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    color: AppColors.foregroundPrimary,
  );

  /// 40px · IBM Plex Mono 500 (metric numerals, hero count-up)
  static const TextStyle monoNumeral = TextStyle(
    fontFamily: _mono,
    fontSize: 40.0,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
  );

  /// 28px · IBM Plex Mono 500 (modal stats row)
  static const TextStyle monoStat = TextStyle(
    fontFamily: _mono,
    fontSize: 28.0,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
  );

  // ── Convenience colour-variant helpers ────────────────────────────────────

  /// Apply [color] to any base style without reconstructing it.
  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}
