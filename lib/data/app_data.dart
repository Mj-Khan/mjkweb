import 'package:flutter/widgets.dart';

import '../data/content_repository.dart';
import '../models/site_config.dart';

/// Provides loaded content + site config to the entire widget tree.
///
/// Data is immutable after load — [updateShouldNotify] always returns false.
/// Access via [AppData.of(context)].
class AppData extends InheritedWidget {
  final ContentRepository content;
  final SiteConfig siteConfig;

  const AppData({
    super.key,
    required this.content,
    required this.siteConfig,
    required super.child,
  });

  /// Returns the nearest [AppData] ancestor.
  /// Throws if not found (indicates a wiring bug).
  static AppData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<AppData>();
    assert(data != null, 'No AppData found in widget tree.');
    return data!;
  }

  /// Data is immutable after load; no rebuild needed when widget is replaced.
  @override
  bool updateShouldNotify(AppData oldWidget) => false;
}
