import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/profile.dart';
import '../models/skill.dart';
import '../models/experience.dart';
import '../models/project.dart';
import '../models/education.dart';

/// Loads all content JSON files and exposes typed lists.
/// Call [load] once at app start; the result is immutable.
class ContentRepository {
  final Profile profile;
  final List<SkillCategory> skills;
  final List<ExperienceRole> experience;
  final List<Project> projects;
  final List<Education> education;

  const ContentRepository._({
    required this.profile,
    required this.skills,
    required this.experience,
    required this.projects,
    required this.education,
  });

  // ── Derived project lists ────────────────────────────────────────────────

  /// Featured projects (featured == true), sorted end_date DESC.
  /// "Present" always sorts as the latest date — no lexical comparison.
  List<Project> get featuredProjects {
    final featured = projects.where((p) => p.featured).toList();
    featured.sort((a, b) => b.sortableEndDate.compareTo(a.sortableEndDate));
    return featured;
  }

  /// Non-featured projects, same sort order.
  List<Project> get supportingProjects {
    final supporting = projects.where((p) => !p.featured).toList();
    supporting.sort((a, b) => b.sortableEndDate.compareTo(a.sortableEndDate));
    return supporting;
  }

  // ── Factory ──────────────────────────────────────────────────────────────

  static Future<ContentRepository> load() async {
    final results = await Future.wait([
      rootBundle.loadString('assets/content/profile.json'),
      rootBundle.loadString('assets/content/skills.json'),
      rootBundle.loadString('assets/content/experience.json'),
      rootBundle.loadString('assets/content/projects.json'),
      rootBundle.loadString('assets/content/education.json'),
    ]);

    final profileJson =
        jsonDecode(results[0]) as Map<String, dynamic>;
    final skillsJson =
        jsonDecode(results[1]) as Map<String, dynamic>;
    final experienceJson =
        jsonDecode(results[2]) as Map<String, dynamic>;
    final projectsJson =
        jsonDecode(results[3]) as Map<String, dynamic>;
    final educationJson =
        jsonDecode(results[4]) as Map<String, dynamic>;

    final rawSkillCats =
        skillsJson['categories'] as List<dynamic>? ?? [];
    final rawRoles =
        experienceJson['roles'] as List<dynamic>? ?? [];
    final rawProjects =
        projectsJson['projects'] as List<dynamic>? ?? [];
    final rawQuals =
        educationJson['qualifications'] as List<dynamic>? ?? [];

    return ContentRepository._(
      profile: Profile.fromJson(profileJson),
      skills: rawSkillCats
          .map((c) => SkillCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      experience: rawRoles
          .map((r) => ExperienceRole.fromJson(r as Map<String, dynamic>))
          .toList(),
      projects: rawProjects
          .map((p) => Project.fromJson(p as Map<String, dynamic>))
          .toList(),
      education: rawQuals
          .map((q) => Education.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
