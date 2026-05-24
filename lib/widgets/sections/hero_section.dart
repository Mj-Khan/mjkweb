import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/motion.dart';
import '../../data/app_data.dart';
import '../../models/site_config.dart';

/// The high-fidelity, fully responsive Hero Section.
/// Renders as asymmetric 2-column on desktop/tablet, and single column on mobile.
class HeroSection extends StatelessWidget {
  final GlobalKey workKey;
  final GlobalKey contactKey;

  const HeroSection({
    super.key,
    required this.workKey,
    required this.contactKey,
  });

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  double _getHeadlineSize(double screenWidth) {
    if (screenWidth > 1024) return 80.0;
    if (screenWidth < 768) return 52.0;
    // Tighter scaling interpolation for tablet widths (768-1024)
    final fraction = (screenWidth - 768.0) / (1024.0 - 768.0);
    return 52.0 + fraction * (80.0 - 52.0);
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final heroConfig = appData.siteConfig.hero;
    final isMobile = context.isMobile;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // Adjusting clean eyebrow to prevent double underscore when cursor is drawn
    final rawEyebrow = heroConfig.eyebrow;
    final cleanEyebrow = rawEyebrow.endsWith('_')
        ? rawEyebrow.substring(0, rawEyebrow.length - 1).trim()
        : rawEyebrow;

    // Headline styling with linear scaling
    final headlineSize = _getHeadlineSize(screenWidth);
    final headlineStyle = TextStyle(
      fontFamily: 'Geist',
      fontSize: headlineSize,
      fontWeight: FontWeight.w700,
      height: 1.05,
      letterSpacing: headlineSize * -0.03,
      color: AppColors.foregroundPrimary,
    );

    // Left Column content (stacked sequentially for animations)
    final leftColumnWidgets = [
      // Eyebrow with custom blinking cursor
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            cleanEyebrow.toUpperCase(),
            style: AppTypography.monoLabel.copyWith(
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 6),
          const BlinkingCursor(),
        ],
      ),
      const SizedBox(height: 16),
      // Scaling Headline
      Text(
        heroConfig.headline,
        style: headlineStyle,
      ),
      const SizedBox(height: 24),
      // Sub-headline / bio
      Text(
        heroConfig.subHeadline,
        style: AppTypography.withColor(
          AppTypography.bodyLarge,
          AppColors.foregroundMuted,
        ),
      ),
      const SizedBox(height: 40),
      // CTAs
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          PrimaryCTA(
            label: heroConfig.ctaPrimary.label,
            onTap: () => _scrollToSection(workKey),
          ),
          GhostCTA(
            label: heroConfig.ctaSecondary.label,
            onTap: () => _scrollToSection(contactKey),
          ),
        ],
      ),
      const SizedBox(height: 48),
      // Metrics Layout
      if (!isMobile)
        // Desktop/Tablet Row with vertical 1px hairlines
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _MetricItem(metric: heroConfig.metrics[0])),
            Container(
              width: 1,
              height: 48,
              color: AppColors.borderDefault,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            Expanded(child: _MetricItem(metric: heroConfig.metrics[1])),
            Container(
              width: 1,
              height: 48,
              color: AppColors.borderDefault,
              margin: const EdgeInsets.symmetric(horizontal: 24),
            ),
            Expanded(child: _MetricItem(metric: heroConfig.metrics[2])),
          ],
        )
      else
        // Mobile Column with horizontal hairline dividers
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MetricItem(metric: heroConfig.metrics[0]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.borderDefault, thickness: 1, height: 1),
            ),
            _MetricItem(metric: heroConfig.metrics[1]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: AppColors.borderDefault, thickness: 1, height: 1),
            ),
            _MetricItem(metric: heroConfig.metrics[2]),
          ],
        ),
    ];

    // Build responsive body
    Widget content;
    if (isMobile) {
      // Mobile Single Column: Avatar card on top, then text contents
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RevealAnimation(
            delay: const Duration(milliseconds: 160),
            child: AvatarCodeCard(
              lines: heroConfig.avatarCode,
              filename: heroConfig.avatarFilename,
            ),
          ),
          const SizedBox(height: 32),
          StaggeredRevealList(
            initialDelay: Duration.zero,
            interval: const Duration(milliseconds: 40),
            children: leftColumnWidgets,
          ),
        ],
      );
    } else {
      // Desktop / Tablet Asymmetric Two-Column Split (60% / 40%)
      final gutterSpacing = screenWidth > 1024 ? AppSpacing.xl : AppSpacing.lg;
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left 60%
          Expanded(
            flex: 60,
            child: StaggeredRevealList(
              initialDelay: Duration.zero,
              interval: const Duration(milliseconds: 40),
              children: leftColumnWidgets,
            ),
          ),
          SizedBox(width: gutterSpacing),
          // Right 40%
          Expanded(
            flex: 40,
            child: RevealAnimation(
              delay: const Duration(milliseconds: 160),
              child: Align(
                alignment: Alignment.centerRight,
                child: AvatarCodeCard(
                  lines: heroConfig.avatarCode,
                  filename: heroConfig.avatarFilename,
                ),
              ),
            ),
          ),
        ],
      );
    }

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
      child: isMobile
          ? content
          : ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.8,
              ),
              child: Center(
                child: content,
              ),
            ),
    );
  }
}

