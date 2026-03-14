# Zikirmatik – Proje Kuralları

Cursor ve geliştirme sırasında dikkat edilecek kurallar. Bu dosyayı `.cursorrules` veya Cursor’da referans olarak kullanabilirsiniz.

---

## Dil ve metin (localization)

- **Yeni metin eklerken:** Statik Türkçe/İngilizce string yazmayın. `AppLocalizations` (widget.localizations) veya `DynamicLocalizationHelper.getText({ 'tr': '...', 'en': '...', ... })` kullanın.
- **Mevcut statik metinler:** Zamanla `lib/utils/localizations.dart` veya `dynamic_localization_helper.dart` içindeki anahtarlara taşınmalı; ekranlarda doğrudan sabit metin kalmamalı.
- **Dil değişimi:** Ayarlardan dil değişince `onLanguageChanged` ile üst widget (MyApp) güncellenmeli; MaterialApp `locale` ile doğru dilde build edilmeli.

---

## Ekranlar ve dosya kullanımı

- **Aktif ayar ekranı:** `lib/screens/settings_screen.dart`. `settings_screen_old.dart` kullanılmıyor.
- **Kupalar:** `KupaScreenNew` (`kupa_screen_new.dart`). Eski `KupaScreen` (`kupa_screen.dart`) kullanılmıyor.
- **Destek:** `SupportScreenNew` (`support_screen_new.dart`). Eski `SupportScreen` kullanılmıyor.
- **Hakkında:** `AboutScreen` (`about_screen.dart`) ayarlardan açılıyor; `AboutScreenNew` sadece `settings_dialog_new` içinde kullanılıyor. Tek ekran kararı TODO’da.
- **Eski/kırık dosyalar:** `localizations_broken.dart`, yedek/old ekranlar referans alınmamalı; silindiyse import’lar da kaldırılmalı.

---

## Tema ve UI

- **Tema:** Ekranlarda `ThemeConfig` ve `AppThemes` kullanın; renkler için tema renkleri (textColor, accentColor, primaryColor, backgroundGradient) kullanılsın.
- **Font:** `GoogleFonts.notoSans` kullanılıyor; tutarlılık için yeni sayfalarda da aynı font ailesi tercih edilsin.

---

## Servisler ve state

- **Ayarlar:** `SettingsService` ile SharedPreferences üzerinden okuma/yazma yapılıyor.
- **Dil:** Hem `SettingsService.getLanguage/saveLanguage` hem `DynamicLocalizationHelper.setLanguage/getText` kullanılıyor; dil değişince ikisi de güncellenmeli.
- **Yeni servis:** Doğrudan singleton/global instance yerine ileride dependency injection düşünülebilir; şimdilik mevcut pattern korunabilir.

---

## Genel

- **Yeni özellik:** Önce TODO.md’ye madde ekleyin; hangi ekran/servisten açılacağı net olsun.
- **Android/test sonrası hata:** Cihazda test edip hata bulursanız TODO.md'de Todo veya In Progress'e madde ekleyin.
- **Supabase/Profil/İzinler:** Supabase (profil, leaderboard) entegrasyonu ve profil resmi seçme akışı elden geçirilmeli; depolama/medya izinleri kontrol edilsin. Export paylaş menüsü ile kullanıcıya sunulur; ayarlar theme_id, language_code, vibration_enabled ile uyumlu.
- **Silinecek dosya:** Silmeden önce projede referans aranmalı (grep ile import ve sınıf kullanımı); referans kaldırıldıktan sonra dosya silinmeli.
