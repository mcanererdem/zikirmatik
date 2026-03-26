# Tasbih Counter 📿

A simple, user-friendly, and accessible digital tasbih (dhikr counter) app with modern UI, real-time sync, and comprehensive features.

**Developer:** Caner Erdem  
**Purpose:** To simplify dhikr counting and save progress with cloud synchronization. Designed for Muslims to use in their daily worship or personal remembrance.

## Features ✨

### Core Features
- 🔢 **Tap Counter:** Increment count by tapping the main button with haptic feedback
- 💾 **Data Persistence:** Local storage with optional cloud sync (Supabase)
- 🌍 **16 Language Support:** Turkish, English, Arabic, Indonesian, Urdu, Bengali, Malay, Persian, French, Chinese, Japanese, Russian, German, Swahili, Hausa
- 🎨 **8 Theme Options:** Blue/Gold, Green/Gold, Purple/Gold, Dark Night, Moonlight, Deep Space, Northern Lights, Starry Night
- ⚙️ **Customizable:** Vibration, sound, confetti, TTS, animation speed settings

### Goals & Statistics
- 🎯 **Multiple Goal System:** Daily/weekly/monthly dhikr-based goals with independent progress tracking
- 🏆 **Trophy System:** Bronze, Silver, Gold, Diamond, Platinum achievements
- 🔥 **Streak Tracking:** Consecutive day/week/month achievement series
- 📊 **Advanced Statistics:** Daily, weekly, monthly charts with detailed analysis
- 🏅 **Leaderboard:** Global and daily rankings with Supabase integration
- 🧩 **Cup Breakdown:** Total cups + per-type cup badges (bronze/silver/gold/diamond/platinum)

### Modern Features
- 📱 **Home Screen Widget:** Quick access via Android home screen widget with live sync
- ➕ **Custom Dhikr:** Add your own dhikr with 16 language support
- 📢 **Ad Support:** Banner and rewarded ads (test mode active)
- 🔄 **Rotation Support:** Data preserved when device rotates
- ♿ **Accessibility:** Screen reader support (TalkBack/VoiceOver)
- 🎯 **Smart Notifications:** Daily reminders with time and day selection
- 💬 **Modern Settings:** Compact, beautiful settings interface
- 📤 **Export/Import:** Backup and restore data (JSON format)
- 🌐 **Cloud Sync:** Supabase integration for data synchronization
- 🎭 **Splash Screen:** Beautiful animated splash screen
- ⚡ **Performance Modes:** 4-level animation speed control

## Getting Started

### Requirements

- Flutter 3.0+ SDK
- Dart 3.0+
- Android SDK (for Android development)
- Xcode (for iOS development)
- Supabase account (for cloud features)

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

# Release AAB (Google Play)
flutter build appbundle --release

# iOS
flutter build ios
```

## Technologies 🛠️

- **Flutter:** UI framework
- **Dart:** Programming language
- **Supabase:** Cloud database and authentication
- **SharedPreferences:** Local data storage
- **Flutter Local Notifications:** Push notifications
- **Google Mobile Ads:** AdMob integration (banner + rewarded)
- **Home Widget:** Android widget support
- **URL Launcher:** External links
- **Package Info Plus:** App version info
- **Path Provider:** File system access
- **Share Plus:** Data sharing
- **File Picker:** File selection
- **Google Fonts:** Typography
- **Confetti:** Celebration animations

## Project Structure

```
zikirmatik/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── home_page.dart        # Main screen with counter
│   │   ├── settings_screen.dart  # Modern settings interface
│   │   ├── leaderboard_screen.dart # Global rankings
│   │   ├── profile_screen.dart   # User profile and achievements
│   │   ├── statistics_screen.dart # Statistics and charts
│   │   ├── splash_screen.dart    # Animated splash screen
│   │   ├── support_screen_new.dart # Customer support
│   │   ├── about_screen_new.dart  # About page
│   │   └── import_export_screen.dart # Data management
│   ├── widgets/
│   │   ├── success_dialog.dart   # Success animations
│   │   ├── target_dialog.dart    # Target setting dialog
│   │   ├── add_zikr_dialog.dart  # Add dhikr dialog (16 languages)
│   │   ├── goal_dialog.dart      # Goal management
│   │   └── confetti_animation.dart # Celebration effects
│   ├── models/
│   │   ├── zikr_model.dart       # Dhikr model
│   │   ├── theme_model.dart      # Theme model (8 themes)
│   │   ├── goal_model.dart       # Goal model
│   │   ├── user_profile_model.dart # User profile for cloud sync
│   │   └── statistics_model.dart # Statistics model
│   ├── services/
│   │   ├── settings_service.dart # Settings management
│   │   ├── supabase_service.dart # Cloud synchronization
│   │   ├── notification_service.dart # Push notifications
│   │   ├── ad_service.dart       # AdMob service (banner + rewarded)
│   │   ├── widget_service.dart   # Widget service
│   │   ├── counter_logic.dart    # Counter logic
│   │   ├── audio_manager.dart    # Audio management
│   │   ├── feedback_manager.dart # Haptic feedback
│   │   └── tts_service.dart      # Text-to-speech
│   └── utils/
│       └── localizations.dart    # Multi-language (16 languages, 100+ keys)
├── assets/
│   ├── icons/                    # App icon
│   └── sounds/                   # Sound effects
├── supabase_schema.sql          # Database schema
└── pubspec.yaml                  # Project dependencies
```

## Console Configuration 🎯

### Quick Console Commands
```bash
# Theme selection
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es theme_id "purple_gold"

