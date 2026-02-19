# Mobil Uygulama Fikirleri ve Planlama

Bu dosya, geliştirmeyi düşündüğümüz mobil uygulama fikirlerini, özelliklerini ve durumlarını takip etmek için kullanılacaktır.

---

## Fikir 1: Zikirmatik

*   **Açıklama:** Sade, kullanımı kolay ve erişilebilirlik odaklı bir dijital tesbih (zikirmatik) uygulaması. Temel amaç, zikir saymayı kolaylaştırmak ve sayıyı kaydetmektir. Bununla birlikte kullanıcılar saymak içinde bu uygulamayı kullanabilirler.
*   **Hedef Kitle:** Günlük ibadetlerini veya kişisel zikirlerini saymak isteyen her yaştan kullanıcı. 
*   **Durum:** v1.0.0 Release Hazır - Store Submission Bekliyor
*   **Teknoloji:** Flutter
*   **Repository:** https://github.com/mcanererdem/zikirmatik.git

### Tamamlanan MVP Özellikleri ✅
- [x] Tıklanınca sayıyı artıran ana sayaç butonu
- [x] Sayıyı sıfırlama butonu
- [x] Uygulama kapansa bile son sayıyı hafızada tutma (SharedPreferences)
- [x] Her tıklamada isteğe bağlı titreşim geri bildirimi
- [x] Basit ve dikkat dağıtmayan bir arayüz (Material Design 3)
- [x] Çoklu dil desteği altyapısı (İngilizce, Türkçe, Arapça, Endonezce)
- [x] Belirlenen sayıya ulaşıldığında titreşim geri bildirimi
- [x] Hızlı hedef seçenekleri (33, 99, 100, 500, 1000)
- [x] Özel hedef girişi (max 999999)
- [x] Geri bildirim ayarları (titreşim, ses, konfeti toggle)
- [x] Ayarlar menüsü (tema, dil seçimi)
- [x] Uygulama rotasyonunda veri korunması
- [x] Tema değiştikçe veri korunması
- [x] Özel zikir ekleme (custom zikir - sadece Arapça alan)
- [x] Zikir seçimi ve yönetimi
- [x] Çoklu tema desteği (Blue/Gold, Dark, Mint vb)
- [x] App launcher ikonu (flutter_launcher_icons)
- [x] Splash screen (native platform-specific)
- [x] AdMob entegrasyonu (test ads aktif, banner reklam)
- [x] Input validasyonları (rakamlar, max 6 hane)
- [x] Ses efekti (click sound, audioplayers)
- [x] Lokasyon bazlı otomatik dil seçimi (ilk açılış İngilizce, sonra lokasyona göre)
- [x] Accessibility iyileştirmeleri (Semantics labels)
- [x] İstatistik paneli (günlük, toplam, son 7 gün grafiği)
- [x] Hatırlatıcılar (zamanlanmış bildirimler)
- [x] İlk açılışta tüm özellikler kapalı (vibration, sound, confetti OFF)
- [x] Dark mode desteği (sistem teması uyumu)
- [x] Home screen widget (Android)
- [x] Günlük/Haftalık/Aylık hedef sistemi (zikr bazlı)
- [x] Streak (ardışık gün) takibi

### Store Submission Aşaması (v1.0.0) 🚀
- [x] Release build signing config (gradle) hazırlanması
- [x] Privacy Policy yazılması
- [x] Google Play Store listing dokümantasyonu hazırlanması
- [x] Release build guide yazılması (keystore, AAB, upload adımları)
- [x] RELEASE_BUILD_GUIDE.md dokümantasyonu tamamlandı
- [x] STORE_LISTING.md store bilgisi tamamlandı
- [x] PRIVACY_POLICY.md politikası tamamlandı
- [x] Vibration paketi güncellendi (v3.1.6 - Android v1 embedding uyumlu)
- [ ] **Keystore (.jks) oluşturulması** (user action required)
- [ ] **Release APK/AAB build kontrol edilmesi** (test device)
- [ ] **Screenshots hazırlanması** (8 ekran görüntüsü)
- [ ] **Feature graphic hazırlanması** (1024x500px)
- [ ] **Google Play Console hesabı oluşturulması**
- [ ] **Store listing bilgisi doldurulması**
- [ ] **Content rating (IARC) formunun doldurulması**
- [ ] **App store'a gönderilmesi ve review beklenmesi**

### v1.0.0 Tamamlanan Özellikler ✅

