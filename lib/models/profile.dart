/// Profile model — parsed from assets/content/profile.json.
/// CRITICAL: phone field is intentionally NOT included to prevent it from
/// ever reaching the UI layer.
class Profile {
  final String name;
  final String tagline;
  final String shortSummary;
  final String longSummary;
  final String location;
  final String? availableFor;
  final String email;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  // phone is NEVER parsed — it must not appear in the DOM anywhere.

  const Profile({
    required this.name,
    required this.tagline,
    required this.shortSummary,
    required this.longSummary,
    required this.location,
    this.availableFor,
    required this.email,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] as String,
      tagline: json['tagline'] as String? ?? '',
      shortSummary: json['short_summary'] as String? ?? '',
      longSummary: json['long_summary'] as String? ?? '',
      location: json['location'] as String? ?? '',
      availableFor: json['available_for'] as String?,
      email: json['email'] as String? ?? '',
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      // 'phone' is deliberately not read.
    );
  }
}
