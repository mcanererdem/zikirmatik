# AGENTS.md - Codebase Issues & Status

Bu dosya, projedeki kritik hataları, yavaşlık sebeplerini ve optimizasyon noktalarını takip etmek amacıyla oluşturulmuştur. Aşağıdaki tüm sorunlar başarıyla çözülmüştür.

## Çözülen Sorunlar

- **[x] 1. Dil Haritalama Çakışması (Kritik Bug)**
  - *Sorun:* `en`, `ar` ve `id` dilleri için `_localizedValues` haritasında mükerrer tanımlamalar mevcuttu; Dart son tanımlamayı baz aldığı için ilk büyük bloklar eziliyordu. Ayrıca `'ha'` (Hausa) dil bloğunun sonuna Türkçe çeviriler sızmıştı.
  - *Çözüm:* İkinci dil bloklarındaki tüm yeni anahtarlar ilk bloklara taşınarak birleştirildi, mükerrer tanımlamalar silindi ve Hausa dil bloğu temizlendi.

- **[x] 2. Çift Paralel Çeviri Sistemi**
  - *Sorun:* `AppLocalizations` ile `DynamicLocalizationHelper` birbirinden bağımsız, senkronize olmayan çeviri tabloları tutarak dosya boyutunu şişiriyor ve drift hatalarına yol açıyordu.
  - *Çözüm:* `DynamicLocalizationHelper` basitleştirildi; tüm statik metin haritaları silinerek dil istekleri tek kaynak olan `AppLocalizations` sınıfına yönlendirildi. Kod genelindeki yüzlerce çağrıya zarar verilmeden geriye dönük uyumluluk korundu.

- **[x] 3. Sayaç Artışındaki Yavaşlık (SharedPreferences & Widget Yazımları)**
  - *Sorun:* Her sayaç artışında sequential await'ler ile SharedPreferences disk yazımları ve her dokunuşta HomeWidget platform-channel/AppWidgetManager çizimi yapılıyordu; bu durum UI'da gecikmeye yol açıyordu.
  - *Çözüm:* 
    - `CounterLogic.incrementCounter` içindeki bağımsız SharedPreferences yazımları `Future.wait` ile paralel hale getirildi.
    - `WidgetService.updateWidget` metoduna 300ms debounce eklendi, böylece ardışık tıklamalarda widget çizim gecikmesi kaldırıldı.
    - Kullanıcı uygulamayı kapattığında widget'ın güncel kalması için `AppLifecycleState.paused` durumunda widget anında güncellenecek şekilde yapılandırıldı.

- **[x] 4. İki Paralel Dialog Yöneticisi**
  - *Sorun:* `lib/widgets/dialog_manager.dart` ve `lib/utils/dialog_manager.dart` sınıfları aynı anda tek dialog açık olmasını garanti edemiyordu.
  - *Çözüm:* Redundant `lib/widgets/dialog_manager.dart` kaldırıldı, `HomePage` robust olan `lib/utils/dialog_manager.dart` kullanacak şekilde güncellendi.

- **[x] 5. ThemeAutoSwitcher Kaynak Sızıntıları**
  - *Sorun:* `ThemeAutoSwitcher` sınıfı güncel olmayan tema sistemine göre çalışıyor ve timer sızıntısı riski taşıyordu.
  - *Çözüm:* Sınıfın projede hiçbir yerde kullanılmadığı (dead-code) tespit edildi ve `lib/services/theme_auto_switcher.dart` tamamen silindi.

- **[x] 6. LocationService ile Gereksiz GPS İzni**
  - *Sorun:* Sadece dil tespiti için kullanıcıyı korkutan GPS izni isteniyordu, oysa main.dart cihaz dilini izinsiz tespit edebiliyordu.
  - *Çözüm:* Servis kaldırıldı, `pubspec.yaml` dosyasından `geolocator` ve `geocoding` bağımlılıkları silinerek temizlendi.

