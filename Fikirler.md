# Mobil Uygulama Fikirleri ve Planlama

Bu dosya, geliştirmeyi düşündüğümüz mobil uygulama fikirlerini, özelliklerini ve durumlarını takip etmek için kullanılacaktır.

---

## Fikir 1: Zikirmatik

*   **Açıklama:** Sade, kullanımı kolay ve erişilebilirlik odaklı bir dijital tesbih (zikirmatik) uygulaması. Temel amaç, zikir saymayı kolaylaştırmak ve sayıyı kaydetmektir. Bununla birlikte kullanıcılar saymak içinde bu uygulamayı kullanabilirler.
*   **Hedef Kitle:** Günlük ibadetlerini veya kişisel zikirlerini saymak isteyen her yaştan kullanıcı. 
*   **Durum:** v1.0.0 Release Hazır - Store Submission Bekliyor
*   **Teknoloji:** Flutter
*   **Repository:** https://github.com/mcanererdem/zikirmatik.git

### Tamamlanan Özellikler ✅
**Çekirdek**
- [x] Sayaç artırma/sıfırlama, veri koruma (rotation/tema)
- [x] Hedef: hızlı seçenekler + özel giriş (max 999999)
- [x] Geri bildirim: titreşim, ses, konfeti
- [x] İstatistik: bugün/toplam/son 7 gün grafiği, trophy
- [x] İstatistik: Son 4 hafta ve Son 12 ay grafikleri eklendi
- [x] İstatistik: Bar/Çizgi grafik türü seçici eklendi (tüm dönemler)
- [x] İstatistik: Ay etiketleri yerelleştirildi (TR/EN/AR)
- [x] Streak (ardışık gün) takibi
- [x] Hatırlatıcılar (günlük bildirim)

**Arayüz ve Tema**
- [x] Material 3 sade arayüz, çoklu tema
- [x] Açık/koyu mod uyumu
- [x] Gradient ve arka plan görsel desteği (ekranlar/diyaloglar)
- [x] Launcher ikon + Splash screen

**Dil ve Erişilebilirlik**
- [x] Çoklu dil (15 dil), cihaz diline göre varsayılan
- [x] Semantics etiketleri, büyük metin uyumu (devamını artıracağız)

**Widget ve Reklam**
- [x] Android widget + app senkronu
- [x] AdMob entegrasyonu (test ads)
 
**Bağımlılıklar**
- [x] fl_chart sürümü ^0.66.2’ye güncellendi

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

### v1.0.0 Notları
- [x] Responsive başlıklar (uzun metinlerde taşma çözüldü)
- [x] Code refactoring (home_page sadeleştirme, servislere ayrışma)

### Ertelenen Özellikler ⏸️
- [ ] **Sesli Zikir (TTS):** Text-to-speech ile zikir metinlerinin sesli okunması
  - **Neden Ertelendi:** flutter_tts paketi Kotlin 2.1.0+ gerektiriyor, proje Kotlin 1.9.10 kullanıyor
  - **Çözüm:** Kotlin versiyonu güncellendiğinde tekrar denenecek
---

## Gelecek Özellik Önerileri (v1.1.0+)

### v1.1.0 Devam Eden Özellikler 🚧
- [x] **Yedekleme/Dışa Aktarma:** JSON export/import entegre edildi (Settings → Export/Import)

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

---

## Sonraki Adımlar (v1.1.0 Odak)
- [ ] Blur efektlerini yaygınlaştırma: Maşallah/Teşekkür diyalogları ve İstatistik kartları
- [ ] Hatırlatıcı güvenilirliği: Exact izin kontrolü, inexact fallback, cihaz özel yönergeler
- [ ] Erişilebilirlik iyileştirmeleri: Kontrast, Semantics, büyük dokunma hedefleri, metin ölçeklenmesi
- [ ] İstatistik UI rafinmanı: Kart hiyerarşisi, tipografi, renk uyumu

## Erişilebilirlik Kontrol Listesi
- [ ] Minimum dokunma hedefi 48x48
- [ ] Semantics label’lar: butonlar, ikonlar, grafikte çubuk değerleri
- [ ] Dinamik metin ölçekleme (MediaQuery.textScaleFactor) uyumu
- [ ] Kontrast oranı: açık temalarda metin rengi uyumu
- [ ] Odak sırası: klavye/okuma sırası mantıklı

## Temizlik ve Birleştirme Notları
- MVP ve v1.0.0 listelerindeki tekrar eden maddeler tek bir “Tamamlanan” listesinde tutulacaktır
- Yinelenen girdiler (Accessibility, AdMob, Splash, Launcher ikon) bir kez geçilecek
- Gelişmiş istatistik ve trophy başlıkları tek bir “İstatistikler” başlığı altında toplanacaktır
