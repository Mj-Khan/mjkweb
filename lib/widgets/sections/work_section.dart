import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/icon_resolver.dart';
import '../../data/app_data.dart';
import '../../models/project.dart';
import '../components/lit_edge_card.dart';
import '../components/project_modal.dart';
import '../components/scroll_reveal.dart';

/// High-fidelity, fully responsive Work Section.
/// Shows featured projects in a responsive 2x2 grid, followed by an AnimatedSize-toggled
/// supporting grid for non-featured projects.
class WorkSection extends StatefulWidget {
  const WorkSection({super.key});

  @override
  State<WorkSection> createState() => _WorkSectionState();
}

class _WorkSectionState extends State<WorkSection> {
  bool _isExpanded = false;

  void _openProjectModal(BuildContext context, Project project) {
    if (project.isClickable) {
      ProjectModal.show(context, project);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final workConfig = appData.siteConfig.work;
    final isMobile = context.isMobile;

    final featured = appData.content.featuredProjects;
    final supporting = appData.content.supportingProjects;

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
            // ── Section Title block ───────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '// ${workConfig.heading.toUpperCase()}',
                  style: AppTypography.monoLabel.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  workConfig.subLine,
                  style: AppTypography.sectionHeading(isMobile: isMobile),
                ),
              ],
            ),
          const SizedBox(height: 48),

          // ── Featured Projects Grid (Coordination via Hover) ───────────────
          FeaturedGrid(
            projects: featured,
            onProjectTap: (p) => _openProjectModal(context, p),
          ),

          // ── Supporting Projects Toggle ────────────────────────────────────
          if (supporting.isNotEmpty) ...[
            const SizedBox(height: 40),
            const Divider(color: AppColors.borderDefault, thickness: 1, height: 1),
            const SizedBox(height: 32),
            Center(
              child: GhostToggleCTA(
                label: _isExpanded ? workConfig.showLessLabel : workConfig.showMoreLabel,
                isExpanded: _isExpanded,
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              alignment: Alignment.topCenter,
              curve: Curves.easeInOut,
              child: Container(
                key: const ValueKey('supporting_projects_animated_wrap'),
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: _buildSupportingGrid(
                          context,
                          supporting,
                          (p) => _openProjectModal(context, p),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }

  /// Builds a responsive supporting projects grid (3-col desktop, 2-col tablet, 1-col mobile)
  Widget _buildSupportingGrid(
    BuildContext context,
    List<Project> projects,
    ValueChanged<Project> onTap,
  ) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: projects
            .map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SupportingCard(project: p, onTap: () => onTap(p)),
                ))
            .toList(),
      );
    }

    final colCount = isTablet ? 2 : 3;
    final rows = <Widget>[];

    for (var i = 0; i < projects.length; i += colCount) {
      final rowItems = <Widget>[];
      for (var j = 0; j < colCount; j++) {
        if (i + j < projects.length) {
          rowItems.add(
            Expanded(
              child: SupportingCard(
                project: projects[i + j],
                onTap: () => onTap(projects[i + j]),
              ),
            ),
          );
        } else {
          rowItems.add(const Expanded(child: SizedBox.shrink()));
        }
        if (j < colCount - 1) {
          rowItems.add(const SizedBox(width: 20));
        }
      }
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowItems,
        ),
      );
      if (i + colCount < projects.length) {
        rows.add(const SizedBox(height: 20));
      }
    }

    return Column(children: rows);
  }
}

/// A wrapper grid managing coordinated hover state for 4 featured cards.
class FeaturedGrid extends StatefulWidget {
  final List<Project> projects;
  final ValueChanged<Project> onProjectTap;

  const FeaturedGrid({
    super.key,
    required this.projects,
    required this.onProjectTap,
  });

  @override
  State<FeaturedGrid> createState() => _FeaturedGridState();
}

