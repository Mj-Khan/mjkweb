import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/motion.dart';
import '../../data/app_data.dart';
import '../../models/experience.dart';
import '../components/lit_edge_card.dart';
import '../components/scroll_reveal.dart';

/// High-fidelity, fully responsive Experience Section.
/// Shows stacked professional experience roles with a timeline rail on desktop,
/// dynamic expand/collapse toggles, and lit-edge cards.
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final experienceConfig = appData.siteConfig.experience;
    final isMobile = context.isMobile;
    final roles = appData.content.experience;

    return ScrollReveal(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderDefault,
              width: 1,
            ),
          ),
        ),
        padding: AppSpacing.sectionPadding(isMobile: isMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Section Title ─────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '// ${experienceConfig.heading.toUpperCase()}',
                  style: AppTypography.monoLabel.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  experienceConfig.subLine,
                  style: AppTypography.sectionHeading(isMobile: isMobile),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // ── Stacked Experience Cards ──────────────────────────────────────
            StaggeredRevealList(
              initialDelay: Duration.zero,
              interval: const Duration(milliseconds: 40),
              children: List.generate(roles.length, (idx) {
                final role = roles[idx];
                final card = ExperienceCard(
                  role: role,
                  isTimelineMode: !isMobile,
                );

                if (isMobile) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: card,
                  );
                }

                return DesktopTimelineRow(
                  card: card,
                  dateText: '${role.startDate} — ${role.endDate ?? "Present"}',
                  isCurrent: role.isPresent,
                  isFirst: idx == 0,
                  isLast: idx == roles.length - 1,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// A desktop vertical timeline row separating date column, rail with dot, and card.
class DesktopTimelineRow extends StatelessWidget {
  final Widget card;
  final String dateText;
  final bool isCurrent;
  final bool isFirst;
  final bool isLast;

  const DesktopTimelineRow({
    super.key,
    required this.card,
    required this.dateText,
    required this.isCurrent,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // Aligns the dot vertically with the first line of card content (header text)
    const double dotTopOffset = 38.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Date column (fixed 140px)
          SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.only(top: dotTopOffset - 6.0, right: 20.0),
              child: Text(
                dateText.toUpperCase(),
                textAlign: TextAlign.right,
                style: AppTypography.monoLabel.copyWith(
                  fontSize: 10,
                  color: isCurrent ? AppColors.accent : AppColors.foregroundSubtle,
                  letterSpacing: 1.0,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),

          // 2. Timeline rail column (fixed 40px)
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Thin dark emerald vertical line segment (#2E3D35)
                Positioned(
                  top: isFirst ? dotTopOffset : 0,
                  bottom: isLast ? null : 0,
                  height: isLast ? dotTopOffset : null,
                  width: 1.5,
                  child: Container(
                    color: AppColors.accentSurfaceLow,
                  ),
                ),
                // Timeline marker dot
                Positioned(
                  top: dotTopOffset - 8.0,
                  child: TimelineDot(isCurrent: isCurrent),
                ),
              ],
            ),
          ),

          // 3. Card column (flexible)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}

/// A timeline dot that pulses and glows for the current/live position.
class TimelineDot extends StatefulWidget {
  final bool isCurrent;

  const TimelineDot({
    super.key,
    required this.isCurrent,
  });

  @override
  State<TimelineDot> createState() => _TimelineDotState();
}

class _TimelineDotState extends State<TimelineDot> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isCurrent) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(
          parent: _pulseController!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pulseController != null) {
      final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (disableAnimations) {
        _pulseController!.stop();
        _pulseController!.value = 0.5;
      } else if (!_pulseController!.isAnimating) {
        _pulseController!.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCurrent) {
      // Dim older role marker
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accentSurfaceMid,
          shape: BoxShape.circle,
        ),
      );
    }

    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    // Glowing bright live dot
    final dotWidget = Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    // Pulse halo glow
    final glowWidget = Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
    );

    if (disableAnimations) {
      return Stack(
        alignment: Alignment.center,
        children: [
          glowWidget,
          dotWidget,
        ],
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _pulseAnimation!.value,
              child: glowWidget,
            ),
            dotWidget,
          ],
        );
      },
    );
  }
}

