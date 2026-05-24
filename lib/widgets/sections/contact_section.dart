import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_colors.dart';
import '../../core/app_radius.dart';
import '../../core/app_spacing.dart';
import '../../core/app_typography.dart';
import '../../core/breakpoints.dart';
import '../../core/icon_resolver.dart';
import '../../core/motion.dart';
import '../../data/app_data.dart';
import '../../models/profile.dart';
import '../../models/site_config.dart';

/// High-fidelity, fully responsive Contact Section.
/// Renders as a 2-column layout on desktop/tablet (Form 60% / Direct Contacts 40%)
/// and stacks vertically on mobile (Form first, Direct Contacts below).
class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  void _launchUrl(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final contactConfig = appData.siteConfig.contact;
    final profile = appData.content.profile;
    final isMobile = context.isMobile;

    // Contact Column Content
    final formColumn = ContactForm(
      contactConfig: contactConfig,
      email: profile.email,
    );

    final directColumn = _DirectContactsBlock(
      profile: profile,
      socialIconMap: appData.siteConfig.socialIconMap,
      onLaunch: _launchUrl,
    );

    Widget content;
    if (isMobile) {
      // Mobile Layout: Stacks Form then Direct Contacts
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          formColumn,
          const SizedBox(height: 48),
          directColumn,
        ],
      );
    } else {
      // Desktop / Tablet Layout: Asymmetric Column Split (60% / 40%)
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left 60%: Form
          Expanded(
            flex: 60,
            child: formColumn,
          ),
          const SizedBox(width: 48),
          // Right 40%: Direct Contacts
          Expanded(
            flex: 40,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0), // Aligns with first field input line
              child: directColumn,
            ),
          ),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
      ),
      padding: AppSpacing.sectionPadding(isMobile: isMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section Title block ───────────────────────────────────────────
          RevealAnimation(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '// ${contactConfig.heading.toUpperCase()}',
                  style: AppTypography.monoLabel.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  contactConfig.subLine,
                  style: AppTypography.sectionHeading(isMobile: isMobile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // ── Responsive columns content ────────────────────────────────────
          content,
        ],
      ),
    );
  }
}

/// Dynamic contact form displaying placeholders, handling inputs,
/// displaying inline error messages, and launching mail client under a native mailto.
class ContactForm extends StatefulWidget {
  final ContactConfig contactConfig;
  final String email;

  const ContactForm({
    super.key,
    required this.contactConfig,
    required this.email,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _subjectError;
  String? _messageError;

  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'EMAIL REQUIRED';
    if (!value.contains('@') || !value.contains('.')) {
      return 'INVALID EMAIL FORMAT';
    }
    return null;
  }

  void _submitForm() async {
    // 1. Run local validations
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'NAME REQUIRED' : null;
      _emailError = _validateEmail(_emailController.text.trim());
      _subjectError = _subjectController.text.trim().isEmpty ? 'SUBJECT REQUIRED' : null;
      _messageError = _messageController.text.trim().isEmpty ? 'MESSAGE REQUIRED' : null;
    });

    // 2. Halt if invalid
    if (_nameError != null || _emailError != null || _subjectError != null || _messageError != null) {
      return;
    }

    // 3. Build pre-formatted, URL-encoded mailto structure
    final nameEncoded = Uri.encodeComponent(_nameController.text.trim());
    final subjectEncoded = Uri.encodeComponent(_subjectController.text.trim());
    final messageEncoded = Uri.encodeComponent(_messageController.text.trim());

    final mailtoUrl =
        'mailto:${widget.email}?subject=[site contact] $subjectEncoded&body=From: $nameEncoded%0A%0A$messageEncoded';

