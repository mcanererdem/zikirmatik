# Zikirmatik 📿

Sade, kullanımı kolay ve erişilebilirlik odaklı bir dijital tesbih (zikirmatik) uygulaması.

**Geliştirici:** Caner Erdem  
**Temel Amaç:** Zikir saymayı kolaylaştırmak ve sayıyı kaydetmek. Müslümanlar tarafından günlük ibadetlerinde veya kişisel zikirlerinde kullanılabilir.

## Özellikler ✨

- 🔢 **Tıklanabilir Sayaç:** Ana butona tıklayarak sayıyı artırın
- 💾 **Veri Korunması:** Uygulama kapandıktan sonra bile veriler kaydedilir (SharedPreferences)
- 🌍 **Çoklu Dil:** Türkçe, İngilizce, Arapça, Endonezce desteği
- 📍 **Otomatik Dil:** İlk açılış İngilizce, sonra lokasyona göre otomatik dil seçimi
- 🎨 **Tema Seçenekleri:** Mavi/Altın, Koyu, Mint vb temalar + Dark mode
- ⚙️ **Ayarlanabilir:** Titreşim, ses, konfeti, dil, tema ayarları (İlk açılışta tümü kapalı)
- 📊 **İstatistikler:** Günlük, toplam ve son 7 gün grafiği + streak takibi
- 🎯 **Hedef Sistemi:** Günlük/haftalık/aylık zikr bazlı hedefler
- 🔔 **Hatırlatıcılar:** Zamanlanmış günlük bildirimler
- 📊 **Özel Hedefler:** Hızlı seçenekler (33, 99, 100, 500, 1000) veya özel sayı girin
- ➕ **Özel Zikir:** Kendi zikirlerinizi ekleyin (sadece Arapça alan, diğer diller otomatik)
- 📢 **AdMob Entegrasyonu:** Banner reklamlar (test mode aktif)
- 🔄 **Rotasyon Desteği:** Cihazı döndürünce veri korunur
- ♿ **Erişilebilirlik:** Ekran okuyucu desteği (TalkBack/VoiceOver)
- 🎯 **Hedef Bildirimi:** Hedefe ulaşınca titreşim ve animasyon
- 📱 **Home Screen Widget:** Android ana ekran widget’ı ile hızlı erişim

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
- **Google Mobile Ads:** AdMob entegrasyonu
- **Flutter Local Notifications:** Hatırlatıcılar
- **Geolocator & Geocoding:** Lokasyon bazlı dil seçimi
- **Flutter Launcher Icons:** Uygulama ikonu

## Proje Yapısı

```
zikirmatik/
├── lib/
│   ├── main.dart                 # Uygulama giriş noktası
│   ├── screens/
│   │   ├── home_page.dart        # Ana ekran
│   │   └── statistics_screen.dart # İstatistik ekranı
│   ├── widgets/
│   │   ├── target_dialog.dart    # Hedef belirleme dialogu
│   │   ├── add_zikr_dialog.dart  # Zikir ekleme dialogu
│   │   ├── settings_dialog.dart  # Ayarlar dialogu
│   │   ├── reminder_dialog.dart  # Hatırlatıcı dialogu
│   │   └── success_dialog.dart   # Başarı dialogu
│   ├── models/
│   │   ├── zikr_model.dart       # Zikir modeli
│   │   ├── theme_model.dart      # Tema modeli
│   │   ├── goal_model.dart       # Hedef modeli
│   │   └── statistics_model.dart # İstatistik modeli
│   ├── services/
│   │   ├── settings_service.dart # Ayarlar servisi
│   │   ├── ad_service.dart       # AdMob servisi
│   │   ├── notification_service.dart # Bildirim servisi
│   │   ├── location_service.dart # Lokasyon servisi
│   │   └── widget_service.dart   # Widget servisi
│   └── utils/
│       └── localizations.dart    # Çoklu dil
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

Uygulamayı Google Play Store'a yüklemek isteyenler için ayrıntılı rehberler:

- **[RELEASE_BUILD_GUIDE.md](RELEASE_BUILD_GUIDE.md)** — Keystore oluşturma, release build alma, ve store'a yükleme adım adım
- **[STORE_LISTING.md](STORE_LISTING.md)** — Google Play Store listeleme bilgisi, açıklamalar, ekran görüntüleri
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

## Geri Bildirim 💬

Buğ bulunuz veya özellik eklemek isteyenler lütfen [Issues](https://github.com/mcanererdem/zikirmatik/issues) kısmını kullanınız.

## Lisans 📄

MIT Lisansı altında sunulmaktadır.

---

صنعته بحب وإخلاص ❤️