# Language change
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es language_code "tr"

# Animation speed (0: Off, 1: Slow, 2: Normal, 3: Fast)
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es animation_speed "0"

# Notification settings
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es reminder_time "21:00"
```

## Supabase Setup 🔗

### Database Setup
1. Create a new project at [supabase.com](https://supabase.com)
2. Run the SQL commands from `supabase_schema.sql`
3. Enable Row Level Security (RLS) for data protection
4. **Credentials:** URL and anon (publishable) key are not in the repo. Pass them at build/run time:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key
   flutter build apk --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
   ```
   See `.env.example` for variable names. Store the database password only in a password manager (for direct Postgres access); the app does not use it.

### Tables Created
- `users` - User profiles and statistics
- `leaderboard_daily` - Daily rankings
- `leaderboard_weekly` - Weekly rankings
- `leaderboard_monthly` - Monthly rankings
- `achievements` - Trophy system
- `user_achievements` - User trophy unlocks

## AdMob Setup 🎯

- **Debug mode:** Test ads automatically used
- **Release mode:** Production ID active (subject to app approval)
- **Ad Units:** Banner ads + Rewarded video ads

## Store Publishing 📱

### Google Play Store Upload

Detailed guides for uploading to Google Play Store:

- **[STORE_LISTING.md](STORE_LISTING.md)** — Google Play Store listing info, descriptions, screenshots
- **[PRIVACY_POLICY.md](PRIVACY_POLICY.md)** — Privacy policy and data handling

### Data Handling Notes (for Store Console drafts)

- Leaderboard sharing is opt-in and off by default.
- Statistics such as most productive hour are on-device aggregate estimates.
- Export files are data-focused and do not include mandatory legal branding text.
- For design prompts, export scope, and performance roadmap details, see `DESIGN_PERFORMANCE_AND_EXPORT_NOTES.md`.

### Release Build

```bash
# Create release AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Privacy Policy

Available at: `https://mcanererdem.github.io/zikirmatik/privacy_policy.html`

## Performance & Optimization ⚡

### Animation Speed Control
- **Off (0):** All animations disabled for maximum performance
- **Slow (1):** Relaxed animations for accessibility
- **Normal (2):** Balanced animations (default)
- **Fast (3):** Quick animations for power users

### Memory Management
- Efficient state management
- Optimized image loading
- Background task management
- Local storage optimization

## Contact 💬

- **Email:** tasbih.counter.zikirmatik@gmail.com
- **GitHub:** [github.com/mcanererdem/zikirmatik](https://github.com/mcanererdem/zikirmatik)

## Feedback 💬

Found a bug or want to request a feature? Please use [Issues](https://github.com/mcanererdem/zikirmatik/issues).

## License 📄

Released under the MIT License.

---

Made with love and dedication ❤️

**Version 1.2.1 - Modern dhikr counter with cloud sync, smart reminders and leaderboard improvements**
