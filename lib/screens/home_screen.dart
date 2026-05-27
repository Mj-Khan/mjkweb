import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_spacing.dart';
import '../core/breakpoints.dart';
import '../data/app_data.dart';
import '../widgets/components/desktop_nav_rail.dart';
import '../widgets/components/mobile_top_bar.dart';
import '../widgets/components/aurora_background.dart';
import '../widgets/sections/hero_section.dart';
import '../widgets/sections/work_section.dart';
import '../widgets/sections/experience_section.dart';
import '../widgets/sections/stack_section.dart';
import '../widgets/sections/contact_section.dart';
import '../widgets/sections/footer_section.dart';

/// Root screen that orchestrates the fixed chrome (rail / top bar) + scrollable
/// content column.  Handles:
///   - Active-section detection via [NotificationListener<ScrollNotification>]
///   - [scrollToSection] called from nav rail, top-bar overlay, and Hero CTAs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Section GlobalKeys ────────────────────────────────────────────────────
  final GlobalKey heroKey       = GlobalKey();
  final GlobalKey workKey       = GlobalKey();
  final GlobalKey experienceKey = GlobalKey();
  final GlobalKey stackKey      = GlobalKey();
  final GlobalKey contactKey    = GlobalKey();
  final GlobalKey footerKey     = GlobalKey();

  late final Map<String, GlobalKey> _sectionKeys;

  final ScrollController _scrollController = ScrollController();

  /// Currently highlighted nav section id.
  String? _activeSection;

  @override
  void initState() {
    super.initState();
    _sectionKeys = {
      'hero':       heroKey,
      'work':       workKey,
      'experience': experienceKey,
      'stack':      stackKey,
      'contact':    contactKey,
    };
    // Default active section is hero.
    _activeSection = 'hero';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Scroll wiring ─────────────────────────────────────────────────────────

  /// Scrolls [key]'s section into view, compensating for the mobile top bar.
  void scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;

    final isDesktop = MediaQuery.sizeOf(context).width > Breakpoints.desktop;
    final alignmentOffset = isDesktop ? 0.0 : 0.0;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: alignmentOffset,
    );
  }

  // ── Active-section detection ──────────────────────────────────────────────

  /// Called on every scroll notification.
  /// Finds the section whose top edge is closest to (but not past) 30% of the
  /// viewport height; that section becomes active.
  bool _handleScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    final viewportHeight = notification.metrics.viewportDimension;
    final threshold = viewportHeight * 0.30;

    // Check sections in reverse order so the last section "wins" when multiple
    // are above the threshold.
    String? newActive;
    for (final entry in _sectionKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;

      final renderBox = ctx.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) continue;

      final position = renderBox.localToGlobal(Offset.zero);
      // Adjust for the chrome offset: on desktop, the rail is on the left
      // (no vertical offset); on mobile/tablet the top bar is 56px.
      final sectionTop = position.dy;

      if (sectionTop <= threshold) {
        newActive = entry.key;
      }
    }

    if (newActive != null && newActive != _activeSection) {
      setState(() => _activeSection = newActive);
    }
    return false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appData     = AppData.of(context);
    final navSections = appData.siteConfig.navSections;
    final isMobile    = context.isMobile;
    final isDesktop   = context.isDesktop;

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: Stack(
          children: [
            // ── Vignette background ─────────────────────────────────────
            Positioned.fill(
              child: Container(decoration: AppColors.vignetteDecoration),
            ),


            // ── DESKTOP: fixed side rail ────────────────────────────────
            if (isDesktop)
              Positioned(
                left: 0, top: 0, bottom: 0,
                width: AppSpacing.sideRailWidth,
                child: DesktopNavRail(
                  navSections: navSections,
                  sectionKeys: _sectionKeys,
                  activeSection: _activeSection,
                  onScrollTo: scrollToSection,
                ),
              ),

            // ── MOBILE / TABLET: sticky top bar ─────────────────────────
            if (!isDesktop)
              Positioned(
                left: 0, top: 0, right: 0,
                height: AppSpacing.topBarHeight,
                child: MobileTopBar(
                  navSections: navSections,
                  sectionKeys: _sectionKeys,
                  activeSection: _activeSection,
                  onScrollTo: scrollToSection,
                ),
              ),

            // ── Main scrollable content ─────────────────────────────────
            Positioned.fill(
              left:  isDesktop ? AppSpacing.sideRailWidth : 0,
              top:   isDesktop ? 0 : AppSpacing.topBarHeight,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSpacing.containerMaxWidth,
                    ),
                    child: Stack(
                      children: [
                        // Aurora Background placed inside the scrollable content Stack
                        const Positioned.fill(
                          child: AuroraBackground(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile
                                ? AppSpacing.gutterMobile
                                : AppSpacing.gutterDesktop,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              HeroSection(
                                key: heroKey,
                                workKey: workKey,
                                contactKey: contactKey,
                              ),
                              WorkSection(
                                key: workKey,
                              ),
                              ExperienceSection(
                                key: experienceKey,
                              ),
                              StackSection(
                                key: stackKey,
                              ),
                              ContactSection(
                                key: contactKey,
                              ),
                              FooterSection(
                                key: footerKey,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
