/// Hero metric — { "value": "05", "label": "YEARS BUILDING FLUTTER" }
class HeroMetric {
  final String value;
  final String label;

  const HeroMetric({required this.value, required this.label});

  factory HeroMetric.fromJson(Map<String, dynamic> json) {
    return HeroMetric(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
    );
  }
}

/// Hero CTA button — { "label": "VIEW PROJECTS", "target": "work" }
class HeroCta {
  final String label;
  final String target; // nav section id, e.g. "work", "contact"

  const HeroCta({required this.label, required this.target});

  factory HeroCta.fromJson(Map<String, dynamic> json) {
    return HeroCta(
      label: json['label'] as String? ?? '',
      target: json['target'] as String? ?? '',
    );
  }
}

/// Hero section config.
class HeroConfig {
  final String avatarFilename;
  final String eyebrow;
  final String headline;
  final String subHeadline;
  final List<HeroMetric> metrics;
  final List<String> avatarCode;
  final HeroCta ctaPrimary;
  final HeroCta ctaSecondary;

  const HeroConfig({
    required this.avatarFilename,
    required this.eyebrow,
    required this.headline,
    required this.subHeadline,
    required this.metrics,
    required this.avatarCode,
    required this.ctaPrimary,
    required this.ctaSecondary,
  });

  factory HeroConfig.fromJson(Map<String, dynamic> json) {
    final rawMetrics = json['metrics'] as List<dynamic>? ?? [];
    final rawAvatarCode = json['avatar_code'] as List<dynamic>? ?? [];
    final rawCtaPrimary = json['cta_primary'] as Map<String, dynamic>?;
    final rawCtaSecondary = json['cta_secondary'] as Map<String, dynamic>?;

    return HeroConfig(
      avatarFilename: json['avatar_filename'] as String? ?? 'mjk_profile.dart',
      eyebrow: json['eyebrow'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      subHeadline: json['sub_headline'] as String? ?? '',
      metrics: rawMetrics
          .map((m) => HeroMetric.fromJson(m as Map<String, dynamic>))
          .toList(),
      avatarCode: rawAvatarCode.cast<String>(),
      ctaPrimary: rawCtaPrimary != null
          ? HeroCta.fromJson(rawCtaPrimary)
          : const HeroCta(label: 'VIEW PROJECTS', target: 'work'),
      ctaSecondary: rawCtaSecondary != null
          ? HeroCta.fromJson(rawCtaSecondary)
          : const HeroCta(label: 'GET IN TOUCH', target: 'contact'),
    );
  }
}

/// Now module config.
class NowConfig {
  final bool showNowModule;
  final String working;
  final String learning;
  final String? reading;
  final String openTo;
  final String lastUpdated;

  const NowConfig({
    required this.showNowModule,
    required this.working,
    required this.learning,
    this.reading,
    required this.openTo,
    required this.lastUpdated,
  });

  factory NowConfig.fromJson(Map<String, dynamic> json) {
    return NowConfig(
      showNowModule: json['show_now_module'] as bool? ?? false,
      working: json['working'] as String? ?? '',
      learning: json['learning'] as String? ?? '',
      reading: json['reading'] as String?,
      openTo: json['open_to'] as String? ?? '',
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }
}

/// Generic section config with heading + sub_line.
class SectionConfig {
  final String heading;
  final String subLine;

  const SectionConfig({required this.heading, required this.subLine});

  factory SectionConfig.fromJson(Map<String, dynamic> json) {
    return SectionConfig(
      heading: json['heading'] as String? ?? '',
      subLine: json['sub_line'] as String? ?? '',
    );
  }
}

/// Work section config.
class WorkConfig extends SectionConfig {
  final String showMoreLabel;
  final String showLessLabel;

  const WorkConfig({
    required super.heading,
    required super.subLine,
    required this.showMoreLabel,
    required this.showLessLabel,
  });

  factory WorkConfig.fromJson(Map<String, dynamic> json) {
    return WorkConfig(
      heading: json['heading'] as String? ?? 'Featured Work',
      subLine: json['sub_line'] as String? ?? '',
      showMoreLabel: json['show_more_label'] as String? ?? 'SHOW MORE PROJECTS',
      showLessLabel: json['show_less_label'] as String? ?? 'SHOW LESS',
    );
  }
}

/// Contact form field placeholders.
class FormFields {
  final String namePlaceholder;
  final String emailPlaceholder;
  final String subjectPlaceholder;
  final String messagePlaceholder;

  const FormFields({
    required this.namePlaceholder,
    required this.emailPlaceholder,
    required this.subjectPlaceholder,
    required this.messagePlaceholder,
  });

