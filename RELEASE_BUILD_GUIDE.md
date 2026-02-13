# Release Build Guide - Zikirmatik v1.0.0

This guide walks through preparing and building the release APK/AAB for Google Play Store.

## Prerequisites

✅ **Before Starting:**
- [ ] Keystore generated (see instructions below)
- [ ] Flutter & Dart installed and working
- [ ] `flutter pub get` completed
- [ ] Version in `pubspec.yaml` set to `1.0.0+1`
- [ ] `firebase-cli` optional (not needed for initial release)

---

## Step 1: Generate Keystore (One-Time Setup)

The keystore is used to sign your app. **Do this once** and keep the keystore file safe!

### Option A: Android Studio GUI (Recommended)

1. Open Android Studio
2. Go to **Build** → **Generate Signed Bundle/APK**
3. Select **Android App Bundle** (for Play Store)
4. Click **Create new...** under Keystore path
5. Fill in:
   - **Keystore path:** `~/upload-keystore.jks` (or choose a location)
   - **Keystore password:** Choose a strong password (min 6 chars) and **save it!**
   - **Key alias:** `upload` (or your preferred name)
   - **Key password:** Same as keystore password or different (your choice)
   - **Validity:** 10000 days (or max available)
   - **Certificate name:** Your name or company name

6. Click **Create**
7. The keystore file is now at `~/upload-keystore.jks`

### Option B: Command Line (Windows/Mac/Linux)

If you have Java installed:

```bash
# Windows Command Prompt
keytool -genkey -v -keystore %UserProfile%\upload-keystore.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# macOS/Linux Terminal
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

When prompted, enter:
- Keystore password
- Key password
- First name, last name, organization, city, state, country

**Example Input:**
```
Enter keystore password: MyStrongPassword123
Key password (same as keystore password):
First and Last Name: Erdem Canerer
Organization Unit: Zikirmatik
Organization: Zikirmatik
City: Istanbul
State: Istanbul
Country Code: TR
```

---

## Step 2: Set Environment Variables (One-Time Setup)

Flutter's gradle build needs to know where your keystore is and its password.

### Option A: Permanent Environment Variables (Recommended)

**Windows:**
1. Press `Win + X` → Search "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables" button
4. Under "User variables" click "New" and add:

```
Variable Name:  KEYSTORE_PATH
Variable Value: %UserProfile%\upload-keystore.jks

Variable Name:  KEYSTORE_PASSWORD
Variable Value: MyStrongPassword123

Variable Name:  KEY_ALIAS
Variable Value: upload

Variable Name:  KEY_PASSWORD
Variable Value: MyStrongPassword123
```

5. Click OK and restart your terminal/IDE

**macOS/Linux:**
Add to `~/.bashrc` or `~/.zshrc`:

```bash
export KEYSTORE_PATH=~/upload-keystore.jks
export KEYSTORE_PASSWORD=MyStrongPassword123
export KEY_ALIAS=upload
export KEY_PASSWORD=MyStrongPassword123
```

Then restart terminal:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Option B: Temporary (Per Command)

```bash
# Windows PowerShell
$env:KEYSTORE_PATH="$env:UserProfile\upload-keystore.jks"
$env:KEYSTORE_PASSWORD="MyStrongPassword123"
$env:KEY_ALIAS="upload"
$env:KEY_PASSWORD="MyStrongPassword123"

flutter build appbundle --release

# macOS/Linux Terminal
export KEYSTORE_PATH=~/upload-keystore.jks
export KEYSTORE_PASSWORD=MyStrongPassword123
export KEY_ALIAS=upload
export KEY_PASSWORD=MyStrongPassword123

