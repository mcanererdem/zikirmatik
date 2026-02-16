# Zikirmatik 📿

Sade, kullanımı kolay ve erişilebilirlik odaklı bir dijital tesbih (zikirmatik) uygulaması.

**Geliştirici:** Caner Erdem  
**Temel Amaç:** Zikir saymayı kolaylaştırmak ve sayıyı kaydetmek. Müslümanlar tarafından günlük ibadetlerinde veya kişisel zikirlerinde kullanılabilir.

## Özellikler ✨

### Temel Özellikler
- 🔢 **Tıklanabilir Sayaç:** Ana butona tıklayarak sayıyı artırın
- 💾 **Veri Korunması:** Uygulama kapandıktan sonra bile veriler kaydedilir (SharedPreferences)
- 🌍 **15 Dil Desteği:** Türkçe, İngilizce, Arapça, Endonezce, Urduca, Bengalce, Malayca, Farsça, Fransızca, Çince, Japonca, Rusça, Almanca, Svahili, Hausa
- 🎨 **Tema Seçenekleri:** Mavi/Altın, Koyu, Mint vb temalar + Dark mode
- ⚙️ **Ayarlanabilir:** Titreşim, ses, konfeti, dil, tema ayarları (İlk açılışta tümü kapalı)

### Hedef ve İstatistikler
- 🎯 **Çoklu Hedef Sistemi:** Günlük/haftalık/aylık zikr bazlı hedefler (bağımsız ilerleme takibi)
- 🏆 **Trophy Sistemi:** Tamamlanan hedefler için kupa ve başarı takibi
- 🔥 **Streak Takibi:** Ardışık gün/hafta/ay başarı serileri (aynı gün birden fazla hedef desteği)
- 📊 **Gelişmiş İstatistikler:** Günlük, haftalık, aylık grafikler ve detaylı analiz

### Ek Özellikler
- 📱 **Home Screen Widget:** Android ana ekran widget'ı ile hızlı erişim (tam senkronizasyon + istatistik gösterimi)
- ➕ **Özel Zikir:** Kendi zikirlerinizi ekleyin (15 dil desteği ile)
- 📢 **Reklam Desteği:** Banner ve rewarded reklamlar (test mode aktif)
- 🔄 **Rotasyon Desteği:** Cihazı döndürünce veri korunur
- ♿ **Erişilebilirlik:** Ekran okuyucu desteği (TalkBack/VoiceOver)
- 🎯 **Hedef Bildirimi:** Hedefe ulaşınca titreşim, animasyon ve streak mesajları
- 💬 **Hakkında Sayfası:** GitHub repo ve iletişim bilgileri

## Başlangıç

### Gereksinimler

- Flutter 3.0+ SDK
- Dart 3.0+
- Android SDK (Android geliştirme için)
- Xcode (iOS geliştirme için)

### Kurulum

```bash
# Repository klonla
git clone https://github.com/mcanererdem/zikirmatik.git
cd zikirmatik

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

### Uygulamayı Build Et

```bash
# Debug APK (Android)
flutter build apk --debug

# Release APK (Android)
flutter build apk --release

# iOS
flutter build ios
```

## Teknolojiler 🛠️

- **Flutter:** UI framework
- **Dart:** Programlama dili
- **SharedPreferences:** Yerel veri depolama
- **Vibration:** Titreşim efektleri
- **AudioPlayers:** Ses efektleri
- **Google Mobile Ads:** AdMob entegrasyonu (banner + rewarded)
- **Home Widget:** Android widget desteği
- **URL Launcher:** Dış bağlantılar için
- **Package Info Plus:** Uygulama versiyon bilgisi

## Proje Yapısı

```
zikirmatik/
├── lib/
│   ├── main.dart                 # Uygulama giriş noktası
│   ├── screens/
│   │   ├── home_page.dart        # Ana ekran (650 satır - refactored)
│   │   ├── statistics_screen.dart # İstatistik ekranı (trophy + streak)
│   │   └── about_screen.dart      # Hakkında sayfası
│   ├── widgets/
│   │   ├── target_dialog.dart    # Hedef belirleme dialogu
│   │   ├── add_zikr_dialog.dart  # Zikir ekleme dialogu (15 dil)
│   │   ├── settings_dialog.dart  # Ayarlar dialogu (rewarded ad)
│   │   ├── goal_dialog.dart      # Hedef dialogu
│   │   └── success_dialog.dart   # Başarı dialogu
│   ├── models/
│   │   ├── zikr_model.dart       # Zikir modeli
│   │   ├── theme_model.dart      # Tema modeli
│   │   ├── goal_model.dart       # Hedef modeli
│   │   ├── trophy_model.dart     # Trophy ve streak modeli
│   │   └── statistics_model.dart # İstatistik modeli
│   ├── services/
│   │   ├── settings_service.dart # Ayarlar servisi
│   │   ├── ad_service.dart       # AdMob servisi (banner + rewarded)
│   │   ├── widget_service.dart   # Widget servisi
│   │   ├── counter_logic.dart    # Sayaç mantığı (extracted)
│   │   ├── audio_manager.dart    # Ses yönetimi (extracted)
│   │   └── feedback_manager.dart # Titreşim yönetimi (extracted)
│   └── utils/
│       └── localizations.dart    # Çoklu dil (15 dil, 80+ key)
├── assets/
│   ├── icons/                    # Uygulama ikonu
│   └── sounds/                   # Ses efektleri
└── pubspec.yaml                  # Proje bağımlılıkları
```

## AdMob Ayarı 🎯

**Production Ad Unit ID (Android):** `ca-app-pub-8195806446886861/1390869911`

- Debug modda: Test reklamlar otomatik kullanılır
- Release modda: Production ID aktif (app approval şartıyla)

## Store Yayıncılığı 📱

### Google Play Store'a Yükleme

Uygulamanın Google Play Store'a yüklenmesi için ayrıntılı rehberler:

- **[RELEASE_BUILD_GUIDE.md](RELEASE_BUILD_GUIDE.md)** — Keystore oluşturma, release build alma, ve store'a yükleme adım adım
- **[STORE_LISTING.md](STORE_LISTING.md)** — Google Play Store listeleme bilgisi, açıklamalar, ekran görüntüleri
- **[SCREENSHOT_GUIDE.md](SCREENSHOT_GUIDE.md)** — Ekran görüntüsü alma rehberi
- **[PRIVACY_POLICY.md](PRIVACY_POLICY.md)** — Gizlilik politikası (store tarafından gerekli)

### Release Build Yöntemi

```bash
# 1. Keystore oluştur (ilk seferinde)
# bkz. RELEASE_BUILD_GUIDE.md → Step 1

# 2. Environment değişkenlerini ayarla
# bkz. RELEASE_BUILD_GUIDE.md → Step 2

# 3. Release AAB oluştur
flutter build appbundle --release

# Çıktı: build/app/outputs/bundle/release/app-release.aab
```

Detaylı talimatlar için [RELEASE_BUILD_GUIDE.md](RELEASE_BUILD_GUIDE.md) dosyasını okuyunuz.

## İletişim 💬

- **Email:** mcanererdem@gmail.com
- **GitHub:** [github.com/mcanererdem/zikirmatik](https://github.com/mcanererdem/zikirmatik)

## Geri Bildirim 💬

Buğ bulunuz veya özellik eklemek isteyenler lütfen [Issues](https://github.com/mcanererdem/zikirmatik/issues) kısmını kullanınız.

## Lisans 📄

MIT Lisansı altında sunulmaktadır.

---

صنعته بحب وإخلاص ❤️