  factory FormFields.fromJson(Map<String, dynamic> json) {
    return FormFields(
      namePlaceholder: json['name_placeholder'] as String? ?? '',
      emailPlaceholder: json['email_placeholder'] as String? ?? '',
      subjectPlaceholder: json['subject_placeholder'] as String? ?? '',
      messagePlaceholder: json['message_placeholder'] as String? ?? '',
    );
  }
}

/// Contact section config.
class ContactConfig extends SectionConfig {
  final FormFields formFields;
  final String submitLabel;
  final String successPrimary;
  final String successSecondary;
  final String directNote;

  const ContactConfig({
    required super.heading,
    required super.subLine,
    required this.formFields,
    required this.submitLabel,
    required this.successPrimary,
    required this.successSecondary,
    required this.directNote,
  });

  factory ContactConfig.fromJson(Map<String, dynamic> json) {
    final rawFormFields =
        json['form_fields'] as Map<String, dynamic>?;
    return ContactConfig(
      heading: json['heading'] as String? ?? "Let's build something.",
      subLine: json['sub_line'] as String? ?? '',
      formFields: rawFormFields != null
          ? FormFields.fromJson(rawFormFields)
          : const FormFields(
              namePlaceholder: '',
              emailPlaceholder: '',
              subjectPlaceholder: '',
              messagePlaceholder: '',
            ),
      submitLabel: json['submit_label'] as String? ?? 'SEND',
      successPrimary: json['success_primary'] as String? ?? '',
      successSecondary: json['success_secondary'] as String? ?? '',
      directNote: json['direct_note'] as String? ?? '',
    );
  }
}

/// Footer config.
class FooterConfig {
  final String copyright;
  final String builtWith;

  const FooterConfig({required this.copyright, required this.builtWith});

  factory FooterConfig.fromJson(Map<String, dynamic> json) {
    return FooterConfig(
      copyright: json['copyright'] as String? ?? '',
      builtWith: json['built_with'] as String? ?? '',
    );
  }
}

/// Root site config — parsed from assets/presentation/site_config.json.
class SiteConfig {
  final HeroConfig hero;
  final NowConfig now;
  final WorkConfig work;
  final SectionConfig experience;
  final SectionConfig stack;
  final ContactConfig contact;
  final FooterConfig footer;
  final List<String> navSections;
  final Map<String, String> socialIconMap;
  final Map<String, String> projectIconMap;
  final Map<String, String> skillCategoryIconMap;

  const SiteConfig({
    required this.hero,
    required this.now,
    required this.work,
    required this.experience,
    required this.stack,
    required this.contact,
    required this.footer,
    required this.navSections,
    required this.socialIconMap,
    required this.projectIconMap,
    required this.skillCategoryIconMap,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) {
    final rawIconMap = json['iconMap'] as Map<String, dynamic>?;
    final rawProjectIcons =
        rawIconMap?['projects'] as Map<String, dynamic>? ?? {};
    final rawSkillIcons =
        rawIconMap?['skill_categories'] as Map<String, dynamic>? ?? {};
    final rawSocial =
        json['socialIconMap'] as Map<String, dynamic>? ?? {};
    final rawNavSections = json['navSections'] as List<dynamic>? ?? [];
    final rawNow = json['now'] as Map<String, dynamic>?;
    final rawWork = json['work'] as Map<String, dynamic>?;
    final rawExperience = json['experience'] as Map<String, dynamic>?;
    final rawStack = json['stack'] as Map<String, dynamic>?;
    final rawContact = json['contact'] as Map<String, dynamic>?;
    final rawFooter = json['footer'] as Map<String, dynamic>?;

    return SiteConfig(
      hero: HeroConfig.fromJson(
          json['hero'] as Map<String, dynamic>? ?? {}),
      now: rawNow != null
          ? NowConfig.fromJson(rawNow)
          : const NowConfig(
              showNowModule: false,
              working: '',
              learning: '',
              openTo: '',
              lastUpdated: '',
            ),
      work: rawWork != null
          ? WorkConfig.fromJson(rawWork)
          : const WorkConfig(
              heading: 'Featured Work',
              subLine: '',
              showMoreLabel: 'SHOW MORE PROJECTS',
              showLessLabel: 'SHOW LESS',
            ),
      experience: rawExperience != null
          ? SectionConfig.fromJson(rawExperience)
          : const SectionConfig(heading: 'Experience', subLine: ''),
      stack: rawStack != null
          ? SectionConfig.fromJson(rawStack)
          : const SectionConfig(heading: 'Stack', subLine: ''),
      contact: rawContact != null
          ? ContactConfig.fromJson(rawContact)
          : ContactConfig.fromJson(const {}),
      footer: rawFooter != null
          ? FooterConfig.fromJson(rawFooter)
          : const FooterConfig(copyright: '', builtWith: ''),
      navSections: rawNavSections.cast<String>(),
      socialIconMap: rawSocial.map((k, v) => MapEntry(k, v as String)),
      projectIconMap:
          rawProjectIcons.map((k, v) => MapEntry(k, v as String)),
      skillCategoryIconMap:
          rawSkillIcons.map((k, v) => MapEntry(k, v as String)),
    );
  }
}
