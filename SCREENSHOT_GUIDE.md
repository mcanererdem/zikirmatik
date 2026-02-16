# Screenshot Hazırlama Rehberi

## 📸 Screenshot Gereksinimleri

### Format
- **Boyut:** 1080x1920 px (9:16 aspect ratio)
- **Format:** PNG veya JPEG
- **Minimum:** 2 screenshot
- **Maximum:** 8 screenshot
- **Dosya boyutu:** Max 8MB per screenshot

## 🎯 Önerilen Screenshot Listesi

### 1. Ana Sayfa (Counter Screen) - ZORUNLU
**Gösterilecekler:**
- Büyük sayaç gösterimi (örn: 33)
- Temiz, minimal arayüz
- Hedef göstergesi
- Alt butonlar (reset, target, settings)

**Nasıl alınır:**
1. Uygulamayı aç
2. Sayacı 33'e getir
3. Hedefi 99'a ayarla
4. Screenshot al (Power + Volume Down)

### 2. Hedef Tamamlama (Success Dialog) - ZORUNLU
**Gösterilecekler:**
- Konfeti animasyonu
- "Maşallah! 🎉" mesajı
- Başarı dialogu

**Nasıl alınır:**
1. Hedefi düşük bir sayıya ayarla (örn: 5)
2. Hedefe ulaş
3. Dialog açıldığında screenshot al

### 3. İstatistikler Sayfası - ÖNERİLEN
**Gösterilecekler:**
- Günlük/Toplam sayaçlar
- Grafik gösterimi
- Trophy kartları
- Streak bilgisi

**Nasıl alınır:**
1. Ana sayfadan Statistics'e git
2. Grafik görünürken screenshot al

### 4. Tema Seçimi - ÖNERİLEN
**Gösterilecekler:**
- Farklı tema seçenekleri
- Renk paletleri
- Settings dialog

**Nasıl alınır:**
1. Settings'i aç
2. Tema seçenekleri görünürken screenshot al

### 5. Çoklu Dil Desteği - ÖNERİLEN
**Gösterilecekler:**
- Dil seçim listesi
- 15 dil seçeneği

**Nasıl alınır:**
1. Settings'i aç
2. Dil seçim butonuna tıkla
3. Liste açıkken screenshot al

### 6. Hedef Belirleme - ÖNERİLEN
**Gösterilecekler:**
- Target dialog
- Hızlı seçim butonları (33, 99, 100, 500, 1000)
- Custom target input

**Nasıl alınır:**
1. Ana sayfada Target butonuna tıkla
2. Dialog açıkken screenshot al

### 7. Widget Gösterimi - ÖNERİLEN
**Gösterilecekler:**
- Ana ekran widget'ı
- Widget üzerinde sayaç

**Nasıl alınır:**
1. Widget'ı ana ekrana ekle
2. Ana ekran screenshot'ı al
3. Widget'ın görünür olduğundan emin ol

### 8. Özel Zikir Ekleme - OPSIYONEL
**Gösterilecekler:**
- Add Dhikr dialog
- Arapça text input
- Çoklu dil alanları

## 🛠️ Screenshot Düzenleme

### Araçlar
- **Android Studio Device Frame:** Cihaz çerçevesi ekler
- **Figma/Canva:** Metin ve açıklama eklemek için
- **Screenshot Easy (App):** Direkt cihazdan frame ekler

### Düzenleme Önerileri
1. **Cihaz Frame Ekle:** Profesyonel görünüm için
2. **Metin Ekle (Opsiyonel):** Her screenshot'a kısa açıklama
3. **Tutarlılık:** Tüm screenshot'lar aynı cihaz frame'i kullanmalı
4. **Temiz Arka Plan:** Status bar'ı temizle (saat: 9:41, tam batarya)

### Android Studio ile Frame Ekleme
```bash
# Screenshot'ları şu klasöre koy:
zikirmatik/screenshots/raw/

# Android Studio'da:
1. Tools > Device Manager
2. Screenshot'ı aç
3. "Add Frame" seç
4. Export et
```

## 📐 Feature Graphic (Store Banner)

### Gereksinimler
- **Boyut:** 1024x500 px
- **Format:** PNG veya JPEG
- **Dosya boyutu:** Max 1MB

### İçerik Önerileri
```
┌─────────────────────────────────────────┐
│                                         │
│  🕌 Zikirmatik                          │
│     Digital Tasbih Counter              │
│                                         │
│  [Ana ekran görseli]  [İstatistik]     │
│                                         │
│  ✨ 15 Languages • Goals • Statistics  │
└─────────────────────────────────────────┘
```

### Tasarım Araçları
- **Canva:** Ücretsiz template'ler
- **Figma:** Profesyonel tasarım
- **Adobe Express:** Hızlı banner oluşturma

## 📁 Dosya Organizasyonu

```
zikirmatik/
├── screenshots/
│   ├── raw/                    # Ham screenshot'lar
│   │   ├── 01_home.png
│   │   ├── 02_success.png
│   │   ├── 03_statistics.png
│   │   └── ...
│   ├── framed/                 # Frame eklenmiş
│   │   ├── 01_home_framed.png
│   │   └── ...
│   └── final/                  # Store'a yüklenecek
│       ├── 01_home_final.png
│       ├── 02_success_final.png
│       └── ...
└── feature_graphic/
    └── zikirmatik_banner.png   # 1024x500
```

## ✅ Screenshot Checklist

- [ ] En az 2 screenshot hazır
- [ ] Tüm screenshot'lar 1080x1920 px
- [ ] Cihaz frame'i eklendi
- [ ] Status bar temiz (9:41, tam batarya)
- [ ] Tutarlı görünüm
- [ ] Dosya boyutları 8MB altında
- [ ] Feature graphic hazır (1024x500)
- [ ] Tüm dosyalar PNG/JPEG formatında

## 🎨 Tasarım İpuçları

1. **Kontrast:** Metin ve arka plan arasında yüksek kontrast
2. **Okunabilirlik:** Küçük ekranlarda da okunabilir olmalı
3. **Tutarlılık:** Aynı tema ve renk paleti kullan
4. **Basitlik:** Çok fazla bilgi ekleme
5. **Kalite:** Bulanık veya düşük çözünürlüklü görsel kullanma

## 📤 Yükleme

Google Play Console'da:
1. Store Listing > Graphics
2. Phone screenshots bölümüne sürükle-bırak
3. Sıralamayı düzenle (en iyi screenshot'ı başa koy)
4. Feature graphic'i yükle
5. Save draft

## 🔄 Sonraki Adım

Screenshot'lar hazır olduktan sonra `GOOGLE_PLAY_CONSOLE.md` dosyasına geçin.
