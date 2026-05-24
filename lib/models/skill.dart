/// A single skill item within a category.
class Skill {
  final String name;
  final int? yearsUsed;
  final String? proficiency;

  const Skill({
    required this.name,
    this.yearsUsed,
    this.proficiency,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] as String,
      yearsUsed: json['years_used'] as int?,
      proficiency: json['proficiency'] as String?,
    );
  }
}

/// A category of skills — parsed from assets/content/skills.json.
class SkillCategory {
  final String name;
  final List<Skill> skills;

  const SkillCategory({
    required this.name,
    required this.skills,
  });

  factory SkillCategory.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'] as List<dynamic>? ?? [];
    return SkillCategory(
      name: json['name'] as String,
      skills: rawSkills
          .map((s) => Skill.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
