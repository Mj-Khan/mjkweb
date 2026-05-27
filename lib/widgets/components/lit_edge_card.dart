import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_radius.dart';

/// Two-tier card presence system.
///
/// [CardPresence.featured] — Hero cards (featured projects, active experience card):
///   - Highest surface contrast, brighter glass-rim edge highlight, emerald outer glow,
///     strong depth shadow. Most "lit glass" feel.
/// [CardPresence.standard] — Secondary cards (supporting projects, Now widget,
///   contact panels, direct-contact rows):
///   - Same solid surface + sheen, quieter rim highlight, no outer glow at rest.
///     Present and crafted, but visually calmer.
enum CardPresence { featured, standard }

/// Premium card wrapper — glass VIBE on a SOLID surface.
///
/// The "glass" read comes from two things, with NO transparency and NO blur:
///   1. EDGE HIGHLIGHT — bright near-white-emerald rim on the TOP-LEFT edge,
///      fading to a dark unlit bottom-right. The bright-vs-dark rim contrast
///      creates the glass-catching-light illusion.
///   2. SURFACE SHEEN — a subtle 3-stop gradient on the solid fill: very
///      slightly lighter at the top (light grazing the surface), settling to
///      the base value within the top ~25%, then deepening toward the bottom.
///
/// Cards are FULLY OPAQUE. Background does NOT bleed through. No BackdropFilter.
class LitEdgeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isHovered;
  final bool isActive;
  final bool isClickable;
  final CardPresence presence;
  final Matrix4? transform;

  const LitEdgeCard({
    super.key,
    required this.child,
    required this.padding,
    this.isHovered = false,
    this.isActive = false,
    this.isClickable = true,
    this.presence = CardPresence.standard,
    this.transform,
  });

  /// True when this card should render at the hero (Tier-1) level.
  bool get _isFeatured => isActive || presence == CardPresence.featured;

  @override
  Widget build(BuildContext context) {
    // ── BORDER GRADIENT — bright TL rim / dark BR ─────────────────────────────
    //
    // The TL stop is a crisp near-white-emerald: light catching the top-left
    // glass rim. The BR stop is the unlit underside. The contrast between them
    // is the primary glass cue.
    //
    // Border stops control:  [TL bright rim, mid, BR dark]
    // We use 3 stops for a fast falloff so the rim stays crisp, not diffuse.
    final Color rimColor;   // bright top-left glass highlight
    final Color midColor;   // gradient mid-point
    final Color baseColor;  // dark bottom-right (unlit side)

    if (isActive) {
      // Active experience card — full accent rim, intensifies on hover
      rimColor  = isHovered ? AppColors.accentBright : AppColors.accentBright.withValues(alpha: 0.85);
      midColor  = isHovered ? AppColors.accent.withValues(alpha: 0.55) : AppColors.accent.withValues(alpha: 0.40);
      baseColor = AppColors.borderDefault.withValues(alpha: 0.55);
    } else if (isHovered && isClickable) {
      // Any card on hover — accent rim
      rimColor  = AppColors.accentBright;
      midColor  = AppColors.accent.withValues(alpha: 0.45);
      baseColor = AppColors.borderDefault.withValues(alpha: 0.40);
    } else if (_isFeatured) {
      // Tier-1 at rest — clearly bright glass rim, noticeably lighter than BR
      rimColor  = AppColors.accentBright.withValues(alpha: 0.42);
      midColor  = AppColors.accentDim.withValues(alpha: 0.28);
      baseColor = AppColors.borderDefault.withValues(alpha: 0.40);
    } else {
      // Tier-2 at rest — visible but quieter rim, calmer glass feel
      rimColor  = AppColors.accentBright.withValues(alpha: 0.26);
      midColor  = AppColors.accentDim.withValues(alpha: 0.16);
      baseColor = AppColors.borderDefault.withValues(alpha: 0.32);
    }

    // ── LIFT ──────────────────────────────────────────────────────────────────
    final double liftY = isHovered && isClickable ? -2.0 : 0.0;

    // ── DEPTH SHADOWS — soft ambient lift off the dark page ───────────────────
    final List<BoxShadow> shadows = [];

    if (_isFeatured) {
      // Tier-1: strong dark ambient shadow + emerald outer glow halo
      shadows.add(BoxShadow(
        color: Colors.black.withValues(alpha: isHovered ? 0.40 : 0.32),
        blurRadius: isHovered ? 36 : 28,
        offset: Offset(0, isHovered ? 10 : 7),
      ));
      // Emerald outer glow: OUTSIDE the card (a halo), NOT a surface tint
      shadows.add(BoxShadow(
        color: AppColors.accent.withValues(
          alpha: isHovered ? 0.22 : (isActive ? 0.18 : 0.14),
        ),
        blurRadius: isHovered ? 24 : 18,
        spreadRadius: isHovered ? 1 : 0,
      ));
    } else {
      // Tier-2: lighter dark ambient shadow
      shadows.add(BoxShadow(
        color: Colors.black.withValues(alpha: isHovered ? 0.32 : 0.24),
        blurRadius: isHovered ? 28 : 22,
        offset: Offset(0, isHovered ? 8 : 5),
      ));
      // Tier-2 hover: brief faint glow flash
      if (isHovered && isClickable) {
        shadows.add(BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.10),
          blurRadius: 16,
          spreadRadius: 0,
        ));
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0.0, liftY, 0.0),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        // ── OUTER 1px SHELL — the glass rim gradient ──────────────────────────
        // Bright TL → mid → dark BR. The fast falloff (stops 0.0→0.25→1.0)
        // keeps the bright rim crisp rather than diffusing across the border.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [rimColor, midColor, baseColor],
          stops: const [0.0, 0.28, 1.0],
        ),
        boxShadow: shadows,
      ),
      padding: const EdgeInsets.all(1.0), // authoritative 1px border ring
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.card,
          // ── SOLID SURFACE SHEEN — fully opaque, no alpha, no blur ─────────
          // 3-stop vertical gradient simulating light grazing the top surface:
          //   top:    #2E2E2C — subtle sheen peak (brightest, top ~0%)
          //   25%:    #272725 — base card surface (clearly lighter than #131313)
          //   bottom: #1E1E1C — shadow corner depth
          // This reads as a polished solid surface, not transparent glass.
          // NO BackdropFilter, NO alpha channel on these colors.
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cardSheenTop,  // top sheen — light grazing the surface
              AppColors.cardSheenMid,  // base surface value
              AppColors.cardSheenBase, // deeper bottom — shadow corner
            ],
            stops: [0.0, 0.28, 1.0],
          ),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}