class _FeaturedGridState extends State<FeaturedGrid> {
  String? _hoveredProjectId;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final projects = widget.projects;
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (isMobile) {
      // 1-column layout for mobile
      return Column(
        children: projects.asMap().entries.map((entry) {
          final idx = entry.key;
          final p = entry.value;
          Widget card = FeaturedCard(
            project: p,
            isDimmed: false,
            onHoverChanged: (_) {},
            onTap: () => widget.onProjectTap(p),
          );

          if (!disableAnimations) {
            card = card.animate(
              delay: Duration(milliseconds: idx * 80),
            ).fadeIn(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            ).slideY(
              begin: 0.05,
              end: 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: card,
          );
        }).toList(),
      );
    }

    // Desktop/Tablet 2-column flow (handles 2x2 perfectly without scroll nesting)
    final rows = <Widget>[];
    for (var i = 0; i < projects.length; i += 2) {
      final rowItems = <Widget>[];
      for (var j = 0; j < 2; j++) {
        final idx = i + j;
        if (idx < projects.length) {
          final p = projects[idx];
          final isDimmed = _hoveredProjectId != null && _hoveredProjectId != p.id;

          Widget card = FeaturedCard(
            project: p,
            isDimmed: isDimmed,
            onHoverChanged: (hovered) {
              setState(() {
                _hoveredProjectId = hovered ? p.id : null;
              });
            },
            onTap: () => widget.onProjectTap(p),
          );

          if (!disableAnimations) {
            card = card.animate(
              delay: Duration(milliseconds: idx * 80),
            ).fadeIn(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            ).slideY(
              begin: 0.05,
              end: 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }

          rowItems.add(
            Expanded(
              child: card,
            ),
          );
        } else {
          rowItems.add(const Expanded(child: SizedBox.shrink()));
        }
        if (j == 0) {
          rowItems.add(const SizedBox(width: 24));
        }
      }
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rowItems,
          ),
        ),
      );
      if (i + 2 < projects.length) {
        rows.add(const SizedBox(height: 24));
      }
    }

    return Column(
      children: rows,
    );
  }
}

/// Coordinated-hover, responsive Featured Project Card.
class FeaturedCard extends StatefulWidget {
  final Project project;
  final bool isDimmed;
  final ValueChanged<bool> onHoverChanged;
  final VoidCallback onTap;

  const FeaturedCard({
    super.key,
    required this.project,
    required this.isDimmed,
    required this.onHoverChanged,
    required this.onTap,
  });

