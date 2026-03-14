# Zikirmatik – Yapılacaklar (Kanban)

Tek kaynak: tüm görevler bu dosyada. Cursor'da `@TODO.md` ile referans ver. Proje bağlamı ve bilinen sorunlar için `@PROJECT_CONTEXT.md`.

---

## Done

- [x] MaterialApp'e `locale: Locale(_currentLanguage)` eklendi
- [x] TODO.md (bu dosya) oluşturuldu
- [x] PROJECT_RULES.md oluşturuldu (localization, ekran kullanımı, tema, servis kuralları)
- [x] Eski dosyalar silindi: settings_screen_old, kupa_screen, support_screen, localizations_broken
- [x] Dil değişiminde MyApp güncellenmesi: SettingsScreen'e onLanguageChanged eklendi, HomePage'den iletiliyor
- [x] Import/Export durum mesajları lokalize edildi
- [x] Export konumu: Paylaş menüsü ile kullanıcı dosyayı İndirilenler'e veya istediği yere kaydedebiliyor (Share.shareFiles)
- [x] Export/Import ayar anahtarları SettingsService ile eşleştirildi (theme_id, language_code, vibration_enabled vb.)
- [x] Profil fotoğrafı: bulut yükleme başarısızsa yerel kayıt ve gösterim (avatar_path_, _localAvatarPath)
- [x] Kupalar: Supabase getUserAchievements ile senkron, profil açılışında prefs güncellenir
- [x] Ayarlar tema: Koyu tema id pure_dark; dark_mode → pure_dark eşlemesi theme_model'de
- [x] Success dialog: success_title/success_message lokalize, transparan kaldırıldı; ayarlar tema bölümü yazı rengi themeConfig.textColor
- [x] Bildirimler: cihaz timezone (flutter_timezone) main'de ayarlanıyor; Android exact alarm isteği; pil ipucu
- [x] PROJECT_CONTEXT.md oluşturuldu (proje bağlamı, bilinen sorunlar, prompt ipuçları)

---

## In Progress

- [ ] Statik metinleri localization'a taşı (settings, profile, statistics, kupa, about, support, import_export)
- [ ] lib sayfalarında dinamik olmayan yazı/text kalmaması (dil değişince hepsi güncellensin)

---

## Todo

- [x] Supabase Storage: avatars politikaları `supabase_schema.sql` içinde (tek dosyada kurulum)
- [ ] Gerekli izinler: depolama/medya (export, profil resmi) ve Supabase için kontrol edilsin
- [ ] AboutScreen vs AboutScreenNew kararı ver; gereksiz dosyayı kaldır
- [ ] dialog_manager çakışmasını çöz (lib/utils vs lib/widgets); tek dosya bırak
- [ ] SupabaseService'e deleteUser metodu ekle (profile_screen TODO)

---

## Backlog

- [ ] Paylaşım: oyun achievement gibi görsel kart (kupa + istatistik) oluşturup paylaş (ör. screenshot/render to image)
- [ ] CounterLogic refactor
- [ ] WidgetService platform bağımsız hale getir
- [ ] Error handling standardizasyonu
- [ ] Feature flag sistemi

---

**Kullanım:** Bir görevi yapmaya başlayınca ilgili satırı **In Progress** bölümüne kesip yapıştırın. Bitince **Done** bölümüne taşıyıp `[ ]` → `[x]` yapın.
