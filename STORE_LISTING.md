# Google Play Store - Listing Information

Complete this information when creating the app listing on Google Play Console.

## Basic Store Listing

### App Name
**Zikirmatik**

### Short Description (80 characters max)
```
Islamic prayer counter with customizable zikir and offline-first design
```

### Full Description (4000 characters max)
```
Zikirmatik is a simple, modern Islamic prayer counter (tasbih/dhikr app) designed 
for daily spiritual practice. Keep track of your zikir (Islamic remembrance) with 
precision and ease.

✨ Features:

📱 Smart Counter
- Tap to increment, long-press or shake device to reset
- Set target numbers for guided dhikr sessions
- Customizable counter animations and sounds

🌍 Multi-Language Support
- Turkish (Türkçe)
- English
- Arabic (العربية)
- Easily switch between languages in settings

🎨 Beautiful Themes
- Multiple color themes including dark mode
- Fluid Material 3 design
- Switch themes instantly

🔧 Customization
- Create your own zikir entries in Arabic, Turkish, and English
- Customize vibration and sound feedback
- Persistent settings across app sessions

📊 Offline-First
- Fully works without internet connection
- All data stored locally on your device
- No accounts or sign-ups required
- No data tracking (except AdMob for ads)

💪 Fast & Lightweight
- Minimal battery usage
- Works on all Android versions (API 22+)
- No unnecessary permissions

🕌 Perfect For
- Islamic daily dhikr and tasbeeh
- Morning and evening zikir practice
- Quranic verse remembrance tracking
- Prayer supplementary counting

== Use Cases ==
- Count 33x "Subhanallah" (سبحان الله)
- Track 100x recitations of "Alhamdulillah" (الحمد لله)
- Monitor 33x "Allahu Akbar" (الله أكبر)
- Custom zikir with personal translations
- Educational counting with friends

== Open Source ==
View the source code on GitHub:
https://github.com/mcanererdem/zikirmatik

== Privacy ==
Your data stays on your device. No cloud sync, no tracking. 
Read our Privacy Policy for details.

== Need Help? ==
- Check the in-app Settings dialog
- Visit GitHub: https://github.com/mcanererdem/zikirmatik/issues
- Email: mcanererdem@example.com

Developed with ❤️ for the Islamic community.
```

---

## Additional Fields

### Screenshots (5 required, 1280×720 or 1440×720 recommended)

**Screenshot 1: Main Counter Screen**
- Show large counter display
- Show increment/reset quick actions
- Show theme colors

**Screenshot 2: Zikir Selection Dialog**
- Highlight zikir list with Arabic, Turkish, English translations
- Show search/filter capability

**Screenshot 3: Settings & Customization**
- Show language selection (TR/EN/AR)
- Show theme options
- Show vibration/sound toggles

**Screenshot 4: Add Custom Zikir**
- Show custom zikir creation dialog
- Show multi-language input fields
- Show count input

**Screenshot 5: Target Setting**
- Show target dialog with quick-select buttons (33, 99, 100, 500, 1000)
- Show success animation preview

---

### Feature Graphic (1024×500px)
Include:
- Central counter display (large, readable)
- App name "Zikirmatik"
- Key features: "Multi-Language • Themed • Offline"
- Islamic crescent moon or prayer-related icon

