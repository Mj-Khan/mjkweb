import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/icon_resolver.dart';
import '../../data/app_data.dart';
import '../../models/profile.dart';

/// Fixed 220px desktop side rail — a real sidebar, not an icon strip.
///
/// Layout (top to bottom):
///   1. Identity block: monogram tile + name + tagline (all visible text)
///   2. Hairline
///   3. Numbered nav labels: "01  HERO", "02  WORK", … active gets accent + bg tint
///   4. Spacer
///   5. Hairline
///   6. Full-width "↓ DOWNLOAD CV" elevated accent button
///   7. Hairline
///   8. Horizontal social icon row (GitHub · LinkedIn · Email)
///
/// Only shown on desktop (≥1024px). Mobile/tablet uses MobileTopBar instead.
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Identity block ─────────────────────────────────────────────
          _IdentityBlock(profile: profile),

          // ── Hairline ───────────────────────────────────────────────────
          Container(height: 1, color: AppColors.borderDefault),

          // ── Numbered nav labels ────────────────────────────────────────
          const SizedBox(height: 12),
          ...navSections.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final sectionId = entry.value;
            final label = _sectionLabels[sectionId] ?? sectionId.toUpperCase();
            final isActive = sectionId == activeSection;
            final key = sectionKeys[sectionId];

            return _NavItem(
              index: index,
              label: label,
              isActive: isActive,
              onTap: key != null ? () => onScrollTo(key) : null,
            );
          }),
          const SizedBox(height: 12),

          const Spacer(),

          // ── Hairline ───────────────────────────────────────────────────
          Container(height: 1, color: AppColors.borderDefault),
          const SizedBox(height: 16),

          // ── CV Download button ─────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: _CvButton(),
          ),
          const SizedBox(height: 16),

          // ── Hairline ───────────────────────────────────────────────────
          Container(height: 1, color: AppColors.borderDefault),
          const SizedBox(height: 12),

          // ── Horizontal social icons ────────────────────────────────────
          _SocialRow(profile: profile),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Identity block ─────────────────────────────────────────────────────────

class _IdentityBlock extends StatelessWidget {
  final Profile profile;
  const _IdentityBlock({required this.profile});

  /// Extract up to 2 initials from name.
  String get _initials {
    final parts = profile.name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 2).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bordered monogram tile — swap Image.asset() here when avatar is available
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Full name
          Text(
            profile.name,
            style: const TextStyle(
              fontFamily: 'Geist',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.foregroundPrimary,
              letterSpacing: -0.1,
            ),
          ),

          const SizedBox(height: 4),

          // Tagline / title
          Text(
            profile.tagline,
            style: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: AppColors.foregroundSubtle,
              letterSpacing: 0.3,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Numbered nav item ─────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  final int index;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.index,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    final Color textColor = widget.isActive
        ? AppColors.accent
        : _hovered
            ? AppColors.foregroundPrimary
            : AppColors.foregroundSubtle;

    return MouseRegion(
      onEnter: (_) {
        if (isDesktop) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (isDesktop) setState(() => _hovered = false);
      },
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 44,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.accent.withValues(alpha: 0.07)
                : _hovered
                    ? AppColors.accent.withValues(alpha: 0.03)
                    : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: widget.isActive ? AppColors.accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Index number
              SizedBox(
                width: 22,
                child: Text(
                  widget.index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: widget.isActive
                        ? AppColors.accent
                        : AppColors.foregroundSubtle.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Section label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 11,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CV Download button ────────────────────────────────────────────────────────

class _CvButton extends StatefulWidget {
  const _CvButton();

  @override
  State<_CvButton> createState() => _CvButtonState();
}

class _CvButtonState extends State<_CvButton> {
  bool _hovered = false;

  Future<void> _download() async {
    const url = 'Abdul-Mujeeb-Khan-Resume.pdf';
    final uri = Uri.parse(url);
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
        onTap: _download,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 40,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.accentBright : AppColors.accent,
            borderRadius: AppRadius.button,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_outlined,
                size: 15,
                color: AppColors.onAccent,
              ),
              const SizedBox(width: 8),
              Text(
                'DOWNLOAD CV',
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: AppColors.onAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Horizontal social icon row ────────────────────────────────────────────────

class _SocialRow extends StatelessWidget {
  final Profile profile;
  const _SocialRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      ),
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
    final isDesktop = context.isDesktop;

    return Tooltip(
      message: widget.tooltip,
      textStyle: AppTypography.monoLabel.copyWith(
        color: AppColors.backgroundBase,
        fontSize: 11,
      ),
      child: MouseRegion(
        onEnter: (_) {
          if (isDesktop) setState(() => _hovered = true);
        },
        onExit: (_) {
          if (isDesktop) setState(() => _hovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _launch,
          child: SizedBox(
            width: 40,
            height: 36,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.iconData,
                  key: ValueKey(_hovered),
                  color: _hovered ? AppColors.accent : AppColors.foregroundSubtle,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
