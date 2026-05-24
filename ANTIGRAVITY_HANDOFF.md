# Flutter Web Portfolio — Antigravity Build Handoff

**Project folder:** `mjkweb`
**Stack:** Flutter Web (responsive), JSON-driven
**Builder:** Google Antigravity (writes files, runs `flutter analyze` itself)
**Design source:** Google Stitch — project "Terminal Precision Portfolio (SPA)", fetched via the Stitch MCP **connected inside Antigravity**
**Deploy target:** `https://mj-khan.github.io/` (GitHub repo must be named `mj-khan.github.io`, base-href `/`)
**Build approach:** Foundation first, section by section, hero as the reference pattern

> The local folder is `mjkweb`; the GitHub repo (created later, in Step 8) must
> be `mj-khan.github.io`. The two names do not need to match.

---

## HOW TO USE THIS DOCUMENT

This is a **sequenced build guide for Antigravity**. Each numbered STEP is a
separate instruction you paste into Antigravity. Do not paste the next step
until Antigravity has completed the current one, run `flutter analyze`, and you
have reviewed the result. Each step depends on the previous one being correct.

- **STEP 0** — MCP connection test, design read (or screenshot fallback), token reconciliation, 5 core Dart files
- **STEP 1** — Data layer, models, repositories, responsive scaffold
- **STEP 2** — Hero section (the reference pattern — get this right before continuing)
- **STEP 3** — Work section (featured grid + supporting grid + modal)
- **STEP 4** — Experience section
- **STEP 5** — Stack + Now section
- **STEP 6** — Contact section + footer
- **STEP 7** — Navigation (side rail + mobile top bar) + scroll wiring
- **STEP 8** — Deploy config + final QA

This file lives in the repo as passive reference. The pasted context prompt +
each pasted step are the active instructions. If this file and the pasted chat
ever conflict, the chat wins.

---

## PRE-FLIGHT — STATUS

All pre-flight tasks are DONE:

- [x] `flutter create mjkweb --platforms web` — project exists, counter app ran.
- [x] 5 content JSON files present in `assets/content/`
      (profile, skills, experience, projects, education).
- [x] `assets/presentation/site_config.json` present, final content
      (includes `now`, `show_now_module`, `hero.avatar_code`, and section copy).
- [x] Fonts (Geist 400/600/700, IBM Plex Mono 400/500) in `assets/fonts/`,
      declared in pubspec with family names exactly `Geist` and `IBM Plex Mono`.
- [x] pubspec asset declarations: `assets/content/`, `assets/presentation/`.
- [x] Stitch MCP connected inside Antigravity.

Nothing to add before starting. Begin at STEP 0.

> Fonts: if Geist ever fails to bundle at runtime, allow a `google_fonts`
> fallback for both families (note: causes a brief flash of unstyled text).

---

## FIXED ARCHITECTURE — DO NOT PROPOSE ALTERNATIVES

```
lib/
  models/         profile.dart, skill.dart, experience.dart,
                  project.dart, education.dart, site_config.dart
  data/           content_repository.dart, site_config_repository.dart,
                  app_data.dart (InheritedWidget)
  core/           app_colors.dart, app_typography.dart, app_spacing.dart,
                  app_radius.dart, breakpoints.dart, icon_resolver.dart, motion.dart
  widgets/        (one file per section + shared components)
  screens/        home_screen.dart
  main.dart

assets/
  content/        profile.json, skills.json, experience.json,
                  projects.json, education.json
  presentation/   site_config.json
  fonts/          Geist + IBM Plex Mono .ttf files
```

**State:** `setState` for local UI (modal open/close, expand toggles, form
fields) + `AppData` InheritedWidget for loaded JSON data. **NO Provider. NO
Riverpod. NO Bloc.**

**Animation:** `flutter_animate` for scroll reveals, staggers, modal scale-in.
Hand-roll the blinking cursor and the metric count-up.

**Data loading:** In `main()`, `ensureInitialized`, load all 6 JSON files via
`rootBundle.loadString`, parse, then `runApp` wrapped in `AppData`. Branded
loading screen. Graceful dark error screen (never a red Flutter error screen).

**No routing.** Single page, scroll + anchor navigation only. No `go_router`.

---

## SOURCE-OF-TRUTH RULE (when values conflict)

- **Stitch design (via MCP)** OR **screenshots (fallback)** -> authoritative for **layout & structure**.
- **The token table below** -> authoritative for **all visual values**. If the design shows a different hex or size, the token table wins.
- **The JSON files** -> authoritative for **all facts**.
- Design element with no JSON field -> **flag it** in the reconciliation report. Do not invent, do not silently drop.