  @override
  State<FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<FeaturedCard> {
  bool _isHovered = false;

  Widget _buildTechPills(List<String> tech) {
    final List<Widget> list = [];
    const limit = 4; // Display at most 4 pills before overflow
    final count = tech.length;

    for (var i = 0; i < (count > limit ? limit : count); i++) {
      list.add(_buildPill(tech[i].toUpperCase(), isAccent: false));
    }

    if (count > limit) {
      list.add(_buildPill('+${count - limit} MORE', isAccent: true));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: list,
    );
  }

  Widget _buildPill(String label, {required bool isAccent}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        border: Border.all(
          color: isAccent ? AppColors.accentDim : AppColors.borderDefault,
          width: 1.0,
        ),
        borderRadius: AppRadius.pill,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Text(
        label,
        style: AppTypography.monoLabel.copyWith(
          fontSize: 10,
          color: isAccent ? AppColors.accent : AppColors.foregroundSubtle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final project = widget.project;
    final isClickable = project.isClickable;
    final isMobile = context.isMobile;

    // Base opacity: 60% for details_pending, 100% for live projects
    final double baseOpacity = isClickable ? 1.0 : 0.6;
    // Dim other projects in grid on hover to 80% opacity
    final double finalOpacity = widget.isDimmed ? baseOpacity * 0.8 : baseOpacity;


    // Find icon
    final iconName = appData.siteConfig.projectIconMap[project.id] ?? 'circle_outlined';
    final iconData = IconResolver.iconFromName(iconName);

    // Format metadata installs/rating
    final meta = project.storeMetadata;
    final List<String> metaParts = [];
    if (meta != null) {
      if (meta.rating != null) metaParts.add('★ ${meta.rating}');
      if (meta.downloadsLabel != null) metaParts.add(meta.downloadsLabel!);
    }
    final metaText = metaParts.join('  •  ');

    final isDesktop = context.isDesktop;

    return MouseRegion(
      onEnter: (_) {
        if (isClickable && isDesktop) {
          setState(() => _isHovered = true);
          widget.onHoverChanged(true);
        }
      },
      onExit: (_) {
        if (isClickable && isDesktop) {
          setState(() => _isHovered = false);
          widget.onHoverChanged(false);
        }
      },
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: isClickable ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: finalOpacity,
          child: LitEdgeCard(
            padding: AppSpacing.cardPadding(isMobile: isMobile),
            presence: CardPresence.featured,
            isHovered: _isHovered,
            isClickable: isClickable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Icon and Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          iconData,
                          size: 24,
                          color: AppColors.accent,
                        ),
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
                            project.status.replaceAll('_', ' ').toUpperCase(),
                            style: AppTypography.monoLabel.copyWith(
                              fontSize: 9,
                              color: AppColors.foregroundMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Project Name
                    Text(
                      project.name,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 6),

                    // Tagline
                    if (project.tagline != null)
                      Text(
                        project.tagline!,
                        style: AppTypography.monoMeta.copyWith(
                          color: AppColors.foregroundMuted,
                          fontSize: 12.0,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Short description (only! no long_description)
                    Text(
                      project.shortDescription ?? 'Description pending.',
                      style: AppTypography.withColor(
                        AppTypography.body,
                        AppColors.foregroundMuted,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

                // Footer Area
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTechPills(project.techStack),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            metaText,
                            style: AppTypography.monoLabel.copyWith(
                              fontSize: 10.0,
                              color: AppColors.foregroundSubtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          isClickable ? 'READ MORE →' : 'COMING SOON',
                          style: AppTypography.monoLabel.copyWith(
                            color: isClickable ? AppColors.accent : AppColors.foregroundSubtle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact project card for supporting list.
class SupportingCard extends StatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const SupportingCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  State<SupportingCard> createState() => _SupportingCardState();
}

class _SupportingCardState extends State<SupportingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final isClickable = project.isClickable;

    // Pending 60% opacity
    final double baseOpacity = isClickable ? 1.0 : 0.6;
    final double finalOpacity = _isHovered && isClickable ? 1.0 : baseOpacity;


    // Context hint from metadata - client, company, or status
    final contextHint = project.client ?? project.company ?? project.status.replaceAll('_', ' ');

    final isDesktop = context.isDesktop;

    return MouseRegion(
      onEnter: (_) {
        if (isClickable && isDesktop) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (isClickable && isDesktop) setState(() => _isHovered = false);
      },
      cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: isClickable ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: finalOpacity,
          child: LitEdgeCard(
            padding: const EdgeInsets.all(20.0),
            isHovered: _isHovered,
            isClickable: isClickable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.name,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 18.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    if (project.tagline != null)
                      Text(
                        project.tagline!,
                        style: AppTypography.monoMeta.copyWith(
                          fontSize: 11.0,
                          color: AppColors.foregroundSubtle,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 16.0),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Wrap of 1-2 tech pills
                    if (project.techStack.isNotEmpty)
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 6.0,
                        children: project.techStack.take(2).map((tech) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLow,
                              border: Border.all(
                                color: AppColors.borderDefault,
                                width: 1.0,
                              ),
                              borderRadius: AppRadius.pill,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 3.0,
                            ),
                            child: Text(
                              tech.toUpperCase(),
                              style: AppTypography.monoLabel.copyWith(
                                fontSize: 9,
                                color: AppColors.foregroundSubtle,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16.0),
                    // Context hint footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            contextHint.toUpperCase(),
                            style: AppTypography.monoLabel.copyWith(
                              fontSize: 9.0,
                              color: AppColors.foregroundSubtle,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isClickable)
                          Text(
                            'COMING SOON',
                            style: AppTypography.monoLabel.copyWith(
                              fontSize: 9.0,
                              color: AppColors.foregroundSubtle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom ghost CTA representing the Supporting expand/collapse toggle.
class GhostToggleCTA extends StatefulWidget {
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  const GhostToggleCTA({
    super.key,
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<GhostToggleCTA> createState() => _GhostToggleCTAState();
}

class _GhostToggleCTAState extends State<GhostToggleCTA> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = isDesktop),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: _isHovered ? AppColors.accent : AppColors.borderDefault,
              width: 1,
            ),
            borderRadius: AppRadius.button,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label.toUpperCase(),
                style: AppTypography.monoLabel.copyWith(
                  color: _isHovered ? AppColors.accent : AppColors.foregroundPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                size: 16,
                color: _isHovered ? AppColors.accent : AppColors.foregroundPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
