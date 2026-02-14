# Zikirmatik - Güncellemeler

## Yeni Özellikler (v1.1.0)

### 1. Lokasyon Bazlı Otomatik Dil Seçimi ✅
- İlk açılışta uygulama **İngilizce** olarak başlar
- Kullanıcının lokasyonu tespit edilir (izin verilirse)
- Lokasyona göre otomatik dil seçimi yapılır:
  - **Türkiye** → Türkçe
  - **Arap Ülkeleri** (SA, AE, EG, IQ, JO, KW, LB, LY, MA, OM, PS, QA, SD, SY, TN, YE, BH, DZ) → Arapça
  - **Endonezya** → Endonezce
  - **Diğer** → İngilizce (varsayılan)

### 2. Endonezce Dil Desteği ✅
- Tam Endonezce çeviri eklendi
- Endonezya pazarı için optimize edildi
- Tüm UI elementleri çevrildi

### 3. Varsayılan Dil İngilizce ✅
- Uygulama artık varsayılan olarak İngilizce açılıyor
- Global kullanıcılar için daha erişilebilir
- Ayarlardan istediğiniz dili seçebilirsiniz

### 4. Geliştirilmiş Erişilebilirlik ✅
- Tüm butonlara semantik etiketler eklendi
- Ekran okuyucu (TalkBack/VoiceOver) desteği iyileştirildi
- Accessibility standartlarına uygun

## Teknik Değişiklikler

### Yeni Paketler
```yaml
geolocator: ^11.0.0      # Lokasyon tespiti
geocoding: ^3.0.0        # Ülke kodu belirleme
```

### Yeni Servisler
- `LocationService`: Lokasyon bazlı dil seçimi için
- Otomatik dil algılama mantığı

### İzinler
**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

**iOS (Info.plist):**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to automatically set your preferred language based on your region.</string>
```

## Desteklenen Diller

1. **English** (en) - Varsayılan
2. **Türkçe** (tr)
3. **العربية** (ar)
4. **Bahasa Indonesia** (id) - YENİ!

## Kullanım

### İlk Açılış
1. Uygulama İngilizce olarak açılır
2. Lokasyon izni istenir (opsiyonel)
3. İzin verilirse, lokasyona göre dil otomatik değişir
4. İzin verilmezse, İngilizce kalır

### Dil Değiştirme
1. Ayarlar → Dil
2. İstediğiniz dili seçin
3. Seçim kaydedilir ve bir daha sorulmaz

## Gelecek Güncellemeler

### Planlanan Özellikler
- [ ] Urduca dil desteği (Pakistan/Hindistan)
- [ ] Bengalce dil desteği (Bangladeş)
- [ ] Malayca dil desteği (Malezya)
- [ ] Farsça dil desteği (İran)
- [ ] Widget desteği
- [ ] İstatistik paneli
- [ ] Hatırlatıcılar

## Notlar

- Lokasyon izni **opsiyoneldir**, uygulama izin olmadan da çalışır
- Lokasyon sadece ilk açılışta kullanılır
- Lokasyon verisi **hiçbir yere gönderilmez**, sadece dil seçimi için kullanılır
- Kullanıcı istediği zaman ayarlardan dili değiştirebilir

## Paket Kurulumu

Yeni paketleri kurmak için:
```bash
cd zikirmatik
flutter pub get
```

## Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```
