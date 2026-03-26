# Design, Performance, and Export Notes

This document summarizes:

- Visual asset generation prompts (Gemini-ready)
- Current export scope and statistics coverage
- Performance findings and optimization backlog

## 1) Gemini Asset Prompt Pack

Use these prompts directly in Gemini Pro and save outputs under `assets/generated/...`.

### 1.1 Leaderboard Empty State

- **Output:** `assets/generated/illustrations/leaderboard_empty.png`
- **Prompt:**
  - Create a clean mobile app illustration for an Islamic dhikr app leaderboard empty state.
  - Composition: centered podium silhouette, subtle crescent and geometric pattern, one friendly minimal character, no text.
  - Style: modern flat + soft gradients, premium and calm.
  - Palette: deep navy `#0F1C2E`, teal `#2EC4B6`, gold `#E7B85C`.
  - Format: PNG, transparent background, 1024x1024.
  - Negative: no watermark, no logos, no busy background.

### 1.2 Profile Header Decorative Background

- **Output:** `assets/generated/backgrounds/profile_header_bg_dark.png`
- **Prompt:**
  - Generate a dark decorative header background for a Flutter profile screen.
  - Abstract layered radial gradients, subtle Islamic geometric motifs, soft glow.
  - No text, no icons, no people.
  - Colors: `#121A2C`, `#2B4E9A`, `#5EC7D9`, subtle `#CFAE6E`.
  - Output: PNG, 1600x900.

### 1.3 Trophy Icon Set

- **Output folder:** `assets/generated/trophies/`
  - `trophy_bronze.png`
  - `trophy_silver.png`
  - `trophy_gold.png`
  - `trophy_diamond.png`
  - `trophy_platinum.png`
- **Prompt template:**
  - Create a single isolated trophy icon for mobile UI, transparent background, centered.
  - Tier: BRONZE/SILVER/GOLD/DIAMOND/PLATINUM.
  - Style: modern semi-flat, readable at small sizes.
  - No text.
  - Output: PNG, 512x512 transparent.

### 1.4 About Hero Illustration

- **Output:** `assets/generated/illustrations/about_hero.png`
- **Prompt:**
  - Create an About screen hero illustration for a dhikr counter app.
  - Elements: abstract app emblem, calm glow, subtle geometric rings.
  - No text/logos/watermark.
  - Output: PNG, 1536x1024.

### 1.5 Support Hero Illustration

- **Output:** `assets/generated/illustrations/support_hero.png`
- **Prompt:**
  - Create a support hero illustration for a mobile app.
  - Include abstract message bubbles + help/shield symbol.
  - Dark mode friendly palette, no text.
  - Output: PNG, 1536x1024.

### 1.6 Light/Dark App Texture Backgrounds

- **Outputs:**
  - `assets/generated/backgrounds/app_bg_dark.png`
  - `assets/generated/backgrounds/app_bg_light.png`
- **Prompt (dark):**
  - Seamless dark app background texture, very subtle geometric motif, low contrast.
  - Output: PNG, 1440x3200.
- **Prompt (light):**
  - Seamless light app background texture, minimal pattern and noise.
  - Output: PNG, 1440x3200.

## 2) Asset Integration Checklist

- Add generated files to:
  - `assets/generated/backgrounds/`
  - `assets/generated/illustrations/`
  - `assets/generated/trophies/`
- Update `pubspec.yaml` assets section accordingly.
- Replace placeholder usage in:
  - `lib/screens/leaderboard_screen.dart`
  - `lib/screens/profile_screen.dart`
  - `lib/screens/about_screen_new.dart`
  - `lib/screens/support_screen_new.dart`

## 3) Export Scope (Current State)

Current backup export in `lib/screens/import_export_screen.dart` includes:

- `zikirCounts` (total/current/last date)
- `achievements` (cup unlock booleans)
- `settings` (theme/language/vibration/sound/confetti/reminder/tts)

### Important Note

Detailed statistics series are **not fully exported yet**:

- `daily_count_`*
- `hourly_count_*`
- other chart source keys used by statistics screens

## 4) Recommended Export Improvement

Add a new `statistics` block to export payload:

- `dailyCounts`: all keys matching `daily_count_`
- `hourlyCounts`: all keys matching `hourly_count_`
- optional derived summaries if needed

And import side should:

- validate type/limits
- apply safely with existing checksum/schema checks
- remain backward-compatible with old backups

## 5) Performance Findings and Action Plan

### Quick wins (high impact, low effort)

- Move non-critical startup async work to post-`runApp`.
- Ensure Ad SDK initialization runs in one place only.
- Reduce heavy glow/shadow layers on animated home widgets.
- Cache frequently read local values instead of repeated async reads in rebuild paths.
- Prefer lazy lists (`ListView.builder`) for ranking-heavy screens.

### Medium refactors

- Startup orchestration by phases: critical vs deferred tasks.
- Shared in-memory session cache for settings/profile/statistics.
- Add adaptive animation quality on lower-end devices.
- Add frame timing logging and periodic jank reporting.

## 6) Verification Checklist

- `flutter analyze` after visual/perf changes.
- Manual checks:
  - cold start duration and white screen behavior
  - leaderboard/profile transitions
  - about/support rendering with new assets
  - backup export/import compatibility after statistics block addition

## 7) Next UI Improvement Strategy

Planned order for the next visual pass:

1. Home progress section modernization
   - Redesign progress bar with stronger contrast, softer corners, and clearer fill animation.
   - Keep current spacing stable first; then tune counter/progress/zikr gaps with small incremental changes.
2. Background asset strategy
   - Use theme-aware background selection rules (light/dark, low-noise variants).
   - Add readability guardrails: preserve text contrast and avoid high-frequency textures behind dense text.
3. Leaderboard card package
   - Build one reusable card style for rank/avatar/name/metrics.
   - Keep cup and zikr modes visually consistent while allowing compact mode-specific chips.

