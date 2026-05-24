/// A work experience role — parsed from assets/content/experience.json.
class ExperienceRole {
  final String id;
  final String company;
  final String title;
  final String? location;
  final String? workMode;
  final String startDate;
  final String? endDate;
  final String? contextLine;
  final List<String> bullets;

  const ExperienceRole({
    required this.id,
    required this.company,
    required this.title,
    this.location,
    this.workMode,
    required this.startDate,
    this.endDate,
    this.contextLine,
    required this.bullets,
  });

  /// True when this role is the current position.
  bool get isPresent => endDate == null || endDate == 'Present';

  factory ExperienceRole.fromJson(Map<String, dynamic> json) {
    final rawBullets = json['bullets'] as List<dynamic>? ?? [];
    return ExperienceRole(
      id: json['id'] as String,
      company: json['company'] as String,
      title: json['title'] as String,
      location: json['location'] as String?,
      workMode: json['work_mode'] as String?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      contextLine: json['context_line'] as String?,
      bullets: rawBullets.cast<String>(),
    );
  }
}
