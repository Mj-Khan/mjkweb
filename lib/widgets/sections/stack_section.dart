import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/icon_resolver.dart';
import '../../core/motion.dart';
import '../../data/app_data.dart';
import '../../models/skill.dart';
import '../components/now_widget.dart';

/// High-fidelity, fully responsive Stack + Now Section.
/// Renders a dynamic two-column layout on desktop (Stack 65% / Now 35%) when enabled,
/// and stacks vertically on mobile. Toggling the now module reflows the Stack to 100% full width.
class StackSection extends StatelessWidget {
  const StackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final stackConfig = appData.siteConfig.stack;
    final showNow = appData.siteConfig.now.showNowModule;
    final isMobile = context.isMobile;

    // Heading block consistent with Work and Experience sections
    final headerBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '// ${stackConfig.heading.toUpperCase()}',
          style: AppTypography.monoLabel.copyWith(
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          stackConfig.subLine,
          style: AppTypography.sectionHeading(isMobile: isMobile),
        ),
      ],
    );

    // Categories list build widget
    final stackContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        headerBlock,
        const SizedBox(height: 48),
        _SkillsCategoryList(),
      ],
    );

    Widget content;
    if (isMobile) {
      // Mobile Layout: Stacks Stack then Now
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          stackContent,
          if (showNow) ...[
            const SizedBox(height: 48),
            const NowWidget(),
          ],
        ],
      );
    } else {
      // Desktop / Tablet Layout: Asymmetric Column Split (65% / 35%)
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Stack Section (flex 65 if Now shown, otherwise 100)
          Expanded(
            flex: showNow ? 65 : 100,
            child: stackContent,
          ),
          if (showNow) ...[
            const SizedBox(width: 48),
            // Right side: Now Card Section (flex 35, constrained to max width 360)
            Expanded(
              flex: 35,
              child: Align(
                alignment: Alignment.topRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 360),
                  child: NowWidget(),
                ),
              ),
            ),
          ],
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
      child: content,
    );
  }
}

/// Dynamic, staggered listing of skill categories.
class _SkillsCategoryList extends StatelessWidget {
  const _SkillsCategoryList();

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final categories = appData.content.skills;

    return StaggeredRevealList(
      initialDelay: Duration.zero,
      interval: const Duration(milliseconds: 60),
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0), // 24-32px spacing between categories
          child: _SkillCategoryBlock(category: cat),
        );
      }).toList(),
    );
  }
}

/// Individual skill category block displaying label + icon, and wrapped pills.
class _SkillCategoryBlock extends StatelessWidget {
  final SkillCategory category;

  const _SkillCategoryBlock({required this.category});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final siteConfig = appData.siteConfig;

    // Resolve category icon from site_config.iconMap.skill_categories
    final iconName = siteConfig.skillCategoryIconMap[category.name] ?? 'circle_outlined';
    final iconData = IconResolver.iconFromName(iconName);

    final isLearning = category.name == 'Currently Learning';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Category Label Header
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 16,
              color: AppColors.accent,
            ),
            const SizedBox(width: 8),
            Text(
              category.name.toUpperCase(),
              style: AppTypography.monoLabel.copyWith(
                color: AppColors.accent,
                letterSpacing: 12.0 * 0.05,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Wrapping Skill Pills
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: category.skills.map((skill) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // transparent bg per spec
                border: Border.all(
                  color: AppColors.borderDefault,
                  width: 1.0,
                ),
                borderRadius: AppRadius.pill, // 6px radius
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pulsing green dot for Currently Learning
                  if (isLearning) ...[
                    const PulsingDot(),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    skill.name.toUpperCase(),
                    style: AppTypography.monoLabel.copyWith(
                      color: AppColors.foregroundPrimary,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Custom stateful pulsing dot that fades opacity from 0.4 to 1.0 dynamically.
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      );
    }

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