    final uri = Uri.tryParse(mailtoUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.contactConfig.formFields;

    if (_isSubmitted) {
      // Success State - replaces the form completely
      return RevealAnimation(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.contactConfig.successPrimary,
              style: AppTypography.subsection.copyWith(
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.contactConfig.successSecondary,
              style: AppTypography.withColor(
                AppTypography.body,
                AppColors.foregroundMuted,
              ),
            ),
          ],
        ),
      );
    }

    return RevealAnimation(
      delay: const Duration(milliseconds: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          ContactTextField(
            placeholder: fields.namePlaceholder,
            controller: _nameController,
            errorText: _nameError,
          ),
          const SizedBox(height: 32),

          // Email field
          ContactTextField(
            placeholder: fields.emailPlaceholder,
            controller: _emailController,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),

          // Subject field
          ContactTextField(
            placeholder: fields.subjectPlaceholder,
            controller: _subjectController,
            errorText: _subjectError,
          ),
          const SizedBox(height: 32),

          // Message field
          ContactTextField(
            placeholder: fields.messagePlaceholder,
            controller: _messageController,
            errorText: _messageError,
            isMultiline: true,
          ),
          const SizedBox(height: 32),

          // Submit Button row (right-aligned)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _SubmitButton(
                label: widget.contactConfig.submitLabel,
                onTap: _submitForm,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Direct Note comment line below form
          Text(
            widget.contactConfig.directNote,
            style: AppTypography.monoMeta.copyWith(
              color: AppColors.foregroundSubtle,
              fontSize: 11.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom, clean text field with transparent fill, dynamic bottom border on focus,
/// and error rendering in AppColors.error (warm red).
class ContactTextField extends StatefulWidget {
  final String placeholder;
  final TextEditingController controller;
  final String? errorText;
  final bool isMultiline;
  final TextInputType keyboardType;

  const ContactTextField({
    super.key,
    required this.placeholder,
    required this.controller,
    this.errorText,
    this.isMultiline = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<ContactTextField> createState() => _ContactTextFieldState();
}

class _ContactTextFieldState extends State<ContactTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          maxLines: widget.isMultiline ? null : 1,
          minLines: widget.isMultiline ? 4 : 1,
          cursorColor: AppColors.accent,
          style: const TextStyle(
            fontFamily: 'IBM Plex Mono',
            fontSize: 13.0,
            color: AppColors.foregroundPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(
              fontFamily: 'IBM Plex Mono',
              fontSize: 13.0,
              color: AppColors.foregroundSubtle,
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        // Bottom border transitions color on focus
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 1.0,
          color: _isFocused ? AppColors.accent : AppColors.borderDefault,
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: AppTypography.monoMeta.copyWith(
              color: AppColors.error,
              fontSize: 11.0,
            ),
          ),
        ],
      ],
    );
  }
}

/// Coordinated list block for Direct Contacts.
class _DirectContactsBlock extends StatelessWidget {
  final Profile profile;
  final Map<String, String> socialIconMap;
  final ValueChanged<String> onLaunch;

  const _DirectContactsBlock({
    required this.profile,
    required this.socialIconMap,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve Dynamic Icons
    final emailIconName = socialIconMap['email'] ?? 'mail_outlined';
    final emailIcon = IconResolver.iconFromName(emailIconName);

    final githubIconName = socialIconMap['github'] ?? 'code_rounded';
    final githubIcon = IconResolver.iconFromName(githubIconName);

    final linkedinIconName = socialIconMap['linkedin'] ?? 'work_outline_rounded';
    final linkedinIcon = IconResolver.iconFromName(linkedinIconName);

    // Location uses outline from resolver
    final locationIcon = IconResolver.iconFromName('location_on_outlined');

    return RevealAnimation(
      delay: const Duration(milliseconds: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Row
          DirectContactRow(
            icon: emailIcon,
            label: 'EMAIL',
            value: profile.email,
            onTap: () => onLaunch('mailto:${profile.email}'),
          ),
          const SizedBox(height: 24),

          // GitHub Row
          if (profile.githubUrl != null) ...[
            DirectContactRow(
              icon: githubIcon,
              label: 'GITHUB',
              value: profile.githubUrl!.replaceAll('https://', ''),
              onTap: () => onLaunch(profile.githubUrl!),
            ),
            const SizedBox(height: 24),
          ],

          // LinkedIn Row
          if (profile.linkedinUrl != null) ...[
            DirectContactRow(
              icon: linkedinIcon,
              label: 'LINKEDIN',
              value: profile.linkedinUrl!.replaceAll('https://www.', '').replaceAll('https://', ''),
              onTap: () => onLaunch(profile.linkedinUrl!),
            ),
            const SizedBox(height: 24),
          ],

          // Location Row (Unclickable, no hover)
          DirectContactRow(
            icon: locationIcon,
            label: 'LOCATION',
            value: profile.location,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

/// Individual Direct Contact row exhibiting a left-sliding accent border on desktop hover.
class DirectContactRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const DirectContactRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  State<DirectContactRow> createState() => _DirectContactRowState();
}

class _DirectContactRowState extends State<DirectContactRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.onTap != null;

    return MouseRegion(
      onEnter: (_) {
        if (canTap) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (canTap) setState(() => _isHovered = false);
      },
      cursor: canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent, // no fill changes on hover
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 2px Matrix Emerald accent left-border slides in (AnimatedContainer)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 2.0,
                height: 38.0,
                color: _isHovered ? AppColors.accent : Colors.transparent,
              ),
              const SizedBox(width: 14),
              Icon(
                widget.icon,
                size: 20,
                color: AppColors.accent,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: AppTypography.monoLabel.copyWith(
                        fontSize: 9.0,
                        color: AppColors.foregroundSubtle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: AppTypography.withColor(
                        AppTypography.body,
                        AppColors.foregroundPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive SEND submit button.
class _SubmitButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.accentBright : AppColors.accent,
            borderRadius: AppRadius.button,
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: AppTypography.monoLabel.copyWith(
              color: AppColors.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}