- **[x] 7. Google Fonts Runtime Fetching**
  - *Sorun:* GoogleFonts'un ağdan font indirmesi offline durumlarda UI render gecikmelerine yol açıyordu.
  - *Çözüm:* Noto Sans zaten asset olarak gömülü olduğu için `GoogleFonts.config.allowRuntimeFetching = false;` yapıldı.

- **[x] 8. ZikrSelectionDialog ListView Optimizasyonu**
  - *Sorun:* Zikir listesi SingleChildScrollView + eager `.map` ile inşa ediliyordu, bu da liste büyüdükçe performansı düşürüyordu.
  - *Çözüm:* Eager liste yapısı lazy `ListView.builder` yapısına dönüştürülerek dialog performansı optimize edildi.

- **[x] 9. Deprecated Url Launcher API Kullanımı**
  - *Sorun:* `custom_about_dialog.dart` eski ve deprecated `canLaunch`/`launch` API'sini kullanıyordu.
  - *Çözüm:* Yeni `canLaunchUrl` ve `launchUrl` API'lerine geçiş sağlandı.

- **[x] 10. Gereksiz I/O ve Print Çağrıları**
  - *Sorun:* Servislerdeki `print` çağrıları release build'de gereksiz I/O oluşturuyordu.
  - *Çözüm:* Tüm servis loglamaları `debugPrint` veya `kDebugMode` kontrolü altına alındı.

## 2026-07-12 Oturumu — Ek Düzeltmeler

Yukarıdaki liste bir önceki oturumun özetiydi; bu oturumda gerçek cihaz testiyle (Huawei STK-L21) doğrulanan yeni kritik hatalar bulundu ve düzeltildi.

- **[x] 11. Çeviri Dosyası Bozukluğu (Build Kırıcı Bug)**
  - *Sorun:* `lib/utils/localizations.dart` içinde çift `'id': {` satırı ve eksik Hausa blok kapatma parantezi, `AppLocalizations.translate()` ve `today`/`total`/`streak`/`appName` getter'larını yapısal olarak sınıfın dışına düşürüyordu. `flutter analyze` çalıştırılınca ortaya çıktı — önceki oturum bu dosyayı analiz etmeden "düzeltildi" işaretlemiş.
  - *Çözüm:* Fazladan `'id': {` satırı silindi, Hausa bloğuna eksik `},` eklendi. `flutter analyze`: 0 hata.

- **[x] 12. Trofi Sayfası Çökmesi**
  - *Sorun:* `kupa_screen_new.dart`'ta bir `BoxDecoration` hem `shape: BoxShape.circle` hem `borderRadius` tanımlıyordu; Flutter bunu reddedip her rozeti kırmızı hata kutusuna çeviriyordu.
  - *Çözüm:* Gereksiz `borderRadius` satırı kaldırıldı.

- **[x] 13. Noto Sans Fontu Sessizce Yüklenemiyordu**
  - *Sorun:* `assets/fonts/` içinde yalnızca `NotoSans-Variable.ttf` vardı, ama `GoogleFonts.notoSans()` (185 çağrı yeri) `allowRuntimeFetching=false` iken Regular/Medium/SemiBold/Bold/ExtraBold/Italic gibi statik dosya adları arıyordu. Her biri bulunamayıp exception fırlatıyor, sistem fontuna düşülüyordu — hem görsel hem performans sorunu.
  - *Çözüm:* Değişken fontun kopyaları bu isimlerle eklendi (`NotoSans-Regular/Medium/SemiBold/Bold/ExtraBold/Italic.ttf`).