---

## JSON KEY NAMES — USE THESE EXACT KEYS (do not rename anything)

**Build the Dart models to match these keys exactly. These are the real keys
in the project's JSON — they are ground truth.**

`projects.json` per project:

```
id, name, tagline, featured (bool), company, client (nullable),
start_date, end_date ("YYYY-MM" or "Present"), status,
short_description, long_description, problem_solved, role_summary,
contribution_bullets (list), tech_stack (list),
links (list of {type, url}),
store_metadata (nullable {rating, review_count, downloads_label,
                last_updated, developer}),
tags (list), images ({hero, thumbnail, screenshots})
```

- **Card preview** uses `short_description`.
- **Modal** uses: `long_description` (or `problem_solved`) for "The problem",
  `role_summary` for "My role", `contribution_bullets` for "What I built",
  `tech_stack` for "Stack", `store_metadata` for the stats row, `links` for the
  Play Store button.
- `status == "details_pending"` -> tagline/dates/descriptions null,
  `contribution_bullets` [], `tech_stack` [], `links` []. Must not throw.
  `isClickable = status != "details_pending"`. These render at 60% opacity,
  not clickable, "COMING SOON" instead of "READ MORE", NO modal ever.
- `end_date == "Present"` sorts as the LATEST date — handle explicitly, never
  lexically compare "Present" against "YYYY-MM" (P < 2 breaks it).

`site_config.json` keys:

```
hero {eyebrow, headline, sub_headline, metrics [{value,label}],
      avatar_code [lines], cta_primary {label,target}, cta_secondary {label,target}}
now {show_now_module (bool), working, learning, reading (nullable),
     open_to, last_updated}
stack {heading, sub_line}
work {heading, sub_line, show_more_label, show_less_label}
experience {heading, sub_line}
contact {heading, sub_line, form_fields {name_placeholder, email_placeholder,
         subject_placeholder, message_placeholder}, submit_label,
         success_primary, success_secondary, direct_note}
footer {copyright, built_with}
navSections [list]
socialIconMap {email, github, linkedin -> icon name}
iconMap {projects {id -> icon name}, skill_categories {category name -> icon name}}
```

**CRITICAL:** `profile.json` contains a phone number. It must NEVER render
anywhere in the DOM — not in text, comments, tooltips, or aria-labels. The
contact section uses email + socials only.

---

## DESIGN TOKENS — TERMINAL PRECISION (AUTHORITATIVE)

### Colors

| Token              | Hex / Value      |
| ------------------ | ---------------- |
| background-base    | #131313          |
| surface-low        | #1c1b1b          |
| surface            | #201f1f          |
| surface-high       | #2a2a2a          |
| surface-highest    | #353534          |
| foreground-primary | #e5e2e1          |
| foreground-muted   | #bdcac0          |
| foreground-subtle  | #87948b          |
| accent             | #6bdbab          |
| accent-bright      | #88f8c6          |
| accent-dim         | #41b487          |
| on-accent          | #003826          |
| border-default     | #3d4943          |
| border-hover       | #6bdbab          |
| border-strong      | #87948b          |
| modal-scrim        | rgba(8,8,8,0.85) |

