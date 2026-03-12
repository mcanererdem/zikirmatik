# Cursor Verimli Kullanım & Zikirmatik Proje Rehberi

Bu rehber hem Cursor'u verimli kullanmanız hem de projeyi düzenli ilerletmeniz için hazırlandı.

---

## Bölüm 1: Cursor'u Verimli Kullanma

### Temel İpuçları
- **Chat (Cursor Chat):** Kod hakkında soru sorun, "bu dosyada X nerede?", "Y özelliğini nasıl eklerim?" gibi. Dosya yolu verirseniz (`@lib/screens/settings_screen.dart`) daha isabetli cevap alırsınız.
- **Composer (Cmd/Ctrl + I):** Birden fazla dosyada değişiklik yapmak için. "Tüm ekranlarda statik Türkçe metinleri localization'a taşı" gibi büyük görevlerde kullanın.
- **Agent modu:** Kompleks, çok adımlı işlerde (refactor, test yazma, temizlik) "Agent" seçeneği ile ajanın adım adım ilerlemesini sağlayabilirsiniz.

### Önerilen Eklentiler / Araçlar
| Araç | Ne işe yarar |
|------|----------------|
| **Flutter** | Dart/Flutter syntax, run/debug, pub get. Zaten kullanıyorsanız sorun yok. |
| **Dart Data Viewer** | Model/list verilerini debug ekranında görmek. |
| **Error Lens** | Hataları satırın yanında gösterir, hızlı fark edersiniz. |

### MCP (Model Context Protocol) – İsteğe bağlı
- **Git MCP:** Commit mesajı önerisi, branch stratejisi için.
- **Notion MCP:** Proje takibini Notion’da yapıyorsanız, Cursor’dan sayfa oluşturma/güncelleme.
- Şu an için proje tek kişi ve kapalı beta aşamasında; MCP’yi zorunlu görmeyebilirsiniz. İleride "Notion’a bug listesi yaz" gibi otomasyon isterseniz ekleyebilirsiniz.

### Hangi "Ajan" Ne Zaman?
- **Hızlı cevap (daha az token):** Küçük düzeltmeler, tek dosya, "şu satırı değiştir" tarzı işler.
- **Daha güçlü model / Agent:** Büyük refactor, mimari karar, tüm projede localization taraması gibi çok adımlı görevler.

### Proje İçin Cursor Kuralları (`.cursor/rules` veya proje kökünde)
Projede tutarlılık için bir `PROJECT_RULES.md` veya `.cursorrules` dosyası ekleyebilirsiniz; Cursor bu dosyayı bağlamda kullanır. Örnek içerik:
- "Yeni metinler için AppLocalizations veya DynamicLocalizationHelper kullan; statik Türkçe/İngilizce string yazma."
- "Yeni ekran eklerken mevcut tema (ThemeConfig, AppThemes) kullan."
- "Eski _old / _new / _backup dosyalarına referans verme; hangi ekranın aktif olduğu PROJECT_STATUS.md’de yazılı."

Bu tür kurallar, Cursor’un önerilerini projenize daha uyumlu hale getirir.

---

## Bölüm 2: Proje Analiz Özeti

### Genel Durum
- **Proje:** Flutter (Dart), zikirmatik uygulaması, Google Play kapalı beta hedefli.
- **Versiyon:** 1.0.9+10.
- **Mimari:** Tekil servisler (SettingsService, CounterLogic, Supabase, WidgetService vb.), ekranlar doğrudan bu servisleri kullanıyor. IMPROVEMENT_PLAN.md’de belirtilen dependency injection ve test altyapısı henüz yok.

### Tespit Edilen Başlıca Sorunlar

