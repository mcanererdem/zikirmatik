# Google Play Console Yayınlama Rehberi

## 🎯 Genel Bakış

Bu rehber, uygulamanızı Google Play Store'da yayınlamak için gereken tüm adımları içerir.

## 💳 Ön Gereksinimler

- [X] Google hesabı
- [X] $25 tek seferlik geliştirici ücreti
- [X] Kredi kartı veya Google Pay

## 📝 Adım 1: Google Play Console Hesabı Oluşturma

### 1.1 Hesap Açma
1. https://play.google.com/console adresine git
2. "Sign up" butonuna tıkla
3. Google hesabınla giriş yap
4. Developer olarak kayıt ol

### 1.2 Ödeme
1. $25 kayıt ücretini öde
2. Geliştirici bilgilerini doldur:
   - **Developer name:** Caner Erdem (veya istediğin isim)
   - **Email:** mcanererdem@gmail.com
   - **Website:** github.com/mcanererdem/zikirmatik (opsiyonel)
   - **Phone:** +90 XXX XXX XX XX

### 1.3 Hesap Doğrulama
1. Email doğrulaması yap
2. Telefon doğrulaması (SMS)
3. Kimlik doğrulama (gerekirse)

## 📱 Adım 2: Yeni Uygulama Oluşturma

### 2.1 Create App
1. "Create app" butonuna tıkla
2. Bilgileri doldur:
   - **App name:** Zikirmatik - Digital Tasbih
   - **Default language:** English (US)
   - **App or game:** App
   - **Free or paid:** Free
   - **Declarations:** Tüm checkbox'ları işaretle

### 2.2 Store Presence

#### Store Listing
1. **App details**
   - **App name:** `Zikirmatik - Digital Tasbih`
   - **Short description (80 characters):** 
   ```
   Digital tasbih counter with goals, statistics & 15 languages support
   ```
   
   - **Full description (4000 characters):**
   ```
   Tasbih Counter is a simple, accessible digital tasbih (dhikr counter) app designed to help Muslims track their daily prayers and personal dhikr.

   🔢 MAIN FEATURES
   • Tap counter with haptic feedback
   • Data persistence - your counts are saved
   • 15 language support (Turkish, English, Arabic, Indonesian, Urdu, Bengali, Malay, Persian, French, Chinese, Japanese, Russian, German, Swahili, Hausa)
   • Multiple theme options with dark mode
   • Customizable settings (vibration, sound, confetti)

   🎯 GOALS & STATISTICS
   • Multiple goal system (daily/weekly/monthly)
   • Trophy system for completed goals
   • Streak tracking (consecutive days/weeks/months)
   • Detailed statistics with charts
   • Same-day multiple goal completion support

   📱 ADDITIONAL FEATURES
   • Home screen widget with live sync
   • Custom dhikr names (15 languages)
   • Screen rotation support
   • Accessibility support (TalkBack/VoiceOver)
   • Export/Import data (JSON format)
   • Ad-supported (banner + rewarded ads)

   ♿ ACCESSIBILITY
   Full screen reader support for visually impaired users.

   🌍 SUPPORTED LANGUAGES
   Turkish, English, Arabic, Indonesian, Urdu, Bengali, Malay, Persian, French, Chinese, Japanese, Russian, German, Swahili, Hausa

   📊 PRIVACY
   All data is stored locally on your device. We don't collect or transmit personal information.

   Perfect for daily dhikr, Tasbih, Tahmid, Takbir, and other Islamic remembrances.
   ```

2. **Graphics**
   - App icon: 512x512 (zaten var)
   - Feature graphic: 1024x500 (hazırlanacak)
   - Phone screenshots: En az 2 (hazırlanacak)

3. **Categorization**
   - App category: Lifestyle
   - Tags: tasbih, dhikr, islamic, muslim, counter

4. **Contact details**
   - Email: mcanererdem@gmail.com
   - Website: github.com/mcanererdem/zikirmatik
   - Phone: (opsiyonel)

