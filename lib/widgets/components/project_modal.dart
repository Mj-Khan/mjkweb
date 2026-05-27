import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../models/project.dart';
import 'lit_edge_card.dart';

/// Accessibility-first, high-fidelity project details modal.
class ProjectModal extends StatelessWidget {
  final Project project;

  const ProjectModal({
    super.key,
    required this.project,
  });

  /// Displays the project modal using [showGeneralDialog] with a custom scale-fade transition.
  static void show(BuildContext context, Project project) {
    showGeneralDialog(
      context: context,
      barrierColor: AppColors.modalScrim,
      barrierDismissible: true,
      barrierLabel: 'Close details for ${project.name}',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ProjectModal(project: project);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );
        return Opacity(
          opacity: opacityAnimation.value,
          child: Transform.scale(
            scale: scaleAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Outer padding settings matching the token table
    final double paddingValue =
        isMobile ? AppSpacing.modalPaddingMobile : AppSpacing.modalPaddingDesktop;

    // Main modal content widget wrapped in FocusScope & KeyboardListener
    final contentWidget = _ModalContent(
      project: project,
      paddingValue: paddingValue,
      onLaunch: _launchUrl,
    );

    if (isMobile) {
      // Full screen takeover for mobile
      return Material(
        color: AppColors.backgroundBase,
        child: SafeArea(
          child: contentWidget,
        ),
      );
    }

    // Centered modal panel on Desktop/Tablet
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 880.0,
            maxHeight: screenHeight * 0.9,
          ),
          child: LitEdgeCard(
            presence: CardPresence.featured,
            isClickable: false,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.card,
              child: contentWidget,
            ),
          ),
        ),
      ),
    );
  }
}

/// The inner scrollable and focus-trapped content of the modal.
class _ModalContent extends StatefulWidget {
  final Project project;
  final double paddingValue;
  final ValueChanged<String> onLaunch;

  const _ModalContent({
    required this.project,
    required this.paddingValue,
    required this.onLaunch,
  });

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus so we capture ESC key events immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final project = widget.project;
    final meta = project.storeMetadata;

    // Formulate date string
    final dateRange = (project.startDate != null)
        ? '${project.startDate} — ${project.endDate ?? "Present"}'
        : null;

