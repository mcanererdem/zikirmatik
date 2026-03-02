# Zikirmatik - Konsol Yapılandırma Rehberi

## 📱 Uygulama Ayarları ve Konsol Komutları

Bu rehber, Zikirmatik uygulamasının konsoldan yönetilmesi için gerekli komutları ve ayarları içerir.

---

## 🚀 Temel Flutter Komutları

### Proje Kurulumu
```bash
# Proje klonlama
git clone https://github.com/mcanererdem/zikirmatik.git
cd zikirmatik

# Bağımlılıkları yükle
flutter pub get

# Flutter doctor ile kontrol et
flutter doctor -v
```

### Uygulama Çalıştırma
```bash
# Debug modda çalıştır
flutter run

# Belirli cihazda çalıştır
flutter run -d <device_id>

# Cihazları listele
flutter devices
```

### Build İşlemleri
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Release AAB (Google Play için)
flutter build appbundle --release

# iOS build
flutter build ios --release
```

---

## ⚙️ Geliştirme Ayarları

### Environment Setup
```bash
# Flutter güncellemesi
flutter upgrade

# Temizleme
flutter clean
flutter pub get

# Analiz çalıştırma
flutter analyze

# Test çalıştırma
flutter test
```

### Android Ayarları
```bash
# Android build tools kontrol
flutter doctor --android-licenses

# Gradle wrapper güncelleme
cd android
./gradlew wrapper --gradle-version=8.0
cd ..
```

---

## 🎨 Tema ve Dil Ayarları

### Tema Değiştirme (Konsoldan)
```bash
# SharedPreferences ile tema değiştirme (test için)
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es theme_id "blue_gold"

# Mevcut temalar:
# - blue_gold (Safir Altın)
# - green_gold (Zümrüt Parıltı)
# - purple_gold (Kraliyet Gül)
# - dark_night (Karan Gece)
# - moonlight (Ay Işığı)
# - deep_space (Derin Uzay)
# - northern_lights (Kuzey Işıkları)
# - dark_blue (Yıldızlı Gece)
```

### Dil Ayarları
```bash
# Dil değiştirme (test için)
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es language_code "tr"

# Desteklenen diller:
# - tr (Türkçe)
# - en (English)
# - ar (العربية)
# - id (Bahasa Indonesia)
# - ur (اردو)
# - bn (বাংলা)
# - ms (Bahasa Melayu)
# - fa (فارسی)
# - fr (Français)
# - zh (中文)
# - ja (日本語)
# - ru (Русский)
# - de (Deutsch)
# - sw (Swahili)
# - ha (Hausa)
```

---

## 🔔 Bildirim Ayarları

### Bildirim Test Komutları
```bash
# Bildirim servisi test
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es notification_test "true"

# Hatırlatıcı zamanı ayarlama (saat:dakika formatında)
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es reminder_time "21:00"

# Hatırlatıcı günleri ayarlama (Pzt,Sal,Çar,Per,Cum,Cmt,Pzr)
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es reminder_days "Pzt,Sal,Çar,Per,Cum"
```

### Bildirim İzinleri
```bash
# Bildirim izinlerini kontrol et
adb shell dumpsys package com.mcanererdem.zikirmatik | grep permission

# Bildirim kanallarını listele
adb shell cmd notification list channels com.mcanererdem.zikirmatik
```

---

## 📊 Veri Yönetimi

### Local Storage İşlemleri
```bash
# SharedPreferences temizleme
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es clear_prefs "true"

# Veri export etme
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es export_data "true"

# Veri import etme
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es import_data "true"
```

### Supabase Bağlantı Test
```bash
# Supabase bağlantısını test et
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es test_supabase "true"

# Leaderboard senkronizasyon test
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es sync_leaderboard "true"
```

---

## 🎯 Hedef ve İstatistikler

### Hedef Sistemi
```bash
# Günlük hedef ayarla
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es daily_target "100"

# Haftalık hedef ayarla
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es weekly_target "500"

# Aylık hedef ayarla
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es monthly_target "2000"
```

### İstatistikleri Sıfırlama
```bash
# Tüm istatistikleri sıfırla
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es reset_stats "true"

