import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/icon_resolver.dart';
import '../../data/app_data.dart';
import '../../models/profile.dart';

/// Fixed 60px desktop side rail.
///
/// - Top: "MK" monogram (mono-label, accent).
/// - Middle: vertical icon-only nav derived from [navSections] + [sectionKeys].
///   Active section gets accent colour + 2px left accent border.
///   Inactive icons are foreground-subtle; hover → accent, 200ms.
/// - Bottom: GitHub + LinkedIn social icons (foreground-subtle → accent on hover).
class DesktopNavRail extends StatelessWidget {
  /// Ordered list of section ids from site_config.navSections.
  final List<String> navSections;

  /// GlobalKey per section id — used to resolve scroll targets.
  final Map<String, GlobalKey> sectionKeys;

  /// Currently active section id (from scroll detection).
  final String? activeSection;

  /// Scroll callback — called with the target section's GlobalKey.
  final void Function(GlobalKey key) onScrollTo;

  const DesktopNavRail({
    super.key,
    required this.navSections,
    required this.sectionKeys,
    required this.activeSection,
    required this.onScrollTo,
  });

  // ── Icon name lookup per section id ─────────────────────────────────────

  static const Map<String, String> _sectionIcons = {
    'hero':       'home_outlined',
    'work':       'code',
    'experience': 'work_outline',
    'stack':      'terminal',
    'contact':    'mail_outlined',
  };

  static const Map<String, String> _sectionLabels = {
    'hero':       'HERO',
    'work':       'WORK',
    'experience': 'EXPERIENCE',
    'stack':      'STACK',
    'contact':    'CONTACT',
  };

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final profile = appData.content.profile;

    return Container(
      width: AppSpacing.sideRailWidth,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        border: Border(
          right: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── MK monogram ────────────────────────────────────────────────
          const SizedBox(height: 24),
          Text(
            'MK',
            style: AppTypography.monoLabel.copyWith(
              color: AppColors.accent,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),

          // ── Hairline divider ───────────────────────────────────────────
          Container(height: 1, color: AppColors.borderDefault),
          const SizedBox(height: 16),

          // ── Vertical section icons ─────────────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: navSections.map((sectionId) {
                final isActive = sectionId == activeSection;
                final iconName = _sectionIcons[sectionId] ?? 'circle_outlined';
                final tooltip = _sectionLabels[sectionId] ?? sectionId.toUpperCase();
                final key = sectionKeys[sectionId];

                return _NavIcon(
                  iconData: IconResolver.iconFromName(iconName),
                  tooltip: tooltip,
                  isActive: isActive,
                  onTap: key != null ? () => onScrollTo(key) : null,
                );
              }).toList(),
            ),
          ),

          // ── Hairline divider ───────────────────────────────────────────
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.borderDefault),
          const SizedBox(height: 16),

          // ── Social icons ────────────────────────────────────────────────
          _SocialIcons(profile: profile),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Nav icon item ────────────────────────────────────────────────────────────

class _NavIcon extends StatefulWidget {
  final IconData iconData;
  final String tooltip;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.iconData,
    required this.tooltip,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isActive
        ? AppColors.accent
        : _hovered
            ? AppColors.accent
            : AppColors.foregroundSubtle;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.tooltip,
          preferBelow: false,
          textStyle: AppTypography.monoLabel.copyWith(
            color: AppColors.backgroundBase,
            fontSize: 11,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: AppSpacing.sideRailWidth,
            height: 48,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: widget.isActive
                      ? AppColors.accent
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.iconData,
                  key: ValueKey(iconColor.toARGB32()),
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Social icons (bottom of rail) ────────────────────────────────────────────

class _SocialIcons extends StatelessWidget {
  final Profile profile;

  const _SocialIcons({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (profile.githubUrl != null)
          _SocialIcon(
            iconData: IconResolver.iconFromName('code_rounded'),
            url: profile.githubUrl!,
            tooltip: 'GitHub',
          ),
        if (profile.linkedinUrl != null)
          _SocialIcon(
            iconData: IconResolver.iconFromName('work_outline_rounded'),
            url: profile.linkedinUrl!,
            tooltip: 'LinkedIn',
          ),
        _SocialIcon(
          iconData: IconResolver.iconFromName('email_outlined'),
          url: 'mailto:${profile.email}',
          tooltip: 'Email',
        ),
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData iconData;
  final String url;
  final String tooltip;

  const _SocialIcon({
    required this.iconData,
    required this.url,
    required this.tooltip,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;

  Future<void> _launch() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _launch,
        child: Tooltip(
          message: widget.tooltip,
          textStyle: AppTypography.monoLabel.copyWith(
            color: AppColors.backgroundBase,
            fontSize: 11,
          ),
          child: SizedBox(
            width: AppSpacing.sideRailWidth,
            height: 40,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.iconData,
                  key: ValueKey(_hovered),
                  color: _hovered ? AppColors.accent : AppColors.foregroundSubtle,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
