# Google Play Store Console Ayarları Rehberi

## 📱 Google Play Console Konfigürasyonu

Bu rehber, Zikirmatik uygulamasının Google Play Store'da yayınlanması için gerekli tüm konsol ayarlarını içerir.

---

## 🏪 Store Giriş

### Console Erişim
1. [Google Play Console](https://play.google.com/console) giriş yapın
2. **Zikirmatik** uygulamasını seçin
3. Sol menüden gerekli ayarlara gidin

---

## 📋 Uygulama Bilgileri (App Content)

### Temel Bilgiler
```
Uygulama Adı: Tasbih Counter - Digital Tasbih
Paket Adı: com.mcanererdem.zikirmatik
Kategori: Lifestyle
İçerik Derecelendirmesi: Everyone
Fiyat: Ücretsiz (reklam destekli)
```

### Açıklamalar
- **Kısa Açıklama:** Digital tasbih app - Counter, goals, widget, 15 languages
- **Tam Açıklama:** STORE_LISTING.md'deki metinleri kullan
- **Güncelleme Notları:** Yeni sürümler için değişiklik listesi

---

## 👥 Kullanıcı Bilgileri ve Gizlilik

### 📊 Veri Toplama (Data Safety)

#### **Veri Toplama Türleri**
```
✅ Kişisel Bilgiler: HAYIR
✅ Finansal Bilgiler: HAYIR  
✅ Konum Bilgileri: HAYIR
✅ İletişim Bilgileri: HAYIR
✅ Hassas İçerik: HAYIR
✅ Kullanıcı Oluşturulan İçerik: HAYIR
```

#### **Toplanan Veri Türleri**
```
🔍 Cihaz veya diğer tanımlayıcılar:
- Reklam ID'si (AdMob tarafından toplanır)
- Uygulama etkileşim verileri
- Yaklaşık konum (cihaz ayarlarına bağlı)

📁 Dosyalar ve uygulama verileri:
- Yerel depolama (SharedPreferences)
- Kullanıcı tercihleri
- Zikir sayıları ve hedefler
- Özel zikir isimleri
```

#### **Veri Kullanım Amaçları**
```
🎯 Uygulama İşlevselliği:
- Sayacı çalıştırma
- Kullanıcı ayarlarını kaydetme
- Hedef takibi ve istatistikler
- Widget senkronizasyonu

📈 Analiz ve Geliştirme:
- Uygulama performansı analizi
- Çökme raporları
- Kullanım istatistikleri

🎪 Reklamlar:
- Google AdMob banner reklamları
- Ödüllü video reklamlar
- Hedeflenmiş reklam gösterimi
```

#### **Veri Paylaşımı**
```
🔒 Üçüncü Taraflarla Paylaşım:
- Google AdMob (reklam hizmetleri için)
- Google Analytics (performans için)

🚫 Diğer Paylaşım:
- Diğer şirketlerle paylaşım: YOK
- Satış veya transfer: YOK
- Kamuya açık paylaşım: YOK
```

#### **Veri Güvenliği**
```
🛡️ Güvenlik Önlemleri:
- Cihaz yerel depolaması
- Şifreli veri aktarımı (SSL/TLS)
- Google Play Console güvenlik standartları
- Supabase RLS (Row Level Security)

⏰ Veri Saklama Süresi:
- Kullanıcı cihazında kalıcı
- Uygulama kaldırıldığında silinir
- Sunucu yedeği: 30 gün
```

---

## 👶 İçerik Derecelendirmesi (Content Rating)

### **Yaş Grubu: 13+**

#### **İçerik Soruları**
```
🚫 Şiddet: HAYIR
🚫 Cinsel İçerik: HAYIR
🚀 Küfür: HAYIR
🚫 Kontrollü Maddeler: HAYIR
🎰 Kumar: HAYIR
👥 Kullanıcı Oluşturulan İçerik: HAYIR
💬 Kullanıcı İletişimi: HAYIR
📊 Kişisel Bilgi Toplama: EVET (sadece yerel depolama)
📍 Konum Paylaşımı: HAYIR
```

#### **Hedef Kitle**
```
🎯 Hedef Yaş: 13+
👨‍👩‍👧‍👦 Ana Hedef Kitle: Müslüman kullanıcılar
🌍 Coğrafi Hedef: Küresel (öncelikle Türkçe ve Arapça konuşan ülkeler)
```

---

## 🔒 Uygulama İzinleri (App Access)

### **Gerekli İzinler**
```
📱 İnternet Erişimi:
- Amaç: Reklam gösterimi ve cloud sync (isteğe bağlı)
- Zorunluluk: Hayır (çevrimdışı çalışır)

💾 Depolama Erişimi:
- Amaç: Veri dışa/içe aktarma
- Zorunluluk: Hayır (sadece kullanıcı isteğiyle)

🔔 Bildirimler:
- Amaç: Günlük hatırlatıcılar
- Zorunluluk: Hayır (kullanıcı kontrolünde)

📊 Vibration:
- Amaç: Haptic feedback
- Zorunluluk: Hayır (kapatılabilir)
```

### **Özel İzinler**
```
🚫 Kamera: GEREKMİYOR
🚫 Mikrofon: GEREKMİYOR
🚫 Konum: GEREKMİYOR
🚫 Kişiler: GEREKMİYOR
🚫 SMS: GEREKMİYOR
🚫 Telefon: GEREKMİYOR
```

---

## 📤 Yayın Ayarları (Release)

### **İzleme Kanalları (Tracks)**
```
🧪 Test Kanalı:
- İç Test: Geliştirici hesapları
- Kapalı Test: 20-100 kullanıcı
- Açık Test: Tüm kullanıcılar

🚀 Prodüksiyon Kanalı:
- Genel Yayın: Tüm dünya
- Onay Süreci: Google Play incelemesi
- Yayın Durumu: Aktif
```

### **Yayın Formatları**
```
📱 Android App Bundle (AAB):
- Format: .aab
- Boyut: ~25MB
- Google Play Signing: EVET
- Optimize Edilmiş: EVET

📲 APK (Alternatif):
- Format: .apk
- Boyut: ~30MB
- İmzalama: Kendi anahtarımızla
```

---

## 💰 Fiyatlandırma ve Dağıtım

### **Fiyatlandırma**
```
💵 Uygulama Fiyatı: ÜCRETSİZ
🎪 İç Satın Almalar: YOK
📦 Abonelikler: YOK
🎰 Kumar İçerik: YOK
```

### **Dağıtım**
```
🌍 Dağıtım: Küresel
🚫 Kısıtlı Ülkeler: YOK
📱 Desteklenen Cihazlar: Tüm Android cihazlar
🔧 Minimum Android Sürümü: 5.0 (API 21)
```

---

## 📊 Reklam Ayarları (Monetization)

### **AdMob Konfigürasyonu**
```
🎪 Reklam Türleri:
- Banner Reklamlar: EVET
- Ödüllü Reklamlar: EVET
- Aralık Reklamlar: HAYIR
- Yerel Reklamlar: HAYIR

📱 Reklam Birimleri:
- Banner ID: ca-app-pub-3940256099942544/6300978111 (Test)
- Rewarded ID: ca-app-pub-3940256099942544/5224355221 (Test)
- Production ID: Yayın için güncellenecek

👥 Hedef Kitle:
- Yaş: 13+
- İlgili Alanlar: Dini, Yaşam Tarzı, Eğitim
- Coğrafi: Küresel
```

### **Reklam Politikası**
```
📋 Google Play Politikaları:
- Uygun: EVET
- Aile Dostu: EVET
- Uygun İçerik: EVET

🔒 Gizlilik:
- Kişisel Bilgi: YOK
- Konum Verisi: YOK
- Hassas Veri: YOK
```

---

## 🛡️ Güvenlik ve Uyumluluk

### **Uygulama Güvenliği**
```
🔐 Güvenlik Önlemleri:
- Kod Obfuskasyon: EVET (ProGuard)
- SSL/TLS: EVET
- Veri Şifreleme: EVET (cihaz seviyesi)
- Güvenli Depolama: EVET

🚫 Güvenlik Riskleri:
- Root Detection: GEREKMİYOR
- Anti-Debug: GEREKMİYOR
- Cihaz Attestation: GEREKMİYOR
```

### **Uyumluluk**
```
✅ Google Play Politikaları:
- Uygun: EVET
- İnceleme Durumu: Beklemede
- Son Güncelleme: Bugün

📋 Yasal Uyumluluk:
- GDPR: Uyumlu
- COPPA: Uyumlu (13+)
- CCPA: Uyumlu
- KVKK: Uyumlu
```

---

## 📈 Performans ve Analiz

### **Vitals**
```
⚡ Performans:
- ANR Oranı: <0.1%
- Çökme Oranı: <0.1%
- Başlatma Süresi: <2 saniye

📊 Kullanıcı Analizi:
- Günlük Aktif Kullanıcı: Takip edilecek
- Elde Tutma Oranı: Takip edilecek
- Kullanıcı Memnuniyeti: Takip edilecek
```

### **Ölçümler**
```
📈 Google Analytics:
- Kullanıcı Etkileşimi: EVET
- Performans İzleme: EVET
- Çökme Raporları: EVET
- Gelir İzleme: EVET

🎯 Özel Etkinlikler:
- Zikir Sayımı: Takip edilecek
- Hedef Tamamlama: Takip edilecek
- Tema Değişimi: Takip edilecek
- Dil Değişimi: Takip edilecek
```

---

## 🎨 Grafik Varlıkları

### **Görseller**
```
📱 Uygulama İkonu:
- Boyut: 512x512 px
- Format: PNG (32-bit)
- Şeffaflık: YOK
- Tasarım: Tesbih teması

🖼️ Özellik Grafiği:
- Boyut: 1024x500 px
- Format: PNG veya JPEG
- Kullanım: Store listing

📸 Ekran Görüntüleri:
- Minimum: 2 adet
- Önerilen: 4-8 adet
- Format: PNG veya JPEG
- En-boy: 16:9 veya 9:16
```

### **Promosyon**
```
🎥 Promosyon Videosu (İsteğe Bağlı):
- Süre: 30 saniye - 2 dakika
- Platform: YouTube
- Format: MP4
- Kalite: HD (1080p)
```

---

## 📞 İletişim Bilgileri

### **Geliştirici Bilgileri**
```
👤 Geliştirici Adı: Caner Erdem
📧 E-posta: mcanererdem@gmail.com
🌐 Web Sitesi: https://github.com/mcanererdem/zikirmatik
📱 Telefon: GEREKMİYOR
🏢 Adres: GEREKMİYOR
```

### **Destek**
```
💬 Kullanıcı Desteği:
- E-posta: mcanererdem@gmail.com
- Web Sitesi: GitHub Issues
- Yanıt Süresi: 24 saat içinde

📋 Gizlilik Politikası:
- URL: https://mcanererdem.github.io/zikirmatik/privacy_policy.html
- Son Güncelleme: 13 Şubat 2026
- Uygunluk: GDPR, COPPA, CCPA
```

---

## 🔄 Yayın Süreci

### **Yayın Öncesi Kontrol Listesi**
```
✅ Uygulama Bilgileri: Tamamlandı
✅ İçerik Derecelendirmesi: 13+
✅ Veri Güvenliği: Yapılandırıldı
✅ Reklam Ayarları: Test modunda
✅ Grafik Varlıkları: Yüklendi
✅ İletişim Bilgileri: Güncel
✅ Gizlilik Politikası: Aktif
✅ Yayın Kanalı: Seçildi
✅ İmzalama: Google Play Signing
```

### **Yayın Sonrası**
```
📊 İzleme:
- İndirme Sayıları
- Kullanıcı Yorumları
- Çökme Raporları
- Gelir İstatistikleri

🔄 Güncellemeler:
- Hata Düzeltmeleri
- Yeni Özellikler
- Performans İyileştirmeleri
- Güvenlik Güncellemeleri
```

---

## 🚨 Önemli Notlar

### **Yasal Uyarılar**
```
⚠️ 13+ Kuralı:
- Çocuklardan veri toplama: YOK
- Ebeveyn onayı: GEREKMİYOR
- Kısıtlı içerik: YOK

🔒 Gizlilik:
- Veri toplama: Minimum
- Paylaşım: Sadece AdMob ile
- Şeffaflık: Politikada açıklandı
```

### **Teknik Gereksinimler**
```
📱 Minimum Sistem:
- Android: 5.0 (API 21)
- RAM: 1GB+
- Depolama: 50MB
- İnternet: İsteğe bağlı

🔧 Geliştirme:
- Flutter: 3.0+
- Dart: 3.0+
- Gradle: 8.0+
- Kotlin: 1.8+
```

---

## 📞 Yardım ve Destek

### **Google Play Destek**
```
📧 Yardım Merkezi: https://support.google.com/googleplay
📱 Geliştirici Politikaları: https://play.google.com/about/developer-content-policy/
🔒 Veri Güvenliği: https://support.google.com/googleplay/android-developer/answer/9451320
```

### **Hızlı Çözümler**
```
🚨 Yayın Gecikmesi:
- Politika incelemesi: 1-3 gün
- Teknik inceleme: 1-2 gün
- Red nedeni: Politikalar bölümü

🔧 Teknik Sorunlar:
- Build hataları: Flutter doctor
- İmzalama sorunları: Keytool
- Boyut optimizasyonu: APK Analyzer
```

---

**Bu rehber, Google Play Console'da yapılması gereken tüm ayarları kapsar. Her adımı dikkatlice uygulayın ve politikaları ihlal etmediğinizden emin olun.**
