/// A typed project link — e.g. { "type": "play_store", "url": "..." }
class ProjectLink {
  final String type;
  final String url;

  const ProjectLink({required this.type, required this.url});

  factory ProjectLink.fromJson(Map<String, dynamic> json) {
    return ProjectLink(
      type: json['type'] as String,
      url: json['url'] as String,
    );
  }
}

/// Play Store (and other store) metadata — nullable on the Project.
class StoreMetadata {
  final double? rating;
  final int? reviewCount;
  final String? downloadsLabel;
  final String? lastUpdated;
  final String? developer;

  const StoreMetadata({
    this.rating,
    this.reviewCount,
    this.downloadsLabel,
    this.lastUpdated,
    this.developer,
  });

  factory StoreMetadata.fromJson(Map<String, dynamic> json) {
    return StoreMetadata(
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
      downloadsLabel: json['downloads_label'] as String?,
      lastUpdated: json['last_updated'] as String?,
      developer: json['developer'] as String?,
    );
  }
}

/// Project images bundle.
class ProjectImages {
  final String? hero;
  final String? thumbnail;
  final List<String> screenshots;

  const ProjectImages({
    this.hero,
    this.thumbnail,
    required this.screenshots,
  });

  factory ProjectImages.fromJson(Map<String, dynamic> json) {
    final rawScreenshots = json['screenshots'] as List<dynamic>? ?? [];
    return ProjectImages(
      hero: json['hero'] as String?,
      thumbnail: json['thumbnail'] as String?,
      screenshots: rawScreenshots.cast<String>(),
    );
  }
}

/// Project — parsed from assets/content/projects.json.
///
/// status == "details_pending" means all optional prose fields are null and
/// [isClickable] is false. The model must not throw on any null field.
class Project {
  final String id;
  final String name;
  final String? tagline;
  final bool featured;
  final String? company;
  final String? client;
  final String? startDate;
  final String? endDate;
  final String status;

  // Prose — all nullable; null on details_pending projects.
  final String? shortDescription;
  final String? longDescription;
  final String? problemSolved;
  final String? roleSummary;
  final List<String> contributionBullets;
  final List<String> techStack;
  final List<ProjectLink> links;
  final StoreMetadata? storeMetadata;
  final List<String> tags;
  final ProjectImages images;

  const Project({
    required this.id,
    required this.name,
    this.tagline,
    required this.featured,
    this.company,
    this.client,
    this.startDate,
    this.endDate,
    required this.status,
    this.shortDescription,
    this.longDescription,
    this.problemSolved,
    this.roleSummary,
    required this.contributionBullets,
    required this.techStack,
    required this.links,
    this.storeMetadata,
    required this.tags,
    required this.images,
  });

  /// Whether the user can tap/click this card to open the modal.
  bool get isClickable => status != 'details_pending';

  /// Whether this role is ongoing ("Present" or null end_date).
  /// Used for sort ordering — "Present" sorts LATEST; never compare lexically.
  bool get isPresent => endDate == null || endDate == 'Present';

  /// Returns a comparable [DateTime] for sort ordering.
  /// "Present" maps to the maximum possible date (year 9999) so it sorts first.
  DateTime get sortableEndDate {
    if (isPresent) return DateTime(9999, 12, 31);
    // Format: "YYYY-MM"
    final parts = endDate!.split('-');
    if (parts.length >= 2) {
      return DateTime(int.parse(parts[0]), int.parse(parts[1]));
    }
    // Fallback: treat as year only
    return DateTime(int.tryParse(endDate!) ?? 0);
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    final rawBullets = json['contribution_bullets'] as List<dynamic>? ?? [];
    final rawTechStack = json['tech_stack'] as List<dynamic>? ?? [];
    final rawLinks = json['links'] as List<dynamic>? ?? [];
    final rawTags = json['tags'] as List<dynamic>? ?? [];
    final rawImages = json['images'] as Map<String, dynamic>?;
    final rawStoreMeta = json['store_metadata'] as Map<String, dynamic>?;

    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      tagline: json['tagline'] as String?,
      featured: json['featured'] as bool? ?? false,
      company: json['company'] as String?,
      client: json['client'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String? ?? 'unknown',
      shortDescription: json['short_description'] as String?,
      longDescription: json['long_description'] as String?,
      problemSolved: json['problem_solved'] as String?,
      roleSummary: json['role_summary'] as String?,
      contributionBullets: rawBullets.cast<String>(),
      techStack: rawTechStack.cast<String>(),
      links: rawLinks
          .map((l) => ProjectLink.fromJson(l as Map<String, dynamic>))
          .toList(),
      storeMetadata:
          rawStoreMeta != null ? StoreMetadata.fromJson(rawStoreMeta) : null,
      tags: rawTags.cast<String>(),
      images: rawImages != null
          ? ProjectImages.fromJson(rawImages)
          : const ProjectImages(screenshots: []),
    );
  }
}
