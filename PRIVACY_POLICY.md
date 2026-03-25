# Tasbih Counter - Privacy Policy

**Last Updated:** March 17, 2026

## Overview

Tasbih Counter ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.

## Information We Collect

### 1. Local Data (On Your Device)
- **Counter values and history:** Saved locally on your device using SharedPreferences
- **User preferences:** Language, theme, vibration, sound, notification settings
- **Custom dhikr entries:** Your personal dhikr data (stored locally)

This data is primarily stored on your device and is removed if you uninstall the app or clear app data.

### 2. Cloud Data (Supabase)
To provide optional features like leaderboard and profile sync, we use Supabase as a backend. Through Supabase we may store:
- **Anonymous user ID:** A random, device-based identifier (no email, password, or phone number)
- **Profile data (optional):** Username, display name, avatar URL
- **Statistics:** Total dhikr counts and aggregate statistics for leaderboards
- **Achievements:** Information about unlocked trophies

We do **not** collect or store sensitive personal identifiers (such as name with contact details, email, phone number, or address).

### 3. Advertising Data (Google Mobile Ads / AdMob)
When you use Tasbih Counter, Google may collect:
- Advertising ID and device information
- Approximate location (if enabled by your device settings)
- App usage data to show and measure ads

See Google's Privacy Policy for details: https://policies.google.com/privacy

## How We Use Information

We use collected information to:
1. Provide and improve core app features (counter, goals, notifications, statistics)
2. Sync optional profile and leaderboard data via Supabase
3. Show ads through Google AdMob (where enabled)
4. Maintain app stability, security, and compliance

We do **not** sell your personal data.

## Data Storage & Security

- **Local storage:** Data stored on your device is protected by your device's security mechanisms (screen lock, OS encryption, etc.).
- **Cloud storage (Supabase):** Data transmitted to Supabase is sent over HTTPS and stored in a managed PostgreSQL database with Row Level Security (RLS) enabled.
- **Backups:** We do not maintain personal backups separate from Supabase's managed infrastructure. If you uninstall the app or clear app data, local data is removed.

## Export/Import Feature

- You can export your dhikr data as a JSON file to your device.
- You can import a previously exported file to restore data.
- These files are stored and managed by you on your own device or cloud drive.
- We do not receive a copy of these files.

## Third-Party Services

### Supabase
Used for optional cloud sync and leaderboard:
- Stores anonymous IDs, basic profile fields, and aggregate dhikr statistics.
- Access is controlled by Row Level Security policies.

Supabase privacy: https://supabase.com/privacy

### Google Mobile Ads (AdMob)
- Collects advertising identifiers and device information to serve and measure ads.
- Data is collected and processed by Google under its own policies.

Google privacy: https://policies.google.com/privacy

## Your Choices and Rights

You can:
- **Disable cloud features:** Turn off leaderboard/profile sync in app settings (where available), or stay offline.
- **Delete local data:** Uninstall the app or clear app data from your device settings.
- **Reset advertising ID / control ads:** Use the system settings and Google My Ad Center: https://myadcenter.google.com

Because we use anonymous identifiers and do not maintain user accounts (email/password), traditional "account deletion" and "data export" requests are limited to the data stored on your device.

## Children's Privacy

Tasbih Counter is designed for general audiences and does not target children specifically. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us so we can delete it.

## Changes to This Policy

We may update this Privacy Policy from time to time. Changes will be posted in the app or repository with an updated date. Your continued use of Tasbih Counter after changes are posted means you accept the updated policy.

## Contact Us

For privacy concerns or questions, please contact:

**Email:** tasbih.counter.zikirmatik@gmail.com  
**GitHub:** https://github.com/mcanererdem/zikirmatik
