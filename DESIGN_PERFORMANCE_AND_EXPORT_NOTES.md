# Asset and App Icon Notes

Bu dokuman sadece gorsel uretimi ve app icon degisimi icin tutulur.

## 1) App Icon Workflow

### Hedef dosya

- Uretilecek ikon: `assets/icons/app_icon_new.png`
- Onerilen boyut: `1024x1024`, PNG, saydam arka plan yok (tam dolu kare).

### Flutter tarafinda kullanilacak yer

- `pubspec.yaml` icindeki `flutter_launcher_icons.image_path` alanini
`assets/icons/app_icon_new.png` yap.
- Sonra ikonlari yeniden uret:
  - `flutter pub get`
  - `dart run flutter_launcher_icons`

## 2) Asset Locations

- Arka planlar: `assets/generated/backgrounds/`
- Ilustrasyonlar: `assets/generated/illustrations/`
- Kupa ikonlari: `assets/generated/trophies/`
- Uygulama ikonu: `assets/icons/`

## 3) Gemini Prompt Pack (Current)

### 3.1 Leaderboard Empty

- Cikti: `assets/generated/illustrations/leaderboard_empty.png`
- Prompt:
  - Clean mobile illustration for an Islamic dhikr app leaderboard empty state.
  - Centered podium silhouette, subtle crescent + geometric pattern.
  - No text, no watermark, no logos.
  - Premium calm style, soft gradients.
  - Palette: `#0F1C2E`, `#2EC4B6`, `#E7B85C`.
  - PNG `1024x1024`.

### 3.2 Profile Header Background

- Cikti: `assets/generated/backgrounds/profile_header_bg_dark.png`
- Prompt:
  - Dark decorative header background for Flutter profile screen.
  - Layered radial gradients, subtle Islamic motifs, soft glow.
  - No text, no people, no icons.
  - Colors: `#121A2C`, `#2B4E9A`, `#5EC7D9`, `#CFAE6E`.
  - PNG `1600x900`.

### 3.3 Trophy Set

- Cikti klasoru: `assets/generated/trophies/`
  - `trophy_bronze.png`
  - `trophy_silver.png`
  - `trophy_gold.png`
  - `trophy_diamond.png`
  - `trophy_platinum.png`
- Prompt template:
  - Single isolated trophy icon for mobile UI.
  - Tier: BRONZE/SILVER/GOLD/DIAMOND/PLATINUM.
  - Modern semi-flat, readable at small sizes.
  - No text.
  - PNG `512x512`, transparent background.

### 3.3 App Icon Prompts

- Dosya yolu önerim: `assets/icons/app_icon_new.png`
- Sonra `pubspec.yaml` içinde `flutter_launcher_icons.image_path` değerini bu dosyaya çek.
- Ardından:
  - `flutter pub get`
  - `dart run flutter_launcher_icons`

- **Prompt 1 - Minimal Geometric (Safe/Store-friendly)**
  - *Design a premium mobile app icon for an Islamic dhikr counter app named Zikirmatik. Create a clean geometric white misbaha/tasbih symbol centered on a deep navy to royal blue gradient background. Add subtle Islamic geometric line texture in the background, very low contrast. No text, no letters, no watermark, no realistic objects. High contrast, crisp edges, modern flat + soft glow style. Output PNG 1024x1024, square, full-bleed background.*
- **Prompt 2 - Luminous Spiritual (More Character)**
  - *Create a modern app icon for a dhikr app: a glowing circular zikr bead ring around a subtle crescent-inspired core. Use elegant blue/cyan/gold palette (#0F1C2E, #2B4E9A, #5EC7D9, #CFAE6E). Style: calm, spiritual, premium, slightly glassy but still readable at small size. No text, no logos, no watermark. Keep composition simple and centered. PNG 1024x1024.*
- **Prompt 3 - Bold Monogram Symbol (Most Distinct)**
  - *Generate a bold mobile app icon for Zikirmatik with an abstract symbolic emblem inspired by tasbih beads and a central prayer marker shape. Strong silhouette for small sizes, minimal detail, high contrast. Background: dark blue gradient with subtle radial light. Foreground symbol: white and light cyan accents. No typography, no text, no watermark. Flat-modern style with slight depth. PNG 1024x1024.*

## 4) Quick Validation

- `flutter analyze`
- Android launcher icon kontrolu (home, app drawer, settings list)
- Play Console listing icon gorseli guncel mi kontrol et

