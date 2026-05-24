import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/icon_resolver.dart';
import '../../data/app_data.dart';

/// Reusable, fully responsive bottom Footer Section.
/// Renders as a 3-column row on desktop (LEFT: copyright, CENTER: built-with tag, RIGHT: socials row)
/// and center-aligned stack on mobile with 12px gaps.
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  void _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final footerConfig = appData.siteConfig.footer;
    final profile = appData.content.profile;
    final socialIconMap = appData.siteConfig.socialIconMap;
    final isMobile = context.isMobile;

    // Resolve Dynamic Social Icons
    final emailIconName = socialIconMap['email'] ?? 'mail_outlined';
    final emailIcon = IconResolver.iconFromName(emailIconName);

    final githubIconName = socialIconMap['github'] ?? 'code_rounded';
    final githubIcon = IconResolver.iconFromName(githubIconName);

    final linkedinIconName = socialIconMap['linkedin'] ?? 'work_outline_rounded';
    final linkedinIcon = IconResolver.iconFromName(linkedinIconName);

    // Left copyright text
    final copyrightWidget = Text(
      footerConfig.copyright.toUpperCase(),
      style: AppTypography.monoLabel.copyWith(
        color: AppColors.foregroundSubtle,
        fontSize: 10.0,
      ),
    );

    // Center built-with tag
    final builtWithWidget = Text(
      footerConfig.builtWith.toUpperCase(),
      style: AppTypography.monoLabel.copyWith(
        color: AppColors.foregroundSubtle,
        fontSize: 10.0,
      ),
    );

    // Right social icon actions row (20px icons, 16px gaps)
    final socialsRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FooterSocialIcon(
          icon: emailIcon,
          onTap: () => _launchUrl('mailto:${profile.email}'),
        ),
        const SizedBox(width: 16),
        if (profile.githubUrl != null) ...[
          _FooterSocialIcon(
            icon: githubIcon,
            onTap: () => _launchUrl(profile.githubUrl!),
          ),
          const SizedBox(width: 16),
        ],
        if (profile.linkedinUrl != null)
          _FooterSocialIcon(
            icon: linkedinIcon,
            onTap: () => _launchUrl(profile.linkedinUrl!),
          ),
      ],
    );

    Widget content;
    if (isMobile) {
      // Mobile Layout: Center-aligned stack with 12px gaps
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          copyrightWidget,
          const SizedBox(height: 12),
          builtWithWidget,
          const SizedBox(height: 12),
          socialsRow,
        ],
      );
    } else {
      // Desktop / Tablet Layout: 3-column row (spread layout)
      content = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: copyrightWidget,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: builtWithWidget,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: socialsRow,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.borderDefault,
            width: 1.0, // Hairline top divider
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 24.0, // authoritative 24px padding
      ),
      child: content,
    );
  }
}

/// Interactive social icon inside the footer.
class _FooterSocialIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FooterSocialIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_FooterSocialIcon> createState() => _FooterSocialIconState();
}

class _FooterSocialIconState extends State<_FooterSocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Icon(
          widget.icon,
          size: 20.0, // authoritative 20px size
          color: _isHovered ? AppColors.accentBright : AppColors.accent,
        ),
      ),
    );
  }
}