#### 1. Dil / Yerelleştirme (Localization)
- **İki sistem bir arada:** Hem `AppLocalizations(languageCode)` (localizations.dart) hem `DynamicLocalizationHelper` (dynamic_localization_helper.dart) kullanılıyor. Bazı ekranlar sadece biriyle besleniyor.
- **MaterialApp’te `locale` yok:** `main.dart` içinde `MaterialApp`’e `locale: Locale(_currentLanguage)` verilmediği için Flutter’ın kendi yerelleştirme mekanizması dil değişiminde tetiklenmiyor. Dil değişince tüm ağaç yenilense bile, bazı widget’lar ilk dilde kalabilir.
- **Statik metinler:** Birçok ekranda hâlâ doğrudan Türkçe/İngilizce string var (örn. settings_screen, profile_screen, statistics_screen_new, kupa_screen_new, about_screen, support_screen_new, import_export_screen). Dil değişince bu metinler güncellenmiyor.

#### 2. Eski / Yinelenen Dosyalar
Aşağıdaki dosyalar ya kullanılmıyor ya da "yeni" sürümle çakışıyor; temizlik planına alınmalı:

| Dosya | Durum / Not |
|-------|----------------|
| `lib/screens/settings_screen_old.dart` | Eski ayar ekranı; aktif `SettingsScreen` `lib/screens/settings_screen.dart`. |
| `lib/screens/kupa_screen.dart` | Kullanılan: `KupaScreenNew` (home_page → KupaScreenNew). Eski KupaScreen referansları var mı kontrol edilmeli, yoksa kaldırılabilir. |
| `lib/screens/about_screen_new.dart` | settings_dialog_new’den `AboutScreenNew` açılıyor; settings_screen’den ise `AboutScreen` (about_screen.dart). Hangisi resmî karar verilmeli, biri kaldırılmalı. |
| `lib/screens/support_screen.dart` | Aktif kullanım: `SupportScreenNew`. Eski support_screen kaldırılabilir. |
| `lib/utils/localizations_broken.dart` | Kırık/eski localization; hiç import edilmemeli, silinmeli. |
| `lib/screens/home_page_backup.dart` | Yedek; gerek yoksa silinebilir. |
| `lib/utils/dialog_manager.dart` vs `lib/widgets/dialog_manager.dart` | İki farklı dialog_manager var; hangisinin kullanıldığı netleştirilip biri kaldırılmalı. |

#### 3. Mimari / Kalite (IMPROVEMENT_PLAN ile uyumlu)
- WidgetService, CounterLogic, Supabase çakışmaları ve error handling tutarsızlığı plan dokümanında vurgulanmış; öncelik sırasına göre ele alınabilir.
- Test altyapısı yok; plana göre Phase 1’de kritik servisler için unit test hedeflenebilir.

---

## Bölüm 3: Öncelik Sırası ve Aksiyonlar

Sizin önerdiğiniz sıra mantıklı: **Önce projeyi anlamak ve verimli ortamı kurmak → Sonra sorunları gidermek → Sonra geliştirmeye devam.** Aşağıdaki sıra bunu somutlaştırıyor.

### Aşama 1: Ortam ve Proje Netliği (1–2 gün)
1. **Proje durumu dokümanı:** `PROJECT_STATUS.md` oluşturun (aşağıda şablon var). Hangi ekranın “resmî” olduğu, hangi dosyaların silineceği burada yazılsın.
2. **Cursor kural dosyası:** `.cursorrules` veya `PROJECT_RULES.md` ile dil/tema/dosya kullanım kurallarını sabitleyin.
3. **Tek bir “todo” kaynağı seçin:** Notion, `.md` dosyası veya Cursor todo; hepsini kullanmayın, tek kaynak olsun.

### Aşama 2: Dil Sorunlarının Azaltılması (Öncelikli)
1. **MaterialApp’e `locale` ekleyin** (yapıldığında tüm ağaç doğru dilde yenilenir).
2. **Statik metinleri tespit edin:** Cursor’da "lib içinde şu ekranlarda statik Türkçe/İngilizce string’leri listele" deyip bir liste çıkarın (settings, profile, statistics, kupa, about, support, import_export).
3. **Tek bir strateji seçin:** Ya sadece `AppLocalizations` ya sadece `DynamicLocalizationHelper` (veya biri ana, diğeri sadece belirli yerler). Uzun vadede tek sisteme geçmek bakımı kolaylaştırır.
4. **Ekran ekran:** Önce en çok kullanılan ekranlardaki statik metinleri localization key’e taşıyın; dil değişince bu sayfaların güncellendiğini test edin.

