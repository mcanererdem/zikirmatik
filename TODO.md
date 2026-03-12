# Zikirmatik – Yapılacaklar (Kanban)

Tek kaynak: tüm görevler bu dosyada. Cursor'da `@TODO.md` ile referans ver.

---

## Done

- [x] MaterialApp'e `locale: Locale(_currentLanguage)` eklendi
- [x] PROJECT_STATUS.md oluşturuldu
- [x] CURSOR_AND_PROJECT_GUIDE.md oluşturuldu
- [x] TODO.md (bu dosya) oluşturuldu
- [x] PROJECT_RULES.md oluşturuldu (localization, ekran kullanımı, tema, servis kuralları)
- [x] Eski dosyalar silindi: settings_screen_old, kupa_screen, support_screen, localizations_broken
- [x] Dil değişiminde MyApp güncellenmesi: SettingsScreen'e onLanguageChanged eklendi, HomePage'den iletiliyor
- [x] Import/Export durum mesajları lokalize edildi
- [x] Export konumu: Paylaş menüsü ile kullanıcı dosyayı İndirilenler'e veya istediği yere kaydedebiliyor (Share.shareFiles)
- [x] Export/Import ayar anahtarları SettingsService ile eşleştirildi (theme_id, language_code, vibration_enabled vb.)

---

## In Progress

- [ ] Statik metinleri localization'a taşı (settings, profile, statistics, kupa, about, support, import_export)
- [ ] lib sayfalarında dinamik olmayan yazı/text kalmaması (dil değişince hepsi güncellensin)

---

## Todo

- [ ] Supabase entegrasyonunu elden geçir: profil ve leaderboard düzgün çalışmıyor; mantık ve senkronizasyon gözden geçirilsin
- [ ] Profil ekranında resim seçme (avatar yükleme) sorunlarını gider
- [ ] Gerekli izinler: depolama/medya (export, profil resmi) ve Supabase için kontrol edilsin
- [ ] AboutScreen vs AboutScreenNew kararı ver; gereksiz dosyayı kaldır
- [ ] dialog_manager çakışmasını çöz (lib/utils vs lib/widgets); tek dosya bırak
- [ ] SupabaseService'e deleteUser metodu ekle (profile_screen TODO)
- [ ] Android cihazda test; hata çıkarsa buraya madde ekle veya In Progress'e taşı

---

## Backlog

- [ ] CounterLogic refactor
- [ ] WidgetService platform bağımsız hale getir
- [ ] Error handling standardizasyonu
- [ ] Feature flag sistemi

---

**Kullanım:** Bir görevi yapmaya başlayınca ilgili satırı **In Progress** bölümüne kesip yapıştırın. Bitince **Done** bölümüne taşıyıp `[ ]` → `[x]` yapın.