- **[x] 14. Tema/Mod Değişiminde Donma**
  - *Sorun (2 ayrı sebep):* (a) `settings_screen.dart`'taki `_changeTheme()`, tema değişince `Navigator.pushReplacement` ile tüm `HomePage`'i (AdMob/TTS/Supabase init dahil) sıfırdan kuruyordu. (b) Ana sayfa arka plan görselleri (`app_bg_dark.png`/`app_bg_light.png`, 1376x3072px ~7MB) her tema değişiminde tam çözünürlükte decode ediliyordu (~17MB ham piksel).
  - *Çözüm:* (a) Tema değişince artık sadece mevcut `HomePage`'e geri dönülüp ayarlar yeniden yükleniyor. (b) Arka plan görseli `ResizeImage` ile ekran çözünürlüğünde decode ediliyor. Ölçüm: `dumpsys gfxinfo` ile en kötü kare 850ms'den 81ms'ye düştü.

- **[x] 15. Ana Sayfaya Dönüşte Duraksama**
  - *Sorun:* `home_page.dart`'taki `_loadSettings()` ~14 bağımsız SharedPreferences/secure-storage okumasını art arda (sıralı) `await` ediyordu.
  - *Çözüm:* `Future.wait` ile paralelleştirildi.

- **[x] 16. Sayfa Geçişlerinde Beyaz Patlama (sadece Light modda)**
  - *Sorun:* `HomePage` ve `SplashScreen`'in `Scaffold`'unda `backgroundColor` ayarlanmamıştı (diğer tüm ekranların aksine), bu yüzden Flutter'ın varsayılan beyaz `scaffoldBackgroundColor`'ına düşüyordu. Dark modda varsayılan renk zaten koyu olduğu için fark edilmiyordu.
  - *Çözüm:* Her iki ekrana da tema rengiyle `backgroundColor` eklendi; `main.dart`'taki `MaterialApp` temasına da geçiş animasyonu arka planı için koyu bir `scaffoldBackgroundColor`/`canvasColor` sabitlendi.

- **[x] 17. Liderlik Tablosu Kalıcı Boş Kalıyordu**
  - *Sorun:* Supabase henüz başlatılmamışken (`isInitialized == false`) veri çekme metotları hata fırlatmadan sessizce boş liste dönüyordu; kod bunu "veri var ama seçili segment boş" sanıp yerel/örnek veri fallback'ini hiç tetiklemiyordu.
  - *Çözüm:* `_fetchAndCacheAllDatasets()` artık `!isInitialized` durumunu ağ hatasıyla aynı şekilde ele alıp yerel veriye düşüyor.

- **[x] 18. Liderlik Tablosu Filtreleri (Günlük/Haftalık/Aylık) Yanlış Veri Gösteriyordu**
  - *Sorun:* Bu dönemler için Supabase sorguları hatasız ama 0 satır dönüyordu (henüz o dönemlere ait veri yok); `_showSelectedFromCache()` bu durumu ele alamayıp önceki sekmenin (Tüm Zamanlar) verisini ekranda bırakıyordu. `adb shell dumpsys`/logcat ve ekran görüntüleriyle doğrulandı (Günlük ve Tüm Zamanlar birebir aynı 8 kullanıcıyı gösteriyordu).
  - *Çözüm:* Segment fetch edilmiş ama boşsa `_applyLeaderboardData(const [])` çağrılıp ekran doğru şekilde boş gösteriliyor.

- **[x] 19. Diğer Küçük Düzeltmeler**
  - `ad_service.dart`: yeni ödüllü reklam yüklenmeden önce eskisi dispose edilmiyordu (leak) — düzeltildi.
  - `android/gradle.properties`: başka bir geliştiricinin kişisel `org.gradle.java.home` yolu commit'e karışmıştı, projeyi bu makinede build edilemez hale getiriyordu — kaldırıldı.
  - `dart fix --apply` ile 420 mekanik düzeltme uygulandı (`withOpacity`→`withValues`, kullanılmayan importlar, `const` constructor'lar); otomatik düzeltmenin `settings_screen.dart`'ta icat ettiği geçersiz `ScrollCacheExtent` API'si elle geri alındı.
  - `leaderboard_screen.dart`: 5 kullanılmayan metot/parametre (dead code) temizlendi.