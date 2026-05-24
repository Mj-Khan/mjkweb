import 'package:flutter/material.dart';

/// Resolves an icon name string (from site_config.json) to a [IconData].
///
/// Covers every icon name present in socialIconMap, iconMap.projects,
/// and iconMap.skill_categories. No reflection — const Map lookup only.
/// On miss: logs a debug warning and returns [Icons.circle_outlined].
abstract final class IconResolver {
  static const Map<String, IconData> _map = {
    // ── Social icons (socialIconMap) ──────────────────────────────────────
    'email_outlined': Icons.email_outlined,
    'code_rounded': Icons.code_rounded,
    'work_outline_rounded': Icons.work_outline_rounded,

    // ── Project icons (iconMap.projects) ─────────────────────────────────
    'auto_awesome_outlined': Icons.auto_awesome_outlined,
    'bar_chart_outlined': Icons.bar_chart_outlined,
    'camera_alt_outlined': Icons.camera_alt_outlined,
    'sim_card_outlined': Icons.sim_card_outlined,
    'electric_car_outlined': Icons.electric_car_outlined,
    'construction_outlined': Icons.construction_outlined,
    'mosque_outlined': Icons.mosque_outlined,
    'school_outlined': Icons.school_outlined,
    'directions_walk_outlined': Icons.directions_walk_outlined,
    'touch_app_outlined': Icons.touch_app_outlined,

    // ── Skill category icons (iconMap.skill_categories) ──────────────────
    'cloud_outlined': Icons.cloud_outlined,
    'map_outlined': Icons.map_outlined,
    'build_outlined': Icons.build_outlined,
    // 'school_outlined' already above
    // 'code_rounded'    already above

    // ── Nav / UI icons (used in side rail, top bar, modal, contact) ──────
    'home': Icons.home,
    'home_outlined': Icons.home_outlined,
    'code': Icons.code,
    'work': Icons.work,
    'work_outline': Icons.work_outline,
    'terminal': Icons.terminal,
    'terminal_outlined': Icons.terminal_outlined,
    'mail': Icons.mail,
    'mail_outlined': Icons.mail_outlined,
    'menu': Icons.menu,
    'close': Icons.close,
    'arrow_back': Icons.arrow_back,
    'open_in_new': Icons.open_in_new,
    'expand_more': Icons.expand_more,
    'expand_less': Icons.expand_less,
    'link': Icons.link,
    'location_on_outlined': Icons.location_on_outlined,
    'send': Icons.send,
    'check_circle_outline': Icons.check_circle_outline,

    // ── Modal content icons ───────────────────────────────────────────────
    'warning': Icons.warning_amber_outlined,
    'engineering': Icons.engineering,
    'calendar_today': Icons.calendar_today,
    'person': Icons.person_outline,
    'smartphone': Icons.smartphone,

    // ── Misc ──────────────────────────────────────────────────────────────
    'circle_outlined': Icons.circle_outlined,
  };

  /// Returns the [IconData] for [name], or [Icons.circle_outlined] on miss.
  static IconData iconFromName(String name) {
    final icon = _map[name];
    if (icon == null) {
      // ignore: avoid_print
      debugPrint('[IconResolver] Unknown icon name: "$name". Using fallback.');
      return Icons.circle_outlined;
    }
    return icon;
  }
}
