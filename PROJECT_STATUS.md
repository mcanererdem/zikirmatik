# Zikirmatik – Proje Durumu

Son güncelleme: 2025-03-12

Bu dosya hangi ekran/servisin aktif olduğu, hangi dosyaların silineceği ve kısa mimari notları içerir. Cursor ve geliştirme kararları bu dosyaya göre verilebilir.

---

## Aktif Ekranlar ve Dosyalar

| Ekran / Özellik | Kullanılan dosya | Açıklama |
|-----------------|-------------------|----------|
| Ana sayfa | `lib/screens/home_page.dart` | Sayaç, tema, dil, navigasyon. |
| Ayarlar | `lib/screens/settings_screen.dart` | Dil, tema, bildirim, içe/dışa aktar, destek, hakkında. |
| Ayarlar (dialog) | `lib/widgets/settings_dialog_new.dart` | Bazı ayar menüleri buradan açılıyor. |
| Kupalar | `lib/screens/kupa_screen_new.dart` | KupaScreenNew – ana kupa ekranı. |
| İstatistikler | `lib/screens/statistics_screen_new.dart` | |
| Profil | `lib/screens/profile_screen.dart` | |
| Liderlik | `lib/screens/leaderboard_screen.dart` | |
| İçe/Dışa aktar | `lib/screens/import_export_screen.dart` | |
| Destek | `lib/screens/support_screen_new.dart` | SupportScreenNew kullanılıyor. |
| Hakkında | `lib/screens/about_screen.dart` (veya AboutScreenNew) | settings_screen.dart → AboutScreen; settings_dialog_new → AboutScreenNew. Hangisi resmî karar verilmeli. |
| Splash | `lib/screens/splash_screen.dart` | |

---

## Eski / Kaldırılacak veya Birleştirilecek Dosyalar

| Dosya | Önerilen aksiyon | Not |
|-------|-------------------|-----|
| ~~settings_screen_old~~ | Silindi | |
| ~~kupa_screen~~ | Silindi | |
| ~~support_screen~~ | Silindi | |
| ~~localizations_broken~~ | Silindi | |
| `lib/screens/home_page_backup.dart` | İsteğe bağlı | Yedek; varsa kaldırılabilir. |
| `lib/screens/about_screen_new.dart` | Karar verilecek | AboutScreen mi AboutScreenNew mi resmî olacak; biri kaldırılacak veya tek isim altında birleştirilecek. |
| `lib/utils/dialog_manager.dart` vs `lib/widgets/dialog_manager.dart` | Birleştir / tek dosya bırak | Hangi dosyanın nerede kullanıldığı grep ile kontrol edilmeli; tek bir dialog_manager kullanılmalı. |

---

## Localization Stratejisi

- **Şu an:** İki sistem var: `AppLocalizations` (localizations.dart) ve `DynamicLocalizationHelper` (dynamic_localization_helper.dart).
- **Hedef:** Uzun vadede tek sistem (tercihen AppLocalizations veya Flutter’ın yerel l10n’i). Yeni metinler için statik string yazılmamalı.
- **MaterialApp:** `locale: Locale(_currentLanguage)` eklendi; dil değişince ağaç bu locale ile yeniden build ediliyor.

---

## Kısa Mimari Not

- Servisler: SettingsService, CounterLogic, SupabaseService, WidgetService, NotificationService, TtsService, vb. doğrudan kullanılıyor; henüz DI yok.
- IMPROVEMENT_PLAN.md: Phase 1 (stabilizasyon, test), Phase 2 (kod kalitesi, feature flag), Phase 3 (yeni özellikler) takip edilebilir.

---

## Yapılacaklar (kısa vade)

- [ ] Statik metinleri localization’a taşı (settings, profile, statistics, kupa, about, support, import_export).
- [ ] AboutScreen vs AboutScreenNew kararı ver; gereksiz dosyayı kaldır.
- [ ] Eski dosyaları (settings_screen_old, kupa_screen, support_screen, localizations_broken) referans kontrolü sonrası sil.
- [ ] dialog_manager çakışmasını çöz; tek dosya bırak.

Tüm görevler **TODO.md** dosyasında (Kanban). Tek kaynak orası.  “yapılacaklar” 