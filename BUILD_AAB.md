# Google Play için AAB (Android App Bundle) Oluşturma

Bu dosya, Zikirmatik uygulamasını Google Play Console’a yüklemek için release AAB oluşturma adımlarını açıklar.

## 1. Sürüm

- **pubspec.yaml** içindeki `version` değeri kullanılır (örn. `1.1.0+11`).
- `+` sonrası sayı (build number) Play Console’da her yüklemede bir artırılmalıdır.

## 2. Supabase Bağlantısı (Zorunlu)

Release build’de Supabase kullanılıyor. AAB oluştururken **mutlaka** aşağıdaki `--dart-define` parametrelerini verin:

- `SUPABASE_URL`: Projenizin Supabase URL’i
- `SUPABASE_ANON_KEY`: Projenizin anon (public) key’i

Bu değerleri `.env` dosyasından veya ortam değişkenlerinden alabilirsiniz. **.env dosyasını git’e eklemeyin.**

## 3. İmzalama (key.properties)

Proje kökünde `key.properties` dosyası olmalı (git’e eklenmemeli). Örnek:

```properties
storePassword=***
keyPassword=***
keyAlias=upload
storeFile=path/to/your/upload-keystore.jks
```

`storeFile` proje köküne göre yol olabilir (örn. `android/app/upload-keystore.jks`).

## 4. AAB Oluşturma Komutu

### Ortam değişkenleri ile (önerilen)

```bash
# Windows (PowerShell)
$env:SUPABASE_URL="https://XXXXXXXX.supabase.co"
$env:SUPABASE_ANON_KEY="eyJhbGc..."
flutter build appbundle --release --dart-define=SUPABASE_URL=$env:SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY
```

```bash
# Windows (CMD)
set SUPABASE_URL=https://XXXXXXXX.supabase.co
set SUPABASE_ANON_KEY=eyJhbGc...
flutter build appbundle --release --dart-define=SUPABASE_URL=%SUPABASE_URL% --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%
```

```bash
# Linux / macOS
export SUPABASE_URL="https://XXXXXXXX.supabase.co"
export SUPABASE_ANON_KEY="eyJhbGc..."
flutter build appbundle --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

### Değerleri doğrudan yazarak (güvenli değil, sadece test)

```bash
flutter build appbundle --release --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## 5. Çıktı Konumu

Başarılı build sonrası AAB dosyası:

```
build/app/outputs/bundle/release/app-release.aab
```

Bu dosyayı Google Play Console → Uygulamanız → Production (veya Internal testing) → Yeni sürüm oluştur → “App bundle’ları yükle” ile yükleyin.

## 6. Özet Kontrol Listesi

- [ ] `pubspec.yaml` sürümü güncel (version + build number)
- [ ] `key.properties` mevcut ve doğru
- [ ] Build komutunda `SUPABASE_URL` ve `SUPABASE_ANON_KEY` geçirildi
- [ ] `flutter build appbundle --release ...` hatasız tamamlandı
- [ ] `app-release.aab` Play Console’a yüklendi