flutter build appbundle --release
```

---

## Step 3: Verify Configuration

Check that `android/app/build.gradle` has the release signing config:

```gradle
signingConfigs {
    release {
        keyAlias System.getenv("KEY_ALIAS") ?: "upload"
        keyPassword System.getenv("KEY_PASSWORD") ?: "password"
        storeFile file(System.getenv("KEYSTORE_PATH") ?: "/path/to/keystore.jks")
        storePassword System.getenv("KEYSTORE_PASSWORD") ?: "password"
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

✅ This is already configured in your repo!

---

## Step 4: Build Release Bundle (AAB) for Play Store

```bash
# Navigate to project root
cd c:\src\GWorks\zikirmatik

# Clean build artifacts (recommended)
flutter clean

# Get dependencies
flutter pub get

# Build release AAB
flutter build appbundle --release
```

**Expected output:**
```
✓ Built build\app\outputs\bundle\release\app-release.aab (16.5 MB)
```

---

## Step 5: Build Release APK (Optional - for testing)

If you want to test the release build on a device first:

```bash
flutter build apk --release
```

**Output:**
```
✓ Built build\app\outputs\apk\release\app-release.apk (12.3 MB)
```

To install on device:
```bash
flutter install -r -d <device-id>
```

---

## Step 6: Verify the Build

### Check File Sizes
- AAB should be 15-20 MB (reasonable for Flutter app)
- APK should be 10-15 MB

### Test APK on Device (Recommended Before Store Upload)

1. Connect Android device to computer
2. Enable Developer Mode + USB Debugging on device
3. Install APK:
   ```bash
   adb install -r build/app/outputs/apk/release/app-release.apk
   ```

4. Test on device:
   - Counter increments correctly
   - Reset works
   - Custom zikir loads
   - All languages work
   - Themes switch smoothly
   - Settings persist
   - Banner ads display (after app approval on Play Store)

---

## Step 7: Upload to Google Play Console

1. **Create/Open Google Play Console account** at https://play.google.com/console

2. **Create new app:**
   - Click "Create app"
   - App name: `Zikirmatik`
   - Default language: English
   - Type: App
   - Category: Lifestyle
   - ESRB rating: Not applicable / Skip

3. **Fill Store Listing:**
   - Complete all fields from [STORE_LISTING.md](STORE_LISTING.md)
   - Upload screenshots (5 required)
   - Upload feature graphic (1024×500)

4. **Upload AAB:**
   - Go to **Release** → **Production**
   - Click "Create new release"
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Add release notes (optional)
   - Review & confirm

5. **Complete Setup:**
   - Content Rating: Fill IARC questionnaire
   - Pricing & Distribution: Free, worldwide (or select countries)
   - App Access: Confirm no restricted content
   - Ads: Yes (AdMob)

6. **Submit for Review:**
   - Click "Review and roll out to production"
   - Google automatically reviews (usually 24-48 hours)
   - You'll receive email when approved

---

## Troubleshooting

### Error: "unable to find a matching keystore"
- Check KEYSTORE_PATH environment variable is set correctly:
  ```bash
  echo %KEYSTORE_PATH%  # Windows
  echo $KEYSTORE_PATH   # macOS/Linux
  ```
- Verify file exists at that path
- Restart terminal after setting environment variables

### Error: "invalid keystore format"
- Keystore file may be corrupted
- Regenerate keystore using Option A or B above

### Error: "Gradle task assembleRelease failed"
- Clean and rebuild:
  ```bash
  flutter clean
  flutter pub get
  flutter build appbundle --release
  ```
- Check Android SDK is up-to-date: `flutter doctor -v`

### Error: "App Bundle must be signed with the same key as your previous app"
- Once signed, **never switch keystores** for future updates
- Keep backup of `upload-keystore.jks` in safe location
- **Do not lose the keystore password!**

### Banner ads not showing after upload
- App needs approval on AdMob (may take 24-48 hours)
- Check Google Play app still working after approval
- Verify no network errors in Logcat

---

## Next Steps After Approval

1. **Celebrate! 🎉** Your app is live on Google Play Store

2. **Monitor Performance:**
   - Check Play Console Analytics
   - Review user ratings and comments
   - Fix any reported bugs promptly

3. **Plan Updates:**
   - Version 1.1.0: Add sound playback, About dialog
   - Version 1.2.0: Additional languages, statistics tracking
   - Version 2.0.0: iOS release (future)

4. **Update Process for Future Versions:**
   - Increment version in `pubspec.yaml`: `1.0.0+1` → `1.0.1+2` (or `1.1.0+3`)
   - Make code changes
   - Test thoroughly
   - Build new AAB: `flutter build appbundle --release`
   - Upload to Google Play Console (same process)
   - Review takes 24-48 hours again

---

## Important Security Notes

🔐 **Keystore & Passwords:**
- **Backup keystore file** in secure location (external drive, password manager)
- **Never commit keystore** to Git (already in `.gitignore`)
- **Never share keystore password** with anyone
- **Do not lose password** — You cannot recover it; you'd need to create new app on Play Store

🔒 **Update Keys:**
- Once set, cannot change signing key for an app
- All future versions must use **same keystore and key**
- Consider using a password manager to store keystore path and passwords

---

## Quick Reference Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build AAB (Play Store)
flutter build appbundle --release

# Build APK (Device testing)
flutter build apk --release

# Install APK on device
adb install -r build/app/outputs/apk/release/app-release.apk

# Uninstall for testing
adb uninstall com.example.zikirmatik

# View APK contents (verification)
unzip -l build/app/outputs/apk/release/app-release.apk
```

---

**Happy releasing! 🚀**

For questions or issues, see:
- [PRIVACY_POLICY.md](PRIVACY_POLICY.md)
- [STORE_LISTING.md](STORE_LISTING.md)
- [README.md](README.md)
- GitHub Issues: https://github.com/mcanererdem/zikirmatik/issues
