# Abdul Mujeeb Khan — Flutter Developer Portfolio

**Live site:** [mj-khan.github.io](https://mj-khan.github.io)

A production-grade Flutter Web portfolio — dark terminal aesthetic, data-driven
content pipeline, zero hardcoded career facts in Dart.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | stable 3.41.2 (pinned in workflow) |
| Dart | ≥ 3.11 (bundled with Flutter) |
| Chrome / Edge | any recent version |

```bash
flutter --version    # verify
flutter doctor -v    # confirm no blocking issues
```

---

## Local Development

```bash
# Clone
git clone https://github.com/mj-khan/mj-khan.github.io.git
cd mj-khan.github.io

# Install dependencies
flutter pub get

# Run in Chrome with hot-reload
flutter run -d chrome
```

The dev server hot-reloads on save. Assets (`assets/content/`, `assets/presentation/`, fonts)
are loaded at runtime via `rootBundle` — changes to JSON files require a hot-restart (`R`).

---

## Manual Production Build

```bash
flutter build web --release --base-href "/"
```

Output is written to `build/web/`. The `--base-href "/"` flag is correct for:
- A **user/org page** repo (`mj-khan.github.io`) — always use `"/"`
- A **custom domain** pointing at the root — always use `"/"`

> ⚠️ **Project repo:** If you ever host under a project repo URL
> (`github.com/mj-khan/portfolio` → `mj-khan.github.io/portfolio`),
> change the flag to `--base-href "/portfolio/"`.

### Test the production build locally

```bash
cd build/web
python3 -m http.server 8000
# Open http://localhost:8000 in Chrome
```

Or use any static file server (`npx serve`, `caddy file-server`, etc.).

---

## GitHub Pages Deployment

### Repository setup

1. Repo **must** be named `mj-khan.github.io` (user/org page).
2. Go to **Settings → Pages → Source** → select **Deploy from a branch** → branch `gh-pages`, folder `/ (root)`.
3. The workflow (`peaceiris/actions-gh-pages@v3`) pushes `build/web` to the `gh-pages` branch automatically.

### Automatic deployment

Every push to `main` triggers `.github/workflows/deploy.yml`:

```
push to main
  → checkout
  → flutter stable
  → flutter pub get
  → flutter build web --release --base-href "/"
  → touch build/web/.nojekyll        # prevents Pages from ignoring _flutter/
  → cp index.html 404.html           # SPA fallback for direct links / refreshes
  → peaceiris/actions-gh-pages@v3    # push build/web → gh-pages branch
```

### Manual trigger

You can trigger a deployment manually from **Actions → Deploy to GitHub Pages → Run workflow**.

### Custom domain

1. Add a `CNAME` file to the `web/` directory (tracked in git):
   ```
   yourname.dev
   ```
2. In **Settings → Pages → Custom domain**, enter your domain.
3. Keep `--base-href "/"` — custom domains always serve from root.
4. Enable **Enforce HTTPS** once DNS propagates.

### Service Worker & Caching (Force Refresh)

This app uses Flutter's default PWA service worker (`flutter_service_worker.js`), which caches `main.dart.js`, web fonts, and JSON assets for offline support and faster load times. 

When you deploy updates:
- **Stale Content Cache:** Returning visitors might see the old version of the site until the service worker checks for updates and refreshes (usually on the second load or after closing all active tabs of the site).
- **How to Force a Cache Refresh:**
  - **For Visitors:** Hard reload by pressing `Ctrl + F5` (Windows/Linux) or `Cmd + Shift + R` (macOS).
  - **For Developers (Chrome/Edge DevTools):**
    1. Open DevTools (`F12` / `Cmd + Option + I`).
    2. Go to **Application** -> **Service Workers**.
    3. Check **Bypass for network** or click **Unregister** on the service worker to fetch the latest changes immediately.
    4. Alternatively, go to **Clear storage** and click **Clear site data**.
- **How to Disable the Service Worker (Optional):**
  If you want a pure static portfolio without any caching delay, you can disable the service worker by omitting `serviceWorkerSettings` or removing the PWA script in `web/index.html` post-build, or adding a post-build step in CI to delete/empty `build/web/flutter_service_worker.js`.

### Web Renderer Options (HTML vs CanvasKit)

By default, the workflow runs `flutter build web --release` which defaults to the `auto` renderer (CanvasKit on desktop for high-performance graphics, HTML on mobile for fast loading).

- **CanvasKit Renderer (Desktop default):**
  - **Pros:** High-fidelity, smooth 60fps animations, pixel-perfect rendering of typography and layout widgets.
  - **Cons:** Larger initial download payload (adds ~2MB WASM dependency download), slightly slower first paint while WASM compiles.
- **HTML Renderer (Mobile default / pure static option):**
  - **Pros:** Extremely fast first load and instant paint (no WASM download overhead). Great for text-first content sites.
  - **Cons:** Custom font weights, text wrapping, and decorative drawing borders might render with subtle browser-specific variations.
- **How to force HTML Renderer (Highly Recommended for Instant Loads):**
  If you want the fastest possible first-page load on both desktop and mobile, edit the build step in `.github/workflows/deploy.yml` to:
  ```bash
  flutter build web --release --web-renderer html --base-href "/"
  ```

---

## Project Structure

```
lib/
├── core/               # Design tokens: colors, spacing, typography, radii, breakpoints, motion
├── data/               # AppData (InheritedWidget) · ContentRepository · SiteConfigRepository
├── models/             # Typed data models (Profile, Project, Experience, Skill, SiteConfig …)
├── screens/
│   └── home_screen.dart    # Root screen: scroll detection + nav wiring
└── widgets/
    ├── components/
    │   ├── desktop_nav_rail.dart    # Fixed 60px rail (desktop)
    │   ├── mobile_top_bar.dart      # Sticky 56px top bar + overlay (mobile/tablet)
    │   ├── now_widget.dart          # "/ now" status card
    │   └── project_modal.dart       # Full project detail modal
    └── sections/
        ├── hero_section.dart
        ├── work_section.dart
        ├── experience_section.dart
        ├── stack_section.dart
        ├── contact_section.dart
        └── footer_section.dart

assets/
├── content/            # profile.json · projects.json · experience.json · skills.json · education.json
├── fonts/              # Geist + IBM Plex Mono (all weights, declared in pubspec.yaml)
└── presentation/       # site_config.json (all UI copy, nav sections, icon maps)
```

### Content editing

All text, links, and UI copy live in JSON — **no career facts are hardcoded in Dart**.

| File | Controls |
|------|---------|
| `assets/content/profile.json` | Name, email, social URLs, location |
| `assets/content/projects.json` | All project cards + modal content |
| `assets/content/experience.json` | Work history |
| `assets/content/skills.json` | Tech stack categories |
| `assets/presentation/site_config.json` | Section headings, nav labels, form copy, footer |

> ⚠️ **Phone number:** The `phone` field in `profile.json` is intentionally **never parsed** by the app.
> It exists only as a record in the JSON file and will never appear in the rendered output.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_animate ^4.5.2` | Declarative reveal animations |
| `url_launcher ^6.3.1` | Social links + mailto |

---

## QA Checklist (pre-deploy)

- [ ] `flutter analyze` — zero errors/warnings
- [ ] `flutter build web --release --base-href "/"` — succeeds
- [ ] Resize 360→1440: no overflow, breakpoints fire at 768/1024
- [ ] All 6 JSON files load (check browser console)
- [ ] Phone number absent from rendered DOM
- [ ] Modal: opens on READ MORE, closes on X / scrim / ESC
- [ ] `details_pending` cards: inert, no modal, shows COMING SOON
- [ ] Supporting projects toggle: animates open/close
- [ ] Experience cards: expand/collapse per role
- [ ] `show_now_module: false` → Stack full-width; `true` → two-column
- [ ] Contact form: validates 4 fields + email format
- [ ] Contact form: mailto launches with `[site contact]` subject prefix
- [ ] Social links: open correct URLs in new tab
- [ ] Nav active item tracks scroll (30% viewport threshold)
- [ ] Mobile overlay: opens, closes, scrolls on tap
- [ ] Hero CTAs scroll to Work / Contact
