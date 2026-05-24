import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/site_config.dart';

/// Loads site_config.json and returns a typed [SiteConfig].
class SiteConfigRepository {
  final SiteConfig config;

  const SiteConfigRepository._({required this.config});

  static Future<SiteConfigRepository> load() async {
    final raw =
        await rootBundle.loadString('assets/presentation/site_config.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return SiteConfigRepository._(config: SiteConfig.fromJson(json));
  }
}