/// Blinking terminal-style block cursor.
class BlinkingCursor extends StatefulWidget {
  const BlinkingCursor({super.key});

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return const SizedBox.shrink(); // Static/no cursor when animations disabled
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final showCursor = _controller.value < 0.5;
        return Opacity(
          opacity: showCursor ? 1.0 : 0.0,
          child: child,
        );
      },
      child: Container(
        width: 8.0, // 1ch width approx
        height: 12.0, // Matches line-height height
        color: AppColors.accent,
      ),
    );
  }
}

/// Dynamic metric numeral that increments over 800ms.
class MetricCountUp extends StatefulWidget {
  final String targetValueString;

  const MetricCountUp({
    super.key,
    required this.targetValueString,
  });

  @override
  State<MetricCountUp> createState() => _MetricCountUpState();
}

class _MetricCountUpState extends State<MetricCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final int _targetValue;
  late final int _length;

  @override
  void initState() {
    super.initState();
    final parsed = int.tryParse(widget.targetValueString) ?? 0;
    _targetValue = parsed;
    _length = widget.targetValueString.length;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: _targetValue.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(
        widget.targetValueString,
        style: AppTypography.monoNumeral,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value.round();
        final paddedValue = currentValue.toString().padLeft(_length, '0');
        return Text(
          paddedValue,
          style: AppTypography.monoNumeral,
        );
      },
    );
  }
}

/// An individual metric item with count-up number and label.
class _MetricItem extends StatelessWidget {
  final HeroMetric metric;

  const _MetricItem({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        MetricCountUp(targetValueString: metric.value),
        const SizedBox(height: 8),
        Text(
          metric.label.toUpperCase(),
          style: AppTypography.monoLabel.copyWith(
            color: AppColors.foregroundSubtle,
            fontSize: 11.0,
          ),
        ),
      ],
    );
  }
}

/// Interactive primary CTA.
class PrimaryCTA extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const PrimaryCTA({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<PrimaryCTA> createState() => _PrimaryCTAState();
}

class _PrimaryCTAState extends State<PrimaryCTA> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.accentBright : AppColors.accent,
            borderRadius: AppRadius.button,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: AppTypography.monoLabel.copyWith(
              color: AppColors.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}

/// Interactive ghost/secondary CTA.
class GhostCTA extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const GhostCTA({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  State<GhostCTA> createState() => _GhostCTAState();
}

class _GhostCTAState extends State<GhostCTA> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: _isHovered ? AppColors.accent : AppColors.borderDefault,
              width: 1,
            ),
            borderRadius: AppRadius.button,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: AppTypography.monoLabel.copyWith(
              color: _isHovered ? AppColors.accent : AppColors.foregroundPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// A premium visual card displaying syntax-highlighted code.
class AvatarCodeCard extends StatelessWidget {
  final List<String> lines;
  final String filename;

  const AvatarCodeCard({
    super.key,
    required this.lines,
    required this.filename,
  });

  Widget _buildCodeLine(String line) {
    final List<TextSpan> children = [];

    // Simple robust tokenizer for highlighted values
    final regExp = RegExp(
      r"('[^']*')|\b(class|extends|final|bool|get|return)\b|\b(true|false)\b",
    );

    int lastMatchEnd = 0;
    for (final match in regExp.allMatches(line)) {
      if (match.start > lastMatchEnd) {
        children.add(TextSpan(
          text: line.substring(lastMatchEnd, match.start),
          style: const TextStyle(color: AppColors.foregroundPrimary),
        ));
      }

      final matchedText = match.group(0)!;
      if (match.group(1) != null) {
        // String literal - Highlight in accent
        children.add(TextSpan(
          text: matchedText,
          style: const TextStyle(color: AppColors.accent),
        ));
      } else if (match.group(2) != null) {
        // Keyword - Highlight in subtle/muted color
        children.add(TextSpan(
          text: matchedText,
          style: const TextStyle(
            color: AppColors.foregroundSubtle,
            fontWeight: FontWeight.w500,
          ),
        ));
      } else if (match.group(3) != null) {
        // Boolean value - Highlight in accent
        children.add(TextSpan(
          text: matchedText,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < line.length) {
      children.add(TextSpan(
        text: line.substring(lastMatchEnd),
        style: const TextStyle(color: AppColors.foregroundPrimary),
      ));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'IBM Plex Mono',
          fontSize: 13.0,
          height: 1.5,
        ),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mac-style window controls top bar
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF5350), // soft red
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCA28), // soft yellow
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF9CCC65), // soft green
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Text(
                filename,
                style: AppTypography.monoMeta.copyWith(
                  color: AppColors.foregroundSubtle,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Code block lines
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: lines
                .map((line) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: _buildCodeLine(line),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
