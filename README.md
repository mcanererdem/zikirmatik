# Tasbih Counter 📿

A simple, user-friendly, and accessible digital tasbih (dhikr counter) app.

**Developer:** Caner Erdem  
**Purpose:** To simplify dhikr counting and save progress. Designed for Muslims to use in their daily worship or personal remembrance.

## Features ✨

### Core Features
- 🔢 **Tap Counter:** Increment count by tapping the main button
- 💾 **Data Persistence:** All data saved even after closing the app (SharedPreferences)
- 🌍 **15 Language Support:** Turkish, English, Arabic, Indonesian, Urdu, Bengali, Malay, Persian, French, Chinese, Japanese, Russian, German, Swahili, Hausa
- 🎨 **Theme Options:** Blue/Gold, Dark, Mint themes + Dark mode
- ⚙️ **Customizable:** Vibration, sound, confetti, language, theme settings (all off by default)

### Goals & Statistics
- 🎯 **Multiple Goal System:** Daily/weekly/monthly dhikr-based goals (independent progress tracking)
- 🏆 **Trophy System:** Track completed goals with trophies and achievements
- 🔥 **Streak Tracking:** Consecutive day/week/month achievement series (supports multiple goals per day)
- 📊 **Advanced Statistics:** Daily, weekly, monthly charts with detailed analysis

### Additional Features
- 📱 **Home Screen Widget:** Quick access via Android home screen widget (full sync + statistics display)
- ➕ **Custom Dhikr:** Add your own dhikr (with 15 language support)
- 📢 **Ad Support:** Banner and rewarded ads (test mode active)
- 🔄 **Rotation Support:** Data preserved when device rotates
- ♿ **Accessibility:** Screen reader support (TalkBack/VoiceOver)
- 🎯 **Goal Notifications:** Vibration, animation, and streak messages on goal completion
- 💬 **About Page:** GitHub repo and contact information
- 📤 **Export/Import:** Backup and restore data (JSON format)

## Getting Started

### Requirements

- Flutter 3.0+ SDK
- Dart 3.0+
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

```bash
# Clone repository
git clone https://github.com/mcanererdem/zikirmatik.git
cd zikirmatik

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build the App

```bash
# Debug APK (Android)
flutter build apk --debug

# Release APK (Android)
flutter build apk --release

# iOS
flutter build ios
```

## Technologies 🛠️

- **Flutter:** UI framework
- **Dart:** Programming language
- **SharedPreferences:** Local data storage
- **Vibration:** Haptic feedback
- **AudioPlayers:** Sound effects
- **Google Mobile Ads:** AdMob integration (banner + rewarded)
- **Home Widget:** Android widget support
- **URL Launcher:** External links
- **Package Info Plus:** App version info
- **Path Provider:** File system access
- **Share Plus:** Data sharing
- **File Picker:** File selection

## Project Structure

```
zikirmatik/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── home_page.dart        # Main screen
│   │   ├── statistics_screen.dart # Statistics screen (trophy + streak)
│   │   └── about_screen.dart      # About page
│   ├── widgets/
│   │   ├── target_dialog.dart    # Target setting dialog
│   │   ├── add_zikr_dialog.dart  # Add dhikr dialog (15 languages)
│   │   ├── settings_dialog.dart  # Settings dialog (rewarded ad)
│   │   ├── goal_dialog.dart      # Goal dialog
│   │   └── success_dialog.dart   # Success dialog
│   ├── models/
│   │   ├── zikr_model.dart       # Dhikr model
│   │   ├── theme_model.dart      # Theme model
│   │   ├── goal_model.dart       # Goal model
│   │   ├── trophy_model.dart     # Trophy and streak model
│   │   └── statistics_model.dart # Statistics model
│   ├── services/
│   │   ├── settings_service.dart # Settings service
│   │   ├── ad_service.dart       # AdMob service (banner + rewarded)
│   │   ├── widget_service.dart   # Widget service
│   │   ├── counter_logic.dart    # Counter logic
│   │   ├── audio_manager.dart    # Audio management
│   │   ├── feedback_manager.dart # Haptic feedback
│   │   └── export_service.dart   # Data export/import
│   └── utils/
│       └── localizations.dart    # Multi-language (15 languages, 80+ keys)
├── assets/
│   ├── icons/                    # App icon
│   └── sounds/                   # Sound effects
└── pubspec.yaml                  # Project dependencies
```

## AdMob Setup 🎯

**Production Ad Unit ID (Android):** `ca-app-pub-8195806446886861/1390869911`

- Debug mode: Test ads automatically used
- Release mode: Production ID active (subject to app approval)

## Store Publishing 📱

### Google Play Store Upload

Detailed guides for uploading to Google Play Store:

- **[STORE_LISTING.md](STORE_LISTING.md)** — Google Play Store listing info, descriptions, screenshots
- **[GOAL_TROPHY_STREAK_LOGIC.md](GOAL_TROPHY_STREAK_LOGIC.md)** — Complete logic documentation for goals, trophies, and streaks

### Release Build

```bash
# Create release AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Privacy Policy

Available at: `https://mcanererdem.github.io/zikirmatik/privacy_policy.html`

## Contact 💬

- **Email:** mcanererdem@gmail.com
- **GitHub:** [github.com/mcanererdem/zikirmatik](https://github.com/mcanererdem/zikirmatik)

## Feedback 💬

Found a bug or want to request a feature? Please use [Issues](https://github.com/mcanererdem/zikirmatik/issues).

## License 📄

Released under the MIT License.

---

Made with love and dedication ❤️
