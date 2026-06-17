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