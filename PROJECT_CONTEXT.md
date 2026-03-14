# Zikirmatik – Proje Bağlamı ve Kullanıcı Bilgileri

Bu dosya Cursor prompt'larında, TODO kurallarında ve agent özelliklerinde referans olarak kullanılabilir. Güncel tutun.

---

## Uygulama Özeti

- **İsim:** Tasbih Counter / Zikirmatik
- **Platform:** Flutter (Android öncelikli, iOS desteklenir)
- **Backend:** Supabase (auth, storage avatars, leaderboard, user_achievements)
- **Dil:** Çoklu dil (tr, en, ar, id, ur, bn, ms, fa, fr, zh, ja, ru, de, sw, ha) – `DynamicLocalizationHelper` + `lib/utils/localizations.dart`

---

## Önemli Dosya Yolları

| Konu | Dosya(lar) |
|------|------------|
| Tema | `lib/models/theme_model.dart`, `lib/screens/settings_screen.dart` |
| Tema id eşlemesi | `theme_model.dart`: `ocean_blue`=Midnight Blue, `pure_dark`=Dark (eski `dark_mode` → `pure_dark` map edilir) |
| Success dialog | `lib/widgets/success_dialog.dart` |
| Lokalizasyon | `lib/utils/localizations.dart` (tr/en key'ler), `lib/utils/dynamic_localization_helper.dart` |
| Leaderboard | `lib/services/supabase_service.dart` (getDailyLeaderboard, getLeaderboard), `lib/screens/leaderboard_screen.dart` |
| Profil / avatar / kupalar | `lib/screens/profile_screen.dart`, `lib/services/supabase_service.dart` (uploadAvatar, getUserAchievements) |
| Bildirimler | `lib/widgets/notification_settings_dialog.dart`, `lib/services/notification_service.dart`, `lib/main.dart` (timezone set) |
| Kurallar | `PROJECT_RULES.md`, `TODO.md` |

---

## Bilinen Sorunlar ve Çözümler

1. **Profil fotoğrafı**
   - Bulut (Supabase Storage) yükleme başarısız olursa fotoğraf **yerel** olarak kaydedilir (`avatar_path_${userId}`) ve ekranda gösterilir.
   - **403 RLS hatası:** Supabase Dashboard > Storage'da `avatars` bucket'ı oluşturulmalı; storage politikaları **`supabase_schema.sql`** sonunda (avatars INSERT/SELECT/UPDATE).
   - Avatar önceliği: yerel dosya varsa `FileImage`, yoksa `avatar_url` (Supabase) ile `NetworkImage`.

2. **Kupalar**
   - Kazanılan kupalar profil açılışında Supabase `getUserAchievements` ile çekilir ve yerel prefs ile birleştirilir; prefs güncellenir ki ana sayfa ve kupa ekranı da görsün.

3. **Leaderboard**
   - **Tüm Zamanlar:** `getAllTimeLeaderboard()` → `users` tablosu, `total_zikrs` sıralı.
   - **Günlük:** `getLeaderboard()` → `leaderboard_daily` (bugünün tarihi); liste boşsa veya test için `supabase_leaderboard_test_data.sql` çalıştırılabilir.
   - RLS: `users` için "Public can read users for leaderboard" politikası ile herkes okuyabilir.
   - `user_id` UUID ile karşılaştırma yapılır (`toUuid(currentUserId)`).

4. **Bildirimler (zamanında gelmeme)**
   - Uygulama başlangıcında cihaz zaman dilimi `flutter_timezone` ile alınıp `tz.setLocalLocation` ile ayarlanır.
   - Android 12+ için kayıt sırasında `requestExactAlarmsPermission()` çağrılır.
   - Kullanıcıya pil optimizasyonundan muaf tutma ipucu bildirim ayarları diyaloğunda gösterilir.

5. **Temalar**
   - Ayarlarda dördüncü tema (Koyu/Dark) id'si `pure_dark`; eski `dark_mode` de `theme_model` içinde `pure_dark` olarak eşlenir.

6. **Success dialog**
   - `success_title` ve `success_message` lokalize edilmeli (tr/en key'leri `localizations.dart` içinde); şeffaf arka plan kaldırıldı, tema renkleri kullanılıyor.

---

## Prompt / Agent İpuçları

- Yeni metin eklerken mutlaka lokalizasyon kullanın: `DynamicLocalizationHelper.getText({ 'tr': '...', 'en': '...' })` veya `localizations` key.
- Tema rengi kullanın: `themeConfig.textColor`, `themeConfig.primaryColor`, `themeConfig.accentColor`, `themeConfig.backgroundGradient`.
- Supabase kullanıcı id'si bazen `user_xxx` formatında; UUID gereken yerlerde `SupabaseService.toUuid(userId)` kullanın.
- Kupalar: achievement_id değerleri `bronze_kupa`, `silver_kupa`, `gold_kupa`, `diamond_kupa`, `platinum_kupa`.

---

## Leaderboard test (Supabase’e kullanıcı ekleme)

Leaderboard’un çalıştığını doğrulamak için:

1. **Uygulama üzerinden:** Kullanıcı zikir sayar, Ayarlar’da “Liderlik tablosuna senkronize et” açıksa hedefe ulaşınca veya senkron tetiklenince `SupabaseService.updateDailyLeaderboard` / `updateUserProfile` ile veri gönderilir. Supabase’de `users` ve `daily_leaderboard` (veya kullandığınız tablo) RLS politikaları buna izin veriyorsa kayıt oluşur.
2. **Manuel test verisi:** Supabase Dashboard → Table Editor → `users` tablosuna satır ekleyin: `id` (UUID), `username`, `display_name`, `total_zikrs` (opsiyonel). Günlük sıra için `daily_leaderboard` benzeri tabloya `user_id` (UUID), `daily_count` vb. ekleyin. Uygulama tarafında `currentUserId` genelde `user_xxx` formatında; `SupabaseService.toUuid(userId)` ile UUID’e çevriliyor, tablolarda UUID kullanılıyor.
3. **RLS:** `users` ve leaderboard tablolarında SELECT/INSERT/UPDATE için anon veya authenticated rolüne uygun politikaların açık olduğundan emin olun.

---

**Son güncelleme:** Bu dosyayı önemli değişiklik veya yeni bilinen sorun sonrası güncelleyin.
