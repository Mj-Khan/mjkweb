import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_spacing.dart';
import '../../core/icon_resolver.dart';
import '../../data/app_data.dart';
import '../../models/profile.dart';

/// Sticky 56px mobile top bar + full-screen overlay nav.
///
/// The overlay fades in (200ms, slight up-slide) and fades out (150ms).
/// Nav links are large Geist 600 34px centered; social row at the bottom.
class MobileTopBar extends StatefulWidget {
  /// Ordered section ids from site_config.navSections.
  final List<String> navSections;

  /// GlobalKey per section id.
  final Map<String, GlobalKey> sectionKeys;

  /// Currently active section id.
  final String? activeSection;

  /// Scroll callback.
  final void Function(GlobalKey key) onScrollTo;

  const MobileTopBar({
    super.key,
    required this.navSections,
    required this.sectionKeys,
    required this.activeSection,
    required this.onScrollTo,
  });

  @override
  State<MobileTopBar> createState() => _MobileTopBarState();
}

class _MobileTopBarState extends State<MobileTopBar>
    with SingleTickerProviderStateMixin {
  bool _overlayOpen = false;
  late final AnimationController _animController;
  OverlayEntry? _overlayEntry;

  // Human-readable labels
  static const Map<String, String> _sectionLabels = {
    'hero':       'HERO',
    'work':       'WORK',
    'experience': 'EXPERIENCE',
    'stack':      'STACK',
    'contact':    'CONTACT',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _openOverlay() {
    final appData = AppData.of(context);
    final profile = appData.content.profile;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => AnimatedBuilder(
        animation: _animController,
        builder: (ctx, child) => Opacity(
          opacity: _animController.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _animController.value) * 16),
            child: child,
          ),
        ),
        child: _OverlayNav(
          navSections: widget.navSections,
          activeSection: widget.activeSection,
          sectionLabels: _sectionLabels,
          profile: profile,
          onClose: _closeOverlay,
          onNavTap: _handleNavTap,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _overlayOpen = true);
    _animController.forward();
  }

  void _closeOverlay() {
    _animController.reverse().then((_) {
      if (mounted) {
        _removeOverlay();
        setState(() => _overlayOpen = false);
      }
    });
  }

  void _handleNavTap(String sectionId) {
    final key = widget.sectionKeys[sectionId];
    _closeOverlay();
    if (key != null) {
      // Small delay so overlay finishes closing before scroll fires
      Future.delayed(const Duration(milliseconds: 160), () {
        widget.onScrollTo(key);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.topBarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLow,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutterMobile),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LEFT — identity block (monogram + name)
          Builder(builder: (ctx) {
            final appData = AppData.of(ctx);
            return _MobileIdentityBlock(name: appData.content.profile.name);
          }),
          // RIGHT — hamburger / close icon
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: _overlayOpen ? _closeOverlay : _openOverlay,
              child: Icon(
                _overlayOpen ? Icons.close : Icons.menu,
                color: AppColors.foregroundPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay nav content ───────────────────────────────────────────────────────

class _OverlayNav extends StatelessWidget {
  final List<String> navSections;
  final String? activeSection;
  final Map<String, String> sectionLabels;
  final Profile profile;
  final VoidCallback onClose;
  final void Function(String sectionId) onNavTap;

  const _OverlayNav({
    required this.navSections,
    required this.activeSection,
    required this.sectionLabels,
    required this.profile,
    required this.onClose,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundBase,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top: identity block + X close button ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutterMobile,
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MobileIdentityBlock(name: profile.name),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: onClose,
                      child: const Icon(
                        Icons.close,
                        color: AppColors.foregroundPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Hairline ───────────────────────────────────────────────
            Container(height: 1, color: AppColors.borderDefault),

            // ── Nav links (centered, large) ────────────────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: navSections.map((sectionId) {
                    final label = sectionLabels[sectionId] ?? sectionId.toUpperCase();
                    final isActive = sectionId == activeSection;
                    return _OverlayNavLink(
                      label: label,
                      isActive: isActive,
                      onTap: () => onNavTap(sectionId),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Hairline ───────────────────────────────────────────────
            Container(height: 1, color: AppColors.borderDefault),

            // ── CV Download ────────────────────────────────────────────
            const _OverlayCvButton(),

            // ── Hairline ───────────────────────────────────────────────
            Container(height: 1, color: AppColors.borderDefault),

            // ── Social icons row ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: _OverlaySocials(profile: profile),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single nav link in overlay ────────────────────────────────────────────────

class _OverlayNavLink extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _OverlayNavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_OverlayNavLink> createState() => _OverlayNavLinkState();
}

class _OverlayNavLinkState extends State<_OverlayNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isActive
        ? AppColors.accent
        : _hovered
            ? AppColors.foregroundPrimary
            : AppColors.foregroundSubtle;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Geist',
              fontSize: 34,
              fontWeight: FontWeight.w600,
              height: 1.10,
              letterSpacing: 34 * -0.02,
              color: color,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ── Social icon row inside overlay ────────────────────────────────────────────

class _OverlaySocials extends StatelessWidget {
  final Profile profile;

  const _OverlaySocials({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (profile.githubUrl != null) ...[
          _OverlaySocialIcon(
            iconData: IconResolver.iconFromName('code_rounded'),
            url: profile.githubUrl!,
          ),
          const SizedBox(width: 24),
        ],
        if (profile.linkedinUrl != null) ...[
          _OverlaySocialIcon(
            iconData: IconResolver.iconFromName('work_outline_rounded'),
            url: profile.linkedinUrl!,
          ),
          const SizedBox(width: 24),
        ],
        _OverlaySocialIcon(
          iconData: IconResolver.iconFromName('email_outlined'),
          url: 'mailto:${profile.email}',
        ),
      ],
    );
  }
}

class _OverlaySocialIcon extends StatefulWidget {
  final IconData iconData;
  final String url;

  const _OverlaySocialIcon({required this.iconData, required this.url});

  @override
  State<_OverlaySocialIcon> createState() => _OverlaySocialIconState();
}

class _OverlaySocialIconState extends State<_OverlaySocialIcon> {
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            widget.iconData,
            key: ValueKey(_hovered),
            color: _hovered ? AppColors.accent : AppColors.foregroundSubtle,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ── Mobile identity block (top bar & overlay header) ─────────────────────────

class _MobileIdentityBlock extends StatelessWidget {
  final String name;
  const _MobileIdentityBlock({required this.name});

  /// First 2 initials from name.
  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 2).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bordered monogram tile
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderDefault, width: 1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(
            child: Text(
              _initials,
              style: const TextStyle(
                fontFamily: 'IBM Plex Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Name text
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Geist',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.foregroundPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Download CV row in overlay ────────────────────────────────────────────────

class _OverlayCvButton extends StatefulWidget {
  const _OverlayCvButton();

  @override
  State<_OverlayCvButton> createState() => _OverlayCvButtonState();
}

class _OverlayCvButtonState extends State<_OverlayCvButton> {
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
          color: _hovered
              ? AppColors.accent.withValues(alpha: 0.06)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutterMobile,
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.download_outlined,
                size: 18,
                color: _hovered ? AppColors.accent : AppColors.foregroundSubtle,
              ),
              const SizedBox(width: 12),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: _hovered ? AppColors.accent : AppColors.foregroundSubtle,
                ),
                child: const Text('DOWNLOAD CV'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