### Aşama 3: Eski Dosyaların Temizliği
1. `PROJECT_STATUS.md`’deki tabloya göre hangi dosyanın silineceğini netleştirin.
2. Silmeden önce: projede o dosyaya/dosyalara referans var mı diye Cursor veya IDE ile arama yapın (örn. `KupaScreen` eski sürüm nerede kullanılıyor?).
3. Referans kaldırıldıktan sonra eski dosyaları silin; bir commit’te "Remove obsolete screens/utils" yapın.

### Aşama 4: İlerleme ve Özellik Yönetimi
- **Yeni özellik / büyük değişiklik:** Önce `PROJECT_STATUS.md` veya seçtiğiniz todo listesine madde ekleyin, sonra koda geçin.
- **Bug:** Aynı listeye “Bug: …” diye ekleyin; çözünce işaretleyin.
- **Google Play kapalı beta:** Store listing, gizlilik politikası, izin metinleri de “proje dokümanı” içinde tutulabilir (örn. `RELEASE_CHECKLIST.md`).

---

## Bölüm 4: Proje Yönetimi – Tek Kaynak Önerisi

Notion, .md veya Cursor todo’dan **birini** ana kaynak yapmanız yeterli.

### Seçenek A: Repo içi .md (Notion kullanmıyorsanız)
- **PROJECT_STATUS.md:** Hangi ekran/servis aktif, hangi dosyalar silinecek, kısa mimari not.
- **TODO.md veya ROADMAP.md:** Yapılacaklar, kısa vadeli hedefler, bug listesi. Cursor’a "@TODO.md" diyerek bu listeyi referans verebilirsiniz.

### Seçenek B: Notion
- Bir “Zikirmatik – Dev” sayfası: Bug listesi, özellik listesi, release checklist.
- Cursor’da “Notion’daki bug listesine göre çalış” demek isterseniz MCP ile entegre edebilirsiniz; şart değil.

### Seçenek C: Cursor Todo
- Küçük, günlük işler için Cursor’daki todo’yu kullanın; büyük roadmap’i yine PROJECT_STATUS.md veya Notion’da tutun.

Öneri: **PROJECT_STATUS.md + TODO.md** repo kökünde olsun; Cursor her zaman bu dosyaları görebilir ve "@TODO.md" ile “bu maddeleri yap” diye yönlendirebilirsiniz.

---

## Bölüm 5: Hızlı Kazanım – MaterialApp locale

Dil değişince tüm uygulamanın doğru dilde yenilenmesi için `main.dart` içinde:

```dart
return MaterialApp(
  locale: Locale(_currentLanguage),
  // ... diğer parametreler
);
```

eklenmesi gerekir. Bu değişiklik yapıldığında, dil değiştiğinde widget ağacı bu locale ile yeniden build edilir; `AppLocalizations(_currentLanguage)` kullanan yerler doğru dili alır. Statik yazılar hâlâ elle localization’a taşınmalıdır ama en azından “dil değişti ama sayfa değişmedi” hissi birçok yerde azalır.

---

## Özet

| Öncelik | Ne yapılacak |
|--------|----------------|
| 1 | PROJECT_STATUS.md ve (isteğe bağlı) PROJECT_RULES.md / .cursorrules ekleyin; tek bir todo kaynağı seçin. |
| 2 | MaterialApp’e `locale: Locale(_currentLanguage)` ekleyin. |
| 3 | Statik metinleri tespit edip localization’a taşıyın; tek bir localization stratejisine geçin. |
| 4 | Eski/yinelenen dosyaları PROJECT_STATUS.md’ye göre temizleyin. |
| 5 | IMPROVEMENT_PLAN’daki Phase 1 (stabilizasyon, test altyapısı) ile devam edin. |

İsterseniz bir sonraki adımda birlikte `PROJECT_STATUS.md` şablonunu doldurup, hangi ekranın resmî kalacağını netleştirebiliriz; ardından dil düzeltmeleri ve dosya temizliği için adım adım ilerleyebiliriz.