5. **Privacy Policy**
   - **URL:** `https://mcanererdem.github.io/zikirmatik/privacy_policy.html`
   - (GitHub Pages'de yayında, app adı Tasbih Counter olarak güncel)

## 🔒 Adım 3: App Content

### 3.1 Privacy Policy
1. **Privacy policy URL:** `https://mcanererdem.github.io/zikirmatik/privacy_policy.html`
2. Data safety form'unu doldur:
   - **Data collection:** No data collected
   - **Data sharing:** No data shared
   - **Security practices:** Data encrypted in transit

### 3.2 Content Rating
1. "Start questionnaire" tıkla
2. Email: mcanererdem@gmail.com
3. Category: Utility, Productivity, Communication, or Other
4. Soruları cevapla:
   - Violence: No
   - Sexual content: No
   - Language: No
   - Controlled substances: No
   - Gambling: No
   - User interaction: No
   - Location sharing: No
   - Personal info sharing: No
5. Submit
6. Beklenen rating: **Everyone**

### 3.3 Target Audience
1. Target age: 13+
2. Appeal to children: No
3. Store listing: General audience

### 3.4 News Apps
- Skip (not a news app)

### 3.5 COVID-19 Contact Tracing
- Skip (not applicable)

### 3.6 Data Safety
1. "Start" tıkla
2. Data collection: **No, we don't collect any data**
3. Data sharing: **No, we don't share any data**
4. Security practices:
   - Data encrypted in transit: Yes
   - Users can request data deletion: N/A
   - Committed to Google Play Families Policy: No
5. Save

### 3.7 Government Apps
- Skip (not a government app)

### 3.8 Financial Features
- Skip (no financial features)

### 3.9 Advertising
- **Contains ads:** Yes
- **Ad format:** Banner ads (AdMob)

## 🚀 Adım 4: Release

### 4.1 Production Release
1. "Production" sekmesine git
2. "Create new release" tıkla

### 4.2 App Bundle Upload
1. "Upload" butonuna tıkla
2. `app-release.aab` dosyasını seç (build/app/outputs/bundle/release/)
3. Upload tamamlanana kadar bekle

### 4.3 Release Details
1. **Release name:** 1.0.0 (Initial Release)
2. **Release notes:**
```
Initial release of Zikirmatik - Digital Tasbih Counter

Features:
• Simple and elegant counter interface
• Goal setting with quick targets
• Detailed statistics and charts
• 15 languages support
• Multiple themes with dark mode
• Home screen widget (Android)
• Daily reminders
• Custom dhikr support
• Offline functionality
• Privacy-focused design

Perfect for daily dhikr tracking and spiritual goal setting.
```

### 4.4 Review and Rollout
1. Tüm bilgileri kontrol et
2. "Review release" tıkla
3. Uyarıları kontrol et ve düzelt
4. "Start rollout to Production" tıkla

## ⏱️ Adım 5: Review Süreci

### Bekleme Süresi
- **İlk yayın:** 1-7 gün
- **Güncellemeler:** 1-3 gün

### Review Durumları
- **Pending publication:** İnceleme bekliyor
- **Under review:** İnceleniyor
- **Approved:** Onaylandı, yayınlanıyor
- **Published:** Yayında!
- **Rejected:** Reddedildi (düzeltme gerekli)

### Reddedilme Durumunda
1. Reddetme sebebini oku
2. Gerekli düzeltmeleri yap
3. Yeni AAB build et
4. Tekrar yükle ve gönder

## 📊 Adım 6: Yayın Sonrası

### 6.1 Türkçe Listing Ekleme (Opsiyonel)
1. Store presence > Main store listing
2. "Add language" > Turkish
3. Bilgileri doldur:

   - **Kısa açıklama (80 karakter):**
   ```
   Dijital tesbih - Hedefler, istatistikler ve 15 dil desteği
   ```
   
   - **Tam açıklama:**
   ```
   Zikirmatik, Müslümanların günlük ibadetlerini ve kişisel zikirlerini takip etmelerine yardımcı olmak için tasarılanmış sade ve erişilebilir bir dijital tesbih uygulamasıdır.

   🔢 TEMEL ÖZELLİKLER
   • Dokunmatik sayaç (titreşim desteği)
   • Veri korunması - sayılarınız kaydedilir
   • 15 dil desteği (Türkçe, İngilizce, Arapça, Endonezce, Urduca, Bengalce, Malayca, Farsça, Fransızca, Çince, Japonca, Rusça, Almanca, Svahili, Hausa)
   • Çoklu tema seçenekleri ve karanlık mod
   • Özelleştirilebilir ayarlar (titreşim, ses, konfeti)

   🎯 HEDEFLER VE İSTATİSTİKLER
   • Çoklu hedef sistemi (günlük/haftalık/aylık)
   • Tamamlanan hedefler için kupa sistemi
   • Seri takibi (ardışık gün/hafta/ay)
   • Grafikli detaylı istatistikler
   • Aynı gün birden fazla hedef tamamlama desteği

   📱 EK ÖZELLİKLER
   • Ana ekran widget'ı (canlı senkronizasyon)
   • Özel zikir isimleri (15 dil)
   • Ekran döndürme desteği
   • Erişilebilirlik desteği (TalkBack/VoiceOver)
   • Veri dışa/içe aktarma (JSON format)
   • Reklam destekli (banner + ödüllü reklamlar)

   ♿ ERİŞİLEBİLİRLİK
   Görme engelli kullanıcılar için tam ekran okuyucu desteği.

   🌍 DESTEKLENEN DİLLER
   Türkçe, İngilizce, Arapça, Endonezce, Urduca, Bengalce, Malayca, Farsça, Fransızca, Çince, Japonca, Rusça, Almanca, Svahili, Hausa

   📊 GİZLİLİK
   Tüm veriler cihazınızda yerel olarak saklanır. Kişisel bilgi toplamayız veya iletmiyoruz.

   Günlük zikir, Tesbih, Tahmid, Tekbir ve diğer İslami zikirler için mükemmel.
   ```

4. Save

### 6.2 Store Listing Kontrolü
1. Play Store'da uygulamayı ara
2. Tüm bilgilerin doğru göründüğünden emin ol
3. Screenshot'ların düzgün yüklendiğini kontrol et

### 6.2 İlk Kullanıcı Geri Bildirimleri
1. İlk yorumları takip et
2. Hızlı yanıt ver
3. Sorunları not al

### 6.3 Analytics Kurulumu
1. Google Play Console > Statistics
2. Kullanıcı sayısını takip et
3. Crash raporlarını kontrol et

## 🔄 Güncelleme Yayınlama

### Version Code Artırma
1. `pubspec.yaml` dosyasını aç
2. Version'ı güncelle: `1.0.0+1` → `1.0.1+2`
3. Build yap: `flutter build appbundle --release`
4. Play Console'da yeni release oluştur
5. Yeni AAB'yi yükle
6. Release notes yaz
7. Rollout başlat

## ⚠️ Önemli Notlar

### Keystore Güvenliği
- Keystore dosyasını **ASLA** kaybetme
- Şifreleri güvenli bir yerde sakla
- Yedek al (Google Drive, USB, vb.)
- Keystore kaybedilirse uygulama güncellenemez!

### Store Listing Güncellemeleri
- Store listing değişiklikleri anında yansır
- AAB güncellemeleri review gerektirir
- Screenshot'ları istediğin zaman değiştirebilirsin

### Yasaklı İçerik
- Telif hakkı ihlali
- Yanıltıcı bilgi
- Spam
- Zararlı davranış
- Uygunsuz içerik

## 📞 Destek

### Google Play Console Yardım
- https://support.google.com/googleplay/android-developer

### Sık Sorulan Sorular
- https://support.google.com/googleplay/android-developer/answer/9859152

### İletişim
- Play Console içinden "Contact us"
- Email: mcanererdem@gmail.com (geliştirici)

## ✅ Final Checklist

- [ ] Google Play Console hesabı açıldı ($25 ödendi)
- [ ] Uygulama oluşturuldu
- [ ] Store listing tamamlandı
- [ ] Screenshots yüklendi
- [ ] Feature graphic yüklendi
- [ ] Privacy policy eklendi
- [ ] Content rating tamamlandı
- [ ] Data safety form dolduruldu
- [ ] AAB dosyası yüklendi
- [ ] Release notes yazıldı
- [ ] Review'a gönderildi
- [ ] Keystore yedeklendi

## 🎉 Tebrikler!

Uygulamanız artık Google Play Store'da review sürecinde! 

Onaylandıktan sonra milyonlarca kullanıcıya ulaşabileceksiniz. 🚀
