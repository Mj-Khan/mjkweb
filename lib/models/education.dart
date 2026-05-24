/// Education qualification — parsed from assets/content/education.json.
class Education {
  final String id;
  final String degree;
  final String institution;
  final String? location;
  final String? startDate;
  final String? endDate;
  final String status;

  const Education({
    required this.id,
    required this.degree,
    required this.institution,
    this.location,
    this.startDate,
    this.endDate,
    required this.status,
  });

  bool get isInProgress => status == 'in_progress';

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'] as String,
      degree: json['degree'] as String,
      institution: json['institution'] as String,
      location: json['location'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String? ?? 'completed',
    );
  }
}