**Suggested Design:** Dark blue background (#0A2239) with gold/cream text and Islamic geometric pattern

---

### Icon (512×512px)
Use: `assets/icons/app_icon.png`
- Square format
- Solid background (match theme color)
- Counter/zikir symbol (e.g., prayer beads, crescent, number)
- Readable at small sizes

---

## Categorization

### Category
**Lifestyle**

### Content Rating
**IARC Questionnaire Answers:**
- Alcohol, Tobacco, Drugs: No
- Violence: No
- Sexual Content: No
- Profanity: No
- Religion: Yes (Islamic app)
- Political Content: No
- Personal Safety: No

**Resulting Age Rating:** All Ages (3+)

---

## Release & Distribution

### Release Notes (for v1.0.0)
```
🎉 Zikirmatik v1.0.0 - Official Launch!

Welcome to the first official release of Zikirmatik!

✨ What's Included:
- Fully functional Islamic counter with customizable zikir
- Multi-language support (Turkish, English, Arabic)
- Beautiful Material 3 themes with dark mode
- Local data storage (no accounts needed)
- Banner ads (ad-free experience coming soon)
- Vibration and sound feedback options

📱 Works offline
💾 Your data stays on your device
🌍 Available in 3 languages

Thank you for supporting this project!
```

### Countries/Regions
Default: Worldwide (All countries)

### Content Characteristics
- **Religion:** Yes

---

## Pricing

**Price:** Free (with AdMob banner ads)

**In-App Purchases:** None

---

## Contact & Support

**Email:** mcanererdem@example.com  
**Website/Support URL:** https://github.com/mcanererdem/zikirmatik  
**Privacy Policy URL:** https://github.com/mcanererdem/zikirmatik/blob/main/PRIVACY_POLICY.md

---

## Compliance Checklist

- [ ] App follows Google Play Policies
  - [ ] No deceptive practices
  - [ ] No hate speech
  - [ ] No intellectual property violations
  - [ ] No malware/security risks

- [ ] Content Rating filled (IARC form submitted)
- [ ] Privacy Policy accessible and accurate
- [ ] App name unique or appropriate (trademark checked)
- [ ] No beta/test APK uploaded
- [ ] Screenshots are actual app screenshots (not mocked-up)
- [ ] Feature graphic dimensions correct (1024×500)
- [ ] Icon dimensions correct (512×512)
- [ ] App tested on at least 2 different devices (if possible)
- [ ] Crash testing done (check Firebase/Logcat)

---

## Testing Before Upload

1. **Device Testing:**
   - Test on Android 5.1 (API 22) - minimum
   - Test on Android latest (API 34+)
   - Test landscape and portrait orientations
   - Test with/without internet (ads should fail gracefully)

2. **Functionality:**
   - Counter increments correctly
   - Reset works
   - Target setting works
   - Custom zikir creation works
   - Language switching works
   - Theme switching works
   - Settings persist after restart

3. **Performance:**
   - App launches in < 2 seconds
   - No obvious lags or freezes
   - Ads load gracefully (or show placeholder)

4. **Localization:**
   - App strings appear in correct language
   - No untranslated UI elements
   - RTL support for Arabic (if implemented)

---

## Upload Instructions

1. **Build Release APK/AAB:**
   ```bash
   flutter build appbundle --release
   # Produces: build/app/outputs/bundle/release/app-release.aab
   ```

2. **In Google Play Console:**
   - Create new app
   - Fill in Store Listing (this document)
   - Upload promo graphics (screenshots, feature graphic, icon)
   - Content Rating: Complete IARC questionnaire
   - Pricing & Distribution: Set to Free, select countries
   - Generate release signing certificate (or upload keystore)
   - Upload app-release.aab under "Release" → "Production"

3. **Review & Submit:**
   - Check all information is complete
   - Click "Review and roll out to production"
   - Wait for Google's automated and manual review (24-48 hours typical)

4. **Post-Launch:**
   - Monitor Play Store reviews and ratings
   - Check Crashes & ANRs in Console
   - Respond to user feedback

---

## Important Notes

- **Email:** Replace `mcanererdem@example.com` with actual contact email
- **Screenshots:** Use actual device screenshots or high-quality emulator screenshots
- **Graphics:** Ensure branding consistency (use brand colors #0A2239 dark blue, gold accents)
- **Translations:** Consider translating store listing to Turkish and Arabic for wider reach
- **Keystore:** Keep signing key secure and backed up (needed for future updates)
- **Versioning:** Increment version code before every release in `pubspec.yaml`

---

**Good luck with your launch! 🎉**