    return FocusScope(
      autofocus: true,
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
        onKeyEvent: _handleKeyEvent,
        child: Column(
          children: [
            // ── Sticky Header (Close Bar) ────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderDefault,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: widget.paddingValue,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        '← BACK',
                        style: AppTypography.monoLabel.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'CLOSE ✕',
                        style: AppTypography.monoLabel.copyWith(
                          color: AppColors.foregroundSubtle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(widget.paddingValue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Tags Eyebrows
                    if (project.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: project.tags.map((tag) {
                            return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.accentDim,
                                  width: 1.0,
                                ),
                                borderRadius: AppRadius.pill,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Text(
                                tag.toUpperCase(),
                                style: AppTypography.monoLabel.copyWith(
                                  fontSize: 10,
                                  color: AppColors.accent,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    // 2. Project Name
                    Text(
                      project.name,
                      style: AppTypography.modalTitle(isMobile: isMobile),
                    ),
                    const SizedBox(height: 8.0),

                    // 3. Tagline
                    if (project.tagline != null)
                      Text(
                        project.tagline!,
                        style: AppTypography.withColor(
                          AppTypography.bodyLarge,
                          AppColors.foregroundMuted,
                        ),
                      ),
                    const SizedBox(height: 16.0),

                    // 4. Meta Strip (Company / Status / Dates)
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (project.company != null) ...[
                          _MetaBadge(
                            label: 'COMPANY',
                            value: project.company!,
                            icon: Icons.person_outline,
                          ),
                          _dividerBullet(),
                        ],
                        _MetaBadge(
                          label: 'STATUS',
                          value: project.status.replaceAll('_', ' ').toUpperCase(),
                          icon: Icons.smartphone,
                        ),
                        if (dateRange != null) ...[
                          _dividerBullet(),
                          _MetaBadge(
                            label: 'TIMELINE',
                            value: dateRange,
                            icon: Icons.calendar_today,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32.0),

                    // 5. Store Stats Row (Omitted if null, no invented numbers!)
                    if (meta != null &&
                        (meta.rating != null ||
                            meta.reviewCount != null ||
                            meta.downloadsLabel != null)) ...[
                      const Divider(color: AppColors.borderDefault, height: 1.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Row(
                          children: [
                            if (meta.rating != null)
                              Expanded(
                                child: _StatItem(
                                  value: '★ ${meta.rating!.toStringAsFixed(1)}',
                                  label: 'RATING',
                                ),
                              ),
                            if (meta.rating != null && meta.reviewCount != null)
                              _verticalDivider(),
                            if (meta.reviewCount != null)
                              Expanded(
                                child: _StatItem(
                                  value: _formatReviews(meta.reviewCount!),
                                  label: 'REVIEWS',
                                ),
                              ),
                            if (meta.reviewCount != null && meta.downloadsLabel != null)
                              _verticalDivider(),
                            if (meta.downloadsLabel != null)
                              Expanded(
                                child: _StatItem(
                                  value: meta.downloadsLabel!,
                                  label: 'DOWNLOADS',
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.borderDefault, height: 1.0),
                      const SizedBox(height: 32.0),
                    ],

                    // 6. Problem Section
                    if (project.problemSolved != null || project.longDescription != null) ...[
                      _sectionEyebrow('01 // THE PROBLEM'),
                      const SizedBox(height: 12.0),
                      Text(
                        project.problemSolved ?? project.longDescription!,
                        style: AppTypography.withColor(
                          AppTypography.bodyLarge,
                          AppColors.foregroundMuted,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                    ],

                    // 7. My Role Section
                    if (project.roleSummary != null) ...[
                      _sectionEyebrow('02 // MY ROLE'),
                      const SizedBox(height: 12.0),
                      Text(
                        project.roleSummary!,
                        style: AppTypography.withColor(
                          AppTypography.bodyLarge,
                          AppColors.foregroundMuted,
                        ),
                      ),
                      const SizedBox(height: 32.0),
                    ],

                    // 8. What I Built Section (Mini-cards wrap layout)
                    if (project.contributionBullets.isNotEmpty) ...[
                      _sectionEyebrow('03 // WHAT I BUILT'),
                      const SizedBox(height: 16.0),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: project.contributionBullets.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 12.0),
                        itemBuilder: (context, index) {
                          final bullet = project.contributionBullets[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.borderDefault,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                                    bullet,
                                    style: AppTypography.withColor(
                                      AppTypography.body,
                                      AppColors.foregroundMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32.0),
                    ],

                    // 9. Tech Stack Section
                    if (project.techStack.isNotEmpty) ...[
                      _sectionEyebrow('04 // TECH STACK'),
                      const SizedBox(height: 16.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: project.techStack.map((tech) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.borderDefault,
                                width: 1.0,
                              ),
                              borderRadius: AppRadius.pill,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 6.0,
                            ),
                            child: Text(
                              tech.toUpperCase(),
                              style: AppTypography.monoLabel.copyWith(
                                fontSize: 11,
                                color: AppColors.foregroundPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 48.0),
                    ],

                    // 10. Actions / Links strip
                    if (project.links.isNotEmpty)
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: project.links.map((link) {
                          final isPlayStore = link.type == 'play_store';
                          final labelText = isPlayStore
                              ? 'VIEW ON PLAY STORE ↗'
                              : 'VISIT LINK ↗';

                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => widget.onLaunch(link.url),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPlayStore
                                      ? AppColors.accent
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: AppColors.accent,
                                    width: 1.0,
                                  ),
                                  borderRadius: AppRadius.button,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                  vertical: 16.0,
                                ),
                                child: Text(
                                  labelText,
                                  style: AppTypography.monoLabel.copyWith(
                                    color: isPlayStore
                                        ? AppColors.onAccent
                                        : AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ────────────────────────────────────────────────────────

  String _formatReviews(int count) {
    if (count >= 1000) {
      return '${(count / 1000.0).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _dividerBullet() {
    return const Text(
      '•',
      style: TextStyle(color: AppColors.borderStrong),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1.0,
      height: 32.0,
      color: AppColors.borderDefault,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
    );
  }

  Widget _sectionEyebrow(String label) {
    return Text(
      label,
      style: AppTypography.monoLabel.copyWith(
        color: AppColors.accent,
      ),
    );
  }
}

/// A compact meta badge combining label, icon, and dynamic string.
class _MetaBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetaBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.monoLabel.copyWith(
            fontSize: 9.0,
            color: AppColors.foregroundSubtle,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.0,
              color: AppColors.accentDim,
            ),
            const SizedBox(width: 6.0),
            Text(
              value,
              style: AppTypography.monoMeta.copyWith(
                fontSize: 12.0,
                color: AppColors.foregroundPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Stat display block.
class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.monoNumeral.copyWith(
            fontSize: 32.0,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: AppTypography.monoLabel.copyWith(
            fontSize: 10.0,
            color: AppColors.foregroundSubtle,
          ),
        ),
      ],
    );
  }
}
