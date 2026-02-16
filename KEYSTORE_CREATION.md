# Keystore Oluşturma Rehberi

## 1. Keystore Dosyası Oluşturma

Komut satırında şu komutu çalıştırın:

```bash
keytool -genkey -v -keystore zikirmatik-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zikirmatik
```

### Sorulacak Bilgiler:
- **Keystore password:** Güçlü bir şifre belirleyin (en az 6 karakter)
- **Key password:** Aynı şifreyi kullanabilirsiniz
- **First and last name:** Caner Erdem
- **Organizational unit:** Developer
- **Organization:** Independent
- **City:** İstanbul
- **State:** İstanbul
- **Country code:** TR

## 2. Keystore Bilgilerini Kaydetme

`android/key.properties` dosyası oluşturun:

```properties
storePassword=BURAYA_KEYSTORE_ŞİFRENİZ
keyPassword=BURAYA_KEY_ŞİFRENİZ
keyAlias=zikirmatik
storeFile=../zikirmatik-release-key.jks
```

⚠️ **ÖNEMLİ:** 
- `key.properties` dosyasını `.gitignore`'a ekleyin
- Keystore dosyasını güvenli bir yerde saklayın
- Şifreleri unutmayın (kaybolursa uygulama güncellenemez!)

## 3. Keystore Dosyasını Taşıma

Oluşturulan `zikirmatik-release-key.jks` dosyasını proje ana dizinine taşıyın:
```
zikirmatik/
├── android/
├── lib/
├── zikirmatik-release-key.jks  ← Buraya
└── ...
```

## 4. Build.gradle Kontrolü

`android/app/build.gradle` dosyasında signing config'in olduğundan emin olun (zaten ekli olmalı).

## 5. Release Build Oluşturma

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Build başarılı olursa:
- AAB dosyası: `build/app/outputs/bundle/release/app-release.aab`
- Bu dosyayı Google Play Console'a yükleyeceksiniz

## Sonraki Adım
Keystore oluşturduktan sonra `STORE_LISTING_PREP.md` dosyasına geçin.