#### Temel Özellikler
- [x] Tıklanınca sayıyı artıran ana sayaç butonu
- [x] Sayıyı sıfırlama butonu
- [x] Uygulama kapansa bile son sayıyı hafızada tutma (SharedPreferences)
- [x] Her tıklamada isteğe bağlı titreşim geri bildirimi
- [x] Basit ve dikkat dağıtmayan bir arayüz (Material Design 3)
- [x] Belirlenen sayıya ulaşıldığında titreşim geri bildirimi
- [x] Hızlı hedef seçenekleri (33, 99, 100, 500, 1000)
- [x] Özel hedef girişi (max 999999)
- [x] Geri bildirim ayarları (titreşim, ses, konfeti toggle)
- [x] Ayarlar menüsü (tema, dil seçimi)
- [x] Uygulama rotasyonunda veri korunması
- [x] Tema değiştikçe veri korunması
- [x] Input validasyonları (rakamlar, max 6 hane)
- [x] Ses efekti (click sound, audioplayers)
- [x] İlk açılışta tüm özellikler kapalı (vibration, sound, confetti OFF)

#### Çoklu Dil ve Tema
- [x] Çoklu dil desteği altyapısı (İngilizce, Türkçe, Arapça, Endonezce)
- [x] Lokasyon bazlı otomatik dil seçimi (ilk açılış İngilizce, sonra lokasyona göre)
- [x] Çok Dilli Destek: 15 dil eklendi (Urduca, Bengalce, Malayca, Farsça, Fransızca, Çince, Japonca, Rusça, Almanca, Svahili, Hausa)
- [x] Çoklu tema desteği (Blue/Gold, Dark, Mint vb)
- [x] Dark mode desteği (sistem teması uyumu)
- [x] Responsive AppBar (Arapça gibi uzun başlıklarda taşma sorunu çözüldü)

#### Zikir Yönetimi
- [x] Özel zikir ekleme (custom zikir - sadece Arapça alan)
- [x] Zikir seçimi ve yönetimi
- [x] Zikir Ekleme İyileştirmesi: Çok dilli isim alanları, 0 validasyonu

#### Hedef ve İstatistikler
- [x] Günlük/Haftalık/Aylık hedef sistemi (zikr bazlı)
- [x] Streak (ardışık gün) takibi
- [x] Goal Sistemi Düzeltmesi: Her goal 0'dan başlıyor
- [x] Goal-Based Streak İyileştirmesi: Aynı gün birden fazla hedef tamamlama, streak mesajları, new best bildirimleri
- [x] İstatistik paneli (günlük, toplam, son 7 gün grafiği)
- [x] İstatistik Sayfası Yenilendi: Trophy sistemi, renkli kartlar

#### Widget ve Bildirimler
- [x] Home screen widget (Android)
- [x] Widget↔App Senkronizasyonu: Widget tıklamaları app'e yansıyor
- [x] İstatistik Widget'ı: Ana ekranda bugün/streak/toplam gösterimi
- [x] Hatırlatıcılar (zamanlanmış bildirimler)

#### Diğer
- [x] App launcher ikonu (flutter_launcher_icons)
- [x] Splash screen (native platform-specific)
- [x] AdMob entegrasyonu (test ads aktif, banner reklam)
- [x] Accessibility iyileştirmeleri (Semantics labels)
- [x] Hakkında Sayfası/Dialog: Uygulama sürümü, gizlilik politikası ve kaynak kodu bağlantıları
- [x] Code Refactoring: home_page 900→650 satır, 3 yeni servis (counter_logic, audio_manager, feedback_manager)
- [x] Vibration paketi güncellendi (v3.1.6 - Android v1 embedding uyumlu)

### Ertelenen Özellikler ⏸️
- [ ] **Sesli Zikir (TTS):** Text-to-speech ile zikir metinlerinin sesli okunması
  - **Neden Ertelendi:** flutter_tts paketi Kotlin 2.1.0+ gerektiriyor, proje Kotlin 1.9.10 kullanıyor
  - **Çözüm:** Kotlin versiyonu güncellendiğinde tekrar denenecek

---

## Gelecek Özellik Önerileri (v1.1.0+)

### v1.1.0 Devam Eden Özellikler 🚧
- [ ] **Yedekleme/Dışa Aktarma:** CSV/JSON export özelliği (eklendi, test edilecek)

### Yüksek Öncelik (v1.1.0)
1. **Sayaç Geçmişi:** Önceki oturumların kaydı ve görüntüleme

### Orta Öncelik (v1.2.0)
1. **Çoklu Sayaç:** Aynı anda birden fazla zikir takibi
2. **Başarı Rozetleri:** Gamification elementleri (milestone badges)
3. **Tema Özelleştirme:** Daha fazla renk seçeneği, özel temalar
4. **Gelişmiş Bildirimler:** Hedef hatırlatıcıları, motivasyon mesajları

### Düşük Öncelik (v2.0.0)
1. **Cloud Backup:** Google Drive/iCloud entegrasyonu
2. **Sosyal Özellikler:** Arkadaşlarla zikir paylaşımı
3. **Özel Animasyonlar:** Daha zengin görsel efektler
4. **iOS Desteği:** App Store yayını
5. **Sesli Zikir (TTS):** Kotlin güncellemesi sonrası