/// A single professional role card with rich hover states and expand/collapse triggers.
class ExperienceCard extends StatefulWidget {
  final ExperienceRole role;
  final bool isTimelineMode;

  const ExperienceCard({
    super.key,
    required this.role,
    this.isTimelineMode = false,
  });

  @override
  State<ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<ExperienceCard> {
  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final role = widget.role;
    final isMobile = context.isMobile;

    // Hover transitions over 200ms
    final dateColor = _isHovered ? AppColors.foregroundPrimary : AppColors.foregroundSubtle;

    // Date range formatting inside card (hidden on desktop timeline mode)
    final showDateInCard = !widget.isTimelineMode;
    final dateText = '${role.startDate} — ${role.endDate ?? "Present"}';
    final locationText = role.location ?? '';
    final infoString = (showDateInCard && locationText.isNotEmpty)
        ? '$dateText  •  $locationText'
        : showDateInCard
            ? dateText
            : locationText;

    // Expand/collapse logic details
    final showToggle = !role.isPresent && role.bullets.length > 2;
    final visibleBulletsCount = (_isExpanded || role.isPresent)
        ? role.bullets.length
        : 2;
    final remainingBulletsCount = role.bullets.length - 2;

    // Bullets list to render
    final visibleBullets = role.bullets.take(visibleBulletsCount).toList();

    final isDesktop = context.isDesktop;

    return MouseRegion(
      onEnter: (_) {
        if (isDesktop) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isDesktop) setState(() => _isHovered = false);
      },
      child: LitEdgeCard(
        padding: const EdgeInsets.all(28.0), // authoritative 28px padding
        isHovered: _isHovered,
        isActive: role.isPresent,
        isClickable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header (Desktop 1-row / Mobile stacked) ──────────────────────
            if (!isMobile)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Company + Role Tag
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            role.company,
                            style: AppTypography.cardTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: AppRadius.pill,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            role.title.toUpperCase(),
                            style: AppTypography.monoLabel.copyWith(
                              fontSize: 10,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right side: Location (intensifies on hover)
                  if (infoString.isNotEmpty)
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: AppTypography.monoMeta.copyWith(
                        color: dateColor,
                      ),
                      child: Text(infoString),
                    ),
                ],
              )
            else
              // Mobile Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    role.company,
                    style: AppTypography.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: AppRadius.pill,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      role.title.toUpperCase(),
                      style: AppTypography.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (infoString.isNotEmpty)
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: AppTypography.monoMeta.copyWith(
                        color: dateColor,
                        fontSize: 12.0,
                      ),
                      child: Text(infoString),
                    ),
                ],
              ),
            const SizedBox(height: 16),

            // ── Context Line ──────────────────────────────────────────────────
            if (role.contextLine != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  role.contextLine!,
                  style: AppTypography.withColor(
                    AppTypography.body,
                    AppColors.foregroundMuted,
                  ),
                ),
              ),

            // ── Bullets list (animated sizing reveal) ────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              curve: Curves.easeInOut,
              child: Container(
                key: ValueKey('role_bullets_${role.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(visibleBullets.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index < visibleBullets.length - 1 ? 12.0 : 0.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Terminal bullet prefix consistent with Step 3 modal
                          const Text(
                            '> ',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Mono',
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                              fontSize: 14.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              visibleBullets[index],
                              style: AppTypography.withColor(
                                AppTypography.body,
                                AppColors.foregroundPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            // ── Show More / Show Less Toggle button ──────────────────────────
            if (showToggle) ...[
              const SizedBox(height: 24),
              Center(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: _isHovered ? AppColors.accent : AppColors.borderDefault,
                          width: 1,
                        ),
                        borderRadius: AppRadius.button,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded
                                ? 'SHOW LESS'
                                : 'SHOW MORE ($remainingBulletsCount MORE)',
                            style: AppTypography.monoLabel.copyWith(
                              color: _isHovered ? AppColors.accent : AppColors.foregroundPrimary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 14,
                            color: _isHovered ? AppColors.accent : AppColors.foregroundPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
