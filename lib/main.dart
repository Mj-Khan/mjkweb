import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/app_colors.dart';
import 'core/app_typography.dart';
import 'data/app_data.dart';
import 'data/content_repository.dart';
import 'data/site_config_repository.dart';
import 'models/site_config.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure flutter_animate global settings.
  Animate.restartOnHotReload = true;

  ContentRepository? content;
  SiteConfig? siteConfig;
  Object? loadError;

  try {
    final results = await Future.wait([
      ContentRepository.load(),
      SiteConfigRepository.load(),
    ]);
    content = results[0] as ContentRepository;
    siteConfig = (results[1] as SiteConfigRepository).config;
    // Confirm load success in console.
    debugPrint('[App] ✓ profile: ${content.profile.name}');
    debugPrint('[App] ✓ projects: ${content.projects.length}');
    debugPrint('[App] ✓ skills: ${content.skills.length} categories');
    debugPrint('[App] ✓ experience: ${content.experience.length} roles');
    debugPrint('[App] ✓ education: ${content.education.length} qualifications');
    debugPrint('[App] ✓ site_config: hero.eyebrow="${siteConfig.hero.eyebrow}"');
  } catch (e, st) {
    loadError = e;
    debugPrint('[App] ✗ Load failed: $e\n$st');
  }

  runApp(
    _PortfolioApp(
      content: content,
      siteConfig: siteConfig,
      loadError: loadError,
    ),
  );
}

class _PortfolioApp extends StatelessWidget {
  final ContentRepository? content;
  final SiteConfig? siteConfig;
  final Object? loadError;

  const _PortfolioApp({
    this.content,
    this.siteConfig,
    this.loadError,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abdul Mujeeb Khan — Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: _buildHome(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundBase,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.backgroundBase,
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontFamily: 'Geist',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.foregroundPrimary,
        ),
      ),
      fontFamily: 'Geist',
      useMaterial3: true,
    );
  }

  Widget _buildHome() {
    // ── ERROR state ───────────────────────────────────────────────────────
    if (loadError != null) {
      return _ErrorScreen(error: loadError!);
    }

    // ── LOADED state ──────────────────────────────────────────────────────
    if (content != null && siteConfig != null) {
      return AppData(
        content: content!,
        siteConfig: siteConfig!,
        child: const HomeScreen(),
      );
    }

    // ── LOADING state (should not normally reach here since we await before
    //    runApp, but kept as safety net) ───────────────────────────────────
    return const _LoadingScreen();
  }
}

// ── Loading screen ─────────────────────────────────────────────────────────
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'initialising...',
              style: AppTypography.monoLabel.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error screen ───────────────────────────────────────────────────────────
class _ErrorScreen extends StatelessWidget {
  final Object error;

  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '// load failed',
                style: AppTypography.monoLabel.copyWith(
                  color: AppColors.foregroundSubtle,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Something went wrong loading the portfolio data.',
                style: AppTypography.body.copyWith(
                  color: AppColors.foregroundPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try refreshing the page.',
                style: AppTypography.small.copyWith(
                  color: AppColors.foregroundMuted,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                error.toString(),
                style: AppTypography.monoMeta.copyWith(
                  color: AppColors.foregroundSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