# Sadece zikir sayacını sıfırla
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es reset_counter "true"
```

---

## 🎮 Animasyon ve Performans

### Animasyon Hızı Ayarları
```bash
# Animasyon hızını ayarla (0: Kapalı, 1: Yavaş, 2: Normal, 3: Hızlı)
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es animation_speed "0"

# Performans modunu aktif et
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es performance_mode "true"
```

### Efekt Ayarları
```bash
# Titreşim aç/kapat
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es vibration "false"

# Ses aç/kapat
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es sound "false"

# Konfeti aç/kapat
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es confetti "false"
```

---

## 🐛 Hata Ayıklama

### Logları İzleme
```bash
# Flutter logları izle
flutter logs

# Sadece uygulama logları
flutter logs | grep "zikirmatik"

# Spesifik log filtreleme
flutter logs | grep -E "(ERROR|WARN)" | grep "zikirmatik"
```

### Crash Raporları
```bash
# Crash loglarını al
adb logcat -d | grep "AndroidRuntime"

# ANR loglarını al
adb logcat -d | grep "ANR"
```

---

## 📱 Widget Test

### Widget Kurulumu
```bash
# Widget'i manuel ekle
adb shell am broadcast -a android.appwidget.action.APPWIDGET_UPDATE \
  --es appWidgetId 1 \
  --cn com.mcanererdem.zikirmatik.ZikirWidget

# Widget'i güncelle
adb shell am broadcast -a com.mcanererdem.zikirmatik.ACTION_UPDATE_WIDGET
```

---

## 🔧 Gelişmiş Ayarlar

### Test Modu
```bash
# Test modunu aktif et
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es test_mode "true"

# Demo verileri yükle
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es load_demo "true"
```

### Reklam Test
```bash
# Test reklamlarını göster
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es test_ads "true"

# Reklam ID'sini değiştir
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity \
  --es ad_unit_id "ca-app-pub-3940256099942544/5224355221"
```

---

## 🚀 Yayın Hazırlığı

### Sürüm Kontrolü
```bash
# Versiyon bilgisini kontrol et
flutter --version

# Build numarasını artır
cd android
./gradlew assembleRelease
cd ..
```

### İmzalama ve Yükleme
```bash
# APK'i imzala
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore my-key.keystore build/app/outputs/flutter-apk/app-release.apk my-alias

# Play Console'a yükleme hazırlığı
echo "AAB dosyası hazır: build/app/outputs/bundle/release/app-release.aab"
```

---

## 📞 Destek ve İletişim

### Hata Raporlama
```bash
# Sistem bilgileri topla
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
flutter doctor -v > system_info.txt
```

### Geliştirici Bilgileri
```bash
# Geliştirici bilgilerini göster
echo "Developer: Caner Erdem"
echo "Email: mcanererdem@gmail.com"
echo "GitHub: https://github.com/mcanererdem/zikirmatik"
```

---

## 🔍 Güvenlik ve Gizlilik

### Veri Temizleme
```bash
# Tüm kullanıcı verilerini temizle
adb shell pm clear com.mcanererdem.zikirmatik

# Uygulamayı sıfırla
adb shell am force-stop com.mcanererdem.zikirmatik
```

### Güvenlik Test
```bash
# SSL/TLS kontrolü
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es security_test "true"

# Network güvenliği test
adb shell am start -n com.mcanererdem.zikirmatik/.MainActivity --es network_test "true"
```

---

## 📝 Notlar

### Önemli Uyarılar
1. **Test Komutları**: Sadece geliştirme ortamında kullanın
2. **Production**: Test komutları production'da çalışmayabilir
3. **İzinler**: Bazı komutlar root izni gerektirebilir
4. **Yedekleme**: Veri temizleme komutlarından önce yedek alın

### Best Practices
1. Her değişiklikten sonra `flutter analyze` çalıştırın
2. Test etmeden production'a yükleme yapmayın
3. Logları düzenli olarak kontrol edin
4. Performansı izlemek için `flutter run --profile` kullanın

---

**Bu rehber, Zikirmatik uygulamasının konsoldan yönetimi için kapsamlı bir kaynak sağlar. Herhangi bir sorun veya soru için geliştirici ile iletişime geçin.**