**Rules:** ONE accent (#6bdbab), no other hue. No glassmorphism. No
backdrop-blur except modal-scrim. No drop shadows — depth via tonal layering +
1px hairline borders. Dark only.

### Typography

| Token           | Desktop | Mobile | Family        | Weight | LH   | Tracking         |
| --------------- | ------- | ------ | ------------- | ------ | ---- | ---------------- |
| hero-headline   | 80px    | 52px   | Geist         | 700    | 1.05 | -0.03em          |
| section-heading | 48px    | 34px   | Geist         | 600    | 1.10 | -0.02em          |
| subsection      | 28px    | 28px   | Geist         | 600    | 1.20 | —                |
| card-title      | 22px    | 22px   | Geist         | 600    | 1.30 | —                |
| modal-title     | 40px    | 32px   | Geist         | 700    | 1.10 | —                |
| body-large      | 18px    | 18px   | Geist         | 400    | 1.60 | —                |
| body            | 16px    | 16px   | Geist         | 400    | 1.60 | —                |
| small           | 14px    | 14px   | Geist         | 400    | 1.50 | —                |
| mono-label      | 12px    | 12px   | IBM Plex Mono | 500    | —    | 0.05em UPPERCASE |
| mono-meta       | 13px    | 13px   | IBM Plex Mono | 400    | —    | —                |
| mono-numeral    | 40px    | 40px   | IBM Plex Mono | 500    | —    | —                |
| mono-stat       | 28px    | 28px   | IBM Plex Mono | 500    | —    | —                |

**Rules:** all uppercase labels = IBM Plex Mono 500, 0.05em. Never hero < 52px.

### Spacing (base 4px)

xs:4 / sm:8 / md:16 / lg:24 / xl:40 / 2xl:64 / 3xl:96
container-max 1200 / gutter 24/20 / section pad 96/64 / card pad 24/20 / modal pad 48/24

### Radius

button/input 8 / card/modal 16 / pill 6 / accent-dot 0

### Breakpoints

mobile < 768 / tablet 768-1024 / desktop > 1024

### Motion

| Interaction     | Spec                                                                |
| --------------- | ------------------------------------------------------------------- |
| page-load       | 20px up + fade, 400ms ease-out, 40ms stagger                        |
| scroll-reveal   | 16px up + fade at 20% in-view, 500ms ease-out, one-shot (no replay) |
| hover           | 200ms ease-out, border->accent, 2px lift, NO shadow, NO scale       |
| modal-open      | scrim fade 300ms + panel scale 96%->100% + opacity 350ms ease-out   |
| modal-close     | reverse, 250ms ease-in                                              |
| blinking cursor | 1ch wide, accent, 1.2s cycle, hand-rolled AnimationController       |

**Reduced motion:** if `MediaQuery.disableAnimations` -> skip entrances +
count-up (show final state), static/no cursor.

---

# STEP 0 — MCP CONNECTION TEST, DESIGN READ, RECONCILIATION, CORE FILES

> Paste this first. The 6 JSON files live in the project — Antigravity reads
> them from disk (no inline pasting). Antigravity does NOT build any UI here.

```
We are building a personal portfolio as a responsive Flutter WEB app, deployed
to GitHub Pages at https://mj-khan.github.io/ (repo "mj-khan.github.io",
base-href "/"). Local project folder is "mjkweb". Sequenced build — one step
at a time. This step: test the Stitch MCP, read the design (or fall back to
screenshots), reconcile against the JSON, produce 5 core Dart files. Do NOT
build any UI. Acknowledge, do the tasks, then STOP and wait for STEP 1.

================================================================
PROJECT FACTS
================================================================
- Flutter web only, responsive. Single page, no routing, scroll + anchor nav.
- Content JSON-driven, loaded at runtime via rootBundle.
- Deploy: GitHub Pages root repo (mj-khan.github.io), base-href "/".

================================================================
ARCHITECTURE (FIXED — do not propose alternatives)
================================================================
Two data layers:
  CONTENT (facts): assets/content/ -> profile, skills, experience, projects, education .json
  PRESENTATION (UI config): assets/presentation/site_config.json
Folders:
  lib/models/  profile, skill, experience, project, education, site_config (hand-written fromJson)
  lib/data/    content_repository, site_config_repository, app_data (InheritedWidget)
  lib/core/    app_colors, app_typography, app_spacing, app_radius, breakpoints, icon_resolver, motion
  lib/widgets/ (sections + components — later)
  lib/screens/ home_screen.dart
  lib/main.dart
State: setState + AppData InheritedWidget. NO Provider/Riverpod/Bloc.
Animation: flutter_animate. Hand-roll cursor + count-up. No routing.

================================================================
TASK 1 — TEST THE STITCH MCP CONNECTION (DO THIS FIRST)
================================================================
1. List the tools available from the Stitch MCP and report them.
2. List Stitch projects, find "Terminal Precision Portfolio (SPA)" (or closest
   match). Report what you find.

IF the Stitch tools are NOT available, OR listing fails, OR no matching project:
  -> STOP using the MCP. Report it clearly and ask me:
    "MCP unavailable — please provide screenshots of the design artboards
     (desktop home, mobile home, modal) so I can read layout from those."
  -> Do NOT fabricate a design. Wait for screenshots, then continue Task 2
    using them as the layout source.
IF the MCP works: proceed to Task 2 using it.

================================================================
TASK 2 — READ THE DESIGN, PRODUCE A DESIGN BRIEF
================================================================
Read the screen design (via MCP, or screenshots if you fell back). Produce a
structured DESIGN BRIEF that stays in our conversation as the layout reference
for every later step. Token table is authoritative for sizes/colors.
Cover, in order:
  a) OVERALL STRUCTURE — every section in order (Hero, Work, Experience,
     Stack+Now, Contact, Footer) + any unexpected section.
  b) HERO — column layout per breakpoint, left vs right content, metrics +
     labels, CTA labels, eyebrow.
  c) WORK — featured grid columns per breakpoint, fields each featured card
     shows, supporting grid layout, modal panel width + content blocks in order.
  d) EXPERIENCE — card layout, fields shown, expand/collapse behavior.
  e) STACK + NOW — column split, skill category layout, Now module fields.
  f) CONTACT — form layout, field count + labels, direct-contact rows.
  g) NAVIGATION — side rail (desktop), top bar (mobile), active-state treatment.
  h) FOOTER — column layout, text.
  i) Any element with no backing JSON field — flag each.

================================================================
TASK 3 — RECONCILIATION REPORT
================================================================
Read the 6 JSON files directly from the project:
  assets/content/profile.json
  assets/content/skills.json
  assets/content/experience.json
  assets/content/projects.json
  assets/content/education.json
  assets/presentation/site_config.json

NOTE ON KEY NAMES (use these EXACT keys, do not rename):
  projects.json modal fields are short_description (card preview),
  long_description, problem_solved, role_summary, contribution_bullets,
  tech_stack, store_metadata (nullable), links, tags, images.
  (They are NOT named "problem" or "role_detail" — match the real keys.)

Produce a RECONCILIATION REPORT:
  A) MISSING FIELDS — any design element with no backing JSON field. Name it;
     say whether it belongs in content JSON (a fact) or site_config (UI copy).
     Do not invent, do not drop.
  B) KEY CONFLICTS — any site_config value conflicting with the token table.
     State which you'll use (token table wins visual values; JSON wins facts).
  C) MODAL PROSE CHECK — confirm projects.json contains long_description,
     problem_solved, role_summary, contribution_bullets for EACH featured
     project (svarupa, zetsim, split-ev, super-construct). List any missing.
  D) STATUS PROJECTS — list status == "details_pending" (feet-first,
     magic-shake). Confirm they render at 60% opacity, not clickable, "COMING SOON".

================================================================
TASK 4 — PRODUCE 5 CORE DART FILES (token source of truth)
================================================================
Use the authoritative token values.
  lib/core/app_colors.dart   — const Color per token (backgroundBase, surfaceLow,
    accent, accentBright, accentDim, onAccent, modalScrim=Color.fromRGBO(8,8,8,0.85),
    etc.) + a vignette helper (RadialGradient/BoxDecoration).
  lib/core/app_typography.dart — TextStyle getter per type token; bool isMobile
    where sizes differ; font families exactly "Geist" / "IBM Plex Mono".
  lib/core/app_spacing.dart  — const doubles (xs..threeXl), containerMaxWidth=1200,
    gutterDesktop=24/gutterMobile=20, section/card/modal paddings.
  lib/core/app_radius.dart   — radiusButton=8, radiusCard=16, radiusPill=6,
    radiusAccentDot=0 + BorderRadius getters.
  lib/core/breakpoints.dart  — mobile=768, desktop=1024; BuildContext extension
    (isMobile/isTablet/isDesktop) via MediaQuery width; responsive<T> helper.

Then STOP. No widgets. Wait for STEP 1.
```

---

# STEP 1 — FOUNDATION: DATA LAYER + SCAFFOLD

> Paste after resolving every item in the Step 0 reconciliation report.

```
STEP 1 — Build the data layer and an empty responsive scaffold. No section UI.

1. MODELS (lib/models/) — hand-written fromJson, null-safe, optional fields
   nullable. Match the ACTUAL JSON keys (use exact names — e.g. problem_solved,
   role_summary, short_description, long_description). Models: Profile,
   SkillCategory, ExperienceRole, Project, Education, SiteConfig.
   - Project: status=="details_pending" -> optional fields null, no throw.
     isClickable = status != "details_pending". isPresent = end_date=="Present"
     || end_date==null.
   - StoreMetadata: nested nullable model.
   - Links: typed {type, url}, never bare strings.

2. REPOSITORIES (lib/data/)
   ContentRepository.load() reads 5 content JSON via rootBundle -> typed lists.
   Exposes profile, skills, experience, projects, education.
   - featuredProjects: featured==true, sorted end_date DESC. "Present" = LATEST
     (sentinel max date or two-pass; never lexical P-vs-2).
   - supportingProjects: featured==false, same sort.
   SiteConfigRepository.load() reads site_config.json -> SiteConfig.

3. APP DATA (lib/data/app_data.dart) — InheritedWidget exposing content +
   siteConfig; static of(context); updateShouldNotify false (immutable).

4. ICON RESOLVER (lib/core/icon_resolver.dart) — iconFromName(String) via const
   Map covering every icon name in site_config.json (socialIconMap +
   iconMap.projects + iconMap.skill_categories). Fallback Icons.circle_outlined
   + debugPrint on miss. No reflection.

5. MAIN (lib/main.dart) — ensureInitialized; load both repos before runApp;
   LOADING (dark bg, accent cursor/spinner), ERROR (dark bg, calm mono message,
   never red), LOADED (HomeScreen wrapped in AppData). Dark ThemeData (bg
   #131313, text #e5e2e1, pubspec fonts). Add flutter_animate + url_launcher.

6. SCAFFOLD (lib/screens/home_screen.dart) — scroll view, centered column
   max-width 1200, breakpoint gutters. Desktop: fixed 60px left slot (rail
   placeholder). Mobile/tablet: sticky 56px top slot (top-bar placeholder).
   Background flat #131313 + subtle RadialGradient vignette to #0e0e0e (~5%).
   6 placeholder containers in order (Hero, Work, Experience, Stack+Now,
   Contact, Footer), each with a GlobalKey for Step 7 scroll nav.

7. PUBSPEC — confirm assets/content/, assets/presentation/, fonts (Geist
   400/600/700, IBM Plex Mono 400/500) declared; deps flutter_animate, url_launcher.

VERIFY: `flutter analyze` clean (paste output, fix errors). App boots, JSON
loads (confirm in console), responsive empty scaffold, correct background +
placeholders. STOP, wait for STEP 2.
```

---

# STEP 2 — HERO SECTION (THE REFERENCE PATTERN)

> Most critical section. Approve fully before continuing.

```
STEP 2 — Build the Hero section only. REFERENCE PATTERN for quality, responsive
layout, animation, token usage. Later sections copy its patterns.

DESIGN REFERENCE: re-read the HERO part of the Step 0 brief (re-read the Stitch
hero or hero screenshot if needed). Token table wins sizes/colors.
CONTENT: all from site_config.hero + profile. No hardcoded strings. Metrics
come from site_config.hero.metrics (05 YEARS / 06 APPS / 10 PROJECTS).

LAYOUT
  Desktop (>1024): two-column asymmetric, left 60% / right 40%, vertically
    centered, min-height 80vh.
  Tablet (768-1024): same two-column, tighter gutters; headline scales 52-80px.
  Mobile (<768): single column, avatar above headline, metrics stack with
    hairline dividers.

COMPONENTS
  Eyebrow: site_config.hero.eyebrow, IBM Plex Mono 12px accent uppercase 0.05em
    + blinking cursor at end (hand-rolled AnimationController, 1.2s, accent,
    1ch — NOT flutter_animate).
  Headline: site_config.hero.headline, 80/52px Geist 700, lh1.05, -0.03em.
    Never < 52px. Wraps naturally.
  Sub-headline: site_config.hero.sub_headline, body-large, foreground-muted.
  Metrics: numerals IBM Plex Mono 40px 500 (leading zeros); labels mono-label
    foreground-subtle; separated by 1px hairlines (vertical desktop / horizontal
    mobile), NOT boxes.
  CTAs: from site_config.hero.cta_primary / cta_secondary. Primary (accent fill,
    on-accent, 8px radius, mono-label) scrolls to target "work"; ghost
    (transparent, border-default, hover->accent) scrolls to target "contact".
    Use GlobalKeys + Scrollable.ensureVisible.
  Avatar: NOT an image. A card (surface #201f1f, 1px border, 16px radius) with
    IBM Plex Mono "code" + accent syntax highlighting, rendered from
    site_config.hero.avatar_code (array of lines).

ANIMATIONS
  flutter_animate: on load, headline->sub->CTAs->metrics->avatar enter 20px up +
    fade, 400ms ease-out, 40ms stagger.
  Hand-roll: cursor blink; metric count-up 0->target over 800ms (Tween +
    AnimationController; format leading zeros on display).
  Reduced motion: MediaQuery.disableAnimations -> skip entrances + count-up,
    final state, static/no cursor.
  Extract reusable reveal/stagger helpers into lib/core/motion.dart.

VERIFY: compare to brief; resize 360->1440 (no overflow/clip, headline >=52px,
metrics reflow); flutter analyze clean; cursor blinks; metrics count up; CTA
scrolls work. Show me. Approve before STEP 3.
```

---

# STEP 3 — WORK SECTION

```
STEP 3 — Build the Work section. Reuse hero's section wrapper, motion.dart
reveal helper, hover patterns.

DESIGN REFERENCE: re-read WORK from the Step 0 brief. Token table wins visuals.
DATA: content.featuredProjects, content.supportingProjects; icons via
iconFromName + site_config.iconMap.projects. Section copy from site_config.work.

PART A — FEATURED GRID: 2x2 desktop / 2-col tablet / 1-col mobile; gap 24/16.
Each card: top icon glyph + status pill; name (card-title); tagline (mono-meta,
foreground-muted); short_description preview (body); tech pills (~4-5 visible,
"+N MORE" if longer); footer rating/reviews/installs (from store_metadata) LEFT
+ "READ MORE" RIGHT.
Hover (desktop): border->accent, 2px lift, others dim 80%, 200ms, NO shadow/scale.
Tablet/mobile: tap opens modal.

PART B — SUPPORTING TOGGLE: hairline divider then centered ghost using
site_config.work.show_more_label / show_less_label. Tap -> AnimatedSize reveals
supporting grid (~250ms), label flips (setState + AnimatedSize).
Supporting grid: 3-col desktop / 2-col tablet / 1-col mobile, compact cards
(20px padding): name, tagline, 1-2 tech pills, context hint footer-left from
project metadata (client / status), not hardcoded.
details_pending: 60% opacity, not clickable, "COMING SOON" not "READ MORE",
modal NEVER opens.

PART C — MODAL: state bool _modalOpen + Project? _selected in HomeScreen, pass
callbacks. Open on "READ MORE" where isClickable. showGeneralDialog,
barrierColor Color.fromRGBO(8,8,8,0.85). Must not break page scroll behind.
  Desktop: max-width 880, max-height 90vh, centered, surface-high #2a2a2a, 1px
  border, 16px radius, 48px padding, internal scroll.
  Mobile: full-screen takeover, 24px padding, sticky inner top bar BACK / X.
Content (from selected project JSON, no invented content), in order:
  1 close bar  2 domain-tag eyebrow (from tags, mono-label accent)  3 modal-title
  (name)  4 tagline  5 meta strip (company/status/dates)  6 stats row (from
  store_metadata — no invented numbers)  7 "The problem" + long_description (or
  problem_solved)  8 "My role" + role_summary  9 "What I built" +
  contribution_bullets (accent prefix)  10 stack pills (tech_stack)  11 bottom meta
  strip (status, Play Store from links if present).
Animation: open scrim fade 300ms + panel scale 96->100% + opacity 350ms;
close reverse 250ms. ESC closes (web). Tap scrim closes. Focus trap (Tab stays in).

VERIFY: resize 360->1440 (grid reflows); modal scrolls internally both layouts;
details_pending inert; focus trap; supporting toggle animates; analyze clean.
Show me.
```

---

# STEP 4 — EXPERIENCE SECTION

```
STEP 4 — Build the Experience section. Reuse established patterns.

DESIGN REFERENCE: re-read EXPERIENCE from the Step 0 brief.
DATA: content.experience (3 roles). Section copy from site_config.experience.

3 cards stacked, full width, 16px gap, 28px padding. Each card top row (desktop
one row / mobile stacked): LEFT company (card-title) + role tag (mono-label,
accent); RIGHT date range (mono-meta, foreground-subtle) + location. Context
line: foreground-muted body. Bullets: body, foreground-primary, accent prefix.

Expand/collapse: current role (no end_date or "Present") expanded by default,
all bullets. Others collapsed -> first 2 bullets + "SHOW MORE (N MORE)" (N from
data), AnimatedSize reveal, label flips, setState.
Hover (desktop): border->accent, 2px lift, date text intensifies, 200ms. Mobile:
top row stacks. NO timeline rail. Scroll reveal via motion.dart.

VERIFY: responsive, toggles work, analyze clean. Show me.
```

---

# STEP 5 — STACK + NOW SECTION

```
STEP 5 — Build the Stack + Now section. Reuse established patterns.

DESIGN REFERENCE: re-read STACK+NOW from the Step 0 brief.
DATA: content.skills + site_config.now + site_config.stack.

LAYOUT: desktop two-column Stack 65% / Now 35%, top-aligned. Mobile: stacked,
Stack then Now.

STACK: heading + sub_line from site_config.stack. Per skill category: label
(mono-label, accent, uppercase) via iconMap.skill_categories + wrapping pills
(transparent, 1px border-default, 6px radius, mono-label uppercase). 24px gap
between categories. "Currently Learning" visually distinct (pulsing accent dot
— Tween 0.4->1.0 opacity 1.5s repeat — OR accent-tinted pills; match brief).
Staggered scroll reveal per category.

NOW MODULE (own file NowWidget): card surface #201f1f, 1px border, 16px radius,
max-width 360. Heading "/ now" ("/" accent, "now" foreground-primary, Geist 600
28px). 4 rows WORKING/LEARNING/READING/OPEN TO from site_config.now (label
mono-label foreground-subtle uppercase; value body foreground-primary; reading
null -> "—"). "// last updated: {last_updated}" mono-meta subtle at bottom.
Toggle: site_config.now.show_now_module. false -> NowWidget = SizedBox.shrink()
AND Stack reflows to FULL width (not 65%) — no layout hole. true -> two-column.
Single boolean flip.

VERIFY: show_now_module toggle clean both states, pill wrapping all breakpoints,
analyze clean. Show me.
```

---

# STEP 6 — CONTACT SECTION + FOOTER

```
STEP 6 — Build Contact + Footer. Reuse patterns.

DESIGN REFERENCE: re-read CONTACT + FOOTER from the Step 0 brief.
DATA: profile.json (email, social URLs) + site_config.contact + site_config.footer.
CRITICAL: phone number in profile.json must NOT render anywhere (text, comments,
tooltips, aria-labels). Email + socials only.

CONTACT: heading + sub_line from site_config.contact. Desktop: form 60% / direct
40%. Mobile: stacked, form first.
FORM — 4 fields (name, email, subject, message multiline) with placeholders from
site_config.contact.form_fields: transparent fill, 1px BOTTOM border only
(border-default), IBM Plex Mono input text (13px), focus -> bottom border accent
(no glow/box), 32px gaps. Message min 4 lines.
Submit from site_config.contact.submit_label "SEND" (accent fill, on-accent,
8px radius, mono-label, right-aligned). Validate (non-empty + email format);
inline errors under failing fields (mono-meta, warm error color, NOT accent).
mailto behavior (no backend): build mailto:mjkhan7124@gmail.com?subject=[site
contact] {subject}&body=From: {name}%0A%0A{message}; launchUrl. SUCCESS replaces
form with site_config.contact.success_primary + success_secondary. No network.
Below form: site_config.contact.direct_note (mono-meta subtle).
DIRECT-CONTACT — Email, GitHub, LinkedIn, Location rows: geometric line icon in
accent (via socialIconMap; Location = location_on_outlined, NOT emoji), label
(mono-label subtle uppercase), value (body primary). Row hover (desktop): 2px
accent left-border slides in (AnimatedContainer), no fill change, 200ms.
Email/GitHub/LinkedIn clickable (url_launcher); Location not clickable, no hover.

FOOTER: 1px divider above, 24px padding. Desktop 3 cols: LEFT
site_config.footer.copyright, CENTER site_config.footer.built_with (both
mono-label subtle), RIGHT social icon row (accent, 20px, 16px gap, url_launcher).
Mobile stacked center, 12px gaps.

VERIFY: validation works, mailto launches correct subject/body, social links
open correct URLs, phone NOT rendered anywhere, responsive, analyze clean. Show me.
```

---

# STEP 7 — NAVIGATION + SCROLL WIRING

```
STEP 7 — Build navigation, fill the rail/top-bar placeholders, wire scroll.

DESIGN REFERENCE: re-read NAVIGATION from the Step 0 brief.
DATA: site_config.navSections + socialIconMap + profile (social URLs).

DESKTOP SIDE RAIL (fixed left, 60px): bg #131313, 1px right border. Top "MK"
monogram (mono-label accent, centered). Vertical nav from navSections
(mono-label; rotated or stacked per brief; active accent, inactive
foreground-subtle; click scrolls). Bottom social icons (20px, foreground-subtle,
accent on hover, url_launcher).

MOBILE/TABLET TOP BAR (sticky, 56px): bg #131313, 1px bottom border. LEFT "MK"
(mono-label accent). RIGHT hamburger (Icons.menu). Tap -> full-screen overlay:
bg #131313, X top-right, nav links centered (section-heading 34px Geist 600),
tap closes + scrolls; social row bottom. Open fade + slight up 200ms; close
fade 150ms.

SCROLL WIRING: each section has a GlobalKey (Step 1). scrollToSection(key) uses
Scrollable.ensureVisible(key.currentContext!, 400ms, Curves.easeInOut, alignment
0.0); on mobile compensate for the 56px sticky bar with a small offset. Wire to:
rail items, overlay items, hero CTAs (work / contact), overlay close+scroll in
one tap.
ACTIVE DETECTION: NotificationListener<ScrollNotification> on root scroll; per
event find the section whose top is nearest (not past) viewport top 30%;
setState active nav item.

VERIFY: active highlight tracks scroll; all targets scroll; hamburger
opens/closes; overlay items scroll+close one tap; hero CTAs scroll; sections not
hidden under mobile bar; analyze clean. Show me.
```

---

# STEP 8 — DEPLOY CONFIG + FINAL QA

```
STEP 8 — Prepare GitHub Pages deployment and run final QA.

================================================================
BASE HREF — ROOT REPO (mj-khan.github.io)
================================================================
Site serves from ROOT (https://mj-khan.github.io/), so base-href is "/":
  flutter build web --release --base-href "/"
Confirm web/index.html has no conflicting hardcoded <base href> (remove any
manual one). If ever switched to a normal project repo: --base-href "/<repo>/".
Custom domain at root also uses "/".

================================================================
GITHUB ACTIONS — .github/workflows/deploy.yml
================================================================
Trigger: push to main. Steps: checkout (actions/checkout@v4); setup Flutter
(subosito/flutter-action@v2, stable); flutter pub get; flutter build web
--release --base-href "/"; add a .nojekyll file to build/web (else GitHub Pages
ignores Flutter's _flutter dir -> blank screen); deploy build/web to Pages
(peaceiris/actions-gh-pages@v3 to gh-pages, OR upload-pages-artifact +
deploy-pages). Document any value to change with a comment.

================================================================
SPA 404
================================================================
Copy build/web/index.html -> build/web/404.html in the workflow so stray direct
links load the app, not a GitHub 404.

================================================================
ASSET VERIFICATION
================================================================
- assets/content/ + assets/presentation/ + fonts declared in pubspec
- all font files declared individually under fonts:
- rootBundle paths match asset paths exactly (case-sensitive)
- flutter_animate + url_launcher in dependencies
- .nojekyll present in deployed output

================================================================
README DEPLOY SECTION
================================================================
Cover: prerequisites; local dev (flutter run -d chrome); manual build (flutter
build web --release --base-href "/"); test prod build (cd build/web && python3
-m http.server 8000); GitHub Pages (repo named mj-khan.github.io, push to main ->
Actions deploys); custom domain note (CNAME, keep base-href "/").

================================================================
FINAL QA — RUN AND REPORT PASS/FAIL/NOTE
================================================================
[ ] flutter analyze: zero errors/warnings
[ ] flutter build web --release --base-href "/": succeeds
[ ] resize 360->1440 every section: no overflow/clip, breakpoints at 768/1024
[ ] all 6 JSON load: confirm in console
[ ] zero hardcoded career facts in Dart: search for stray name/date/URL/copy literals
[ ] phone number: absent from rendered DOM everywhere
[ ] modal: opens on READ MORE, closes on X / scrim / ESC; internal scroll works
[ ] details_pending cards inert (no tap, no modal, "COMING SOON")
[ ] supporting toggle reveals/hides with animation
[ ] experience expand toggles per role
[ ] show_now_module false -> Stack full width; true -> two-column
[ ] form validation (4 fields + email format)
[ ] mailto launches with correct subject + body
[ ] social links open correct URLs in new tab
[ ] nav active item tracks scroll; all targets scroll
[ ] mobile overlay opens/closes/scrolls on tap
[ ] hero CTAs scroll to Work / Contact
[ ] loading screen on throttled network (DevTools)
[ ] error screen graceful dark (NOT red) — break an asset path then revert
[ ] prefers-reduced-motion (DevTools -> Rendering): animations don't run
[ ] dead code: no leftover placeholders/unused imports; run dart fix --apply

Report results. Fix all FAILs before marking complete.
```

---

## TIPS FOR DRIVING THIS BUILD

- **One step at a time.** Don't paste Step N+1 until Step N is reviewed and analyze is clean.
- **Fix 90%-right details in the same turn** (padding, hover that scales instead of lifts).
- **If Antigravity proposes Provider/Riverpod/Bloc or routing — decline, quote the architecture section.**
- **If Geist won't bundle — allow google_fonts fallback, note the change.**
- **The Step 0 design brief is your layout contract.** Re-paste the relevant section if Antigravity drifts.
- **The Step 0 reconciliation report is your decision point.** Resolve any missing JSON field before the step that needs it. Never hardcode facts in Dart.
- **MCP failure is not fatal.** If Step 0 Task 1 reports the Stitch tools aren't reachable, provide screenshots and continue.
- **Git comes last.** Build and preview locally; create the `mj-khan.github.io` repo and wire deployment only in Step 8.
