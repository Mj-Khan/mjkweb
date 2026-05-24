import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/motion.dart';
import '../../data/app_data.dart';
import '../../models/experience.dart';

/// High-fidelity, fully responsive Experience Section.
/// Shows stacked professional experience roles with dynamic expand/collapse toggles
/// and hover state transformations.
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final experienceConfig = appData.siteConfig.experience;
    final isMobile = context.isMobile;
    final roles = appData.content.experience;

    return Container(
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
          RevealAnimation(
            child: Column(
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
          ),
          const SizedBox(height: 48),

          // ── Stacked Experience Cards ──────────────────────────────────────
          StaggeredRevealList(
            initialDelay: Duration.zero,
            interval: const Duration(milliseconds: 40),
            children: roles.map((role) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ExperienceCard(role: role),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// A single professional role card with rich hover states and expand/collapse triggers.
class ExperienceCard extends StatefulWidget {
  final ExperienceRole role;

  const ExperienceCard({
    super.key,
    required this.role,
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

    // Hover transformations over 200ms
    final offset = _isHovered ? const Offset(0, -2.0) : Offset.zero;
    final borderColor = _isHovered ? AppColors.accent : AppColors.borderDefault;
    final dateColor = _isHovered ? AppColors.foregroundPrimary : AppColors.foregroundSubtle;

    // Date range formatting
    final dateText = '${role.startDate} — ${role.endDate ?? "Present"}';
    final locationText = role.location ?? '';
    final infoString = locationText.isNotEmpty ? '$dateText  •  $locationText' : dateText;

    // Expand/collapse logic details
    final showToggle = !role.isPresent && role.bullets.length > 2;
    final visibleBulletsCount = (_isExpanded || role.isPresent)
        ? role.bullets.length
        : 2;
    final remainingBulletsCount = role.bullets.length - 2;

    // Bullets list to render
    final visibleBullets = role.bullets.take(visibleBulletsCount).toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, offset.dy, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
          borderRadius: AppRadius.card,
        ),
        padding: const EdgeInsets.all(28.0), // authoritative 28px padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  // Right side: Dates & Location (intensifies on hover)
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
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
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
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
                    child: Container(
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
