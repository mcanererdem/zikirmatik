# Goal, Trophy & Streak System - Complete Logic

## Terimler (Terms)

### 1. **Zikir (Dhikr)**
- Kullanıcının çektiği her bir zikir (örn: Sübhanallah, Elhamdülillah)
- Her zikrin varsayılan bir hedefi var (örn: 33, 100)
- Kullanıcı ana ekranda zikir çeker

### 2. **Hedef (Goal/Target)**
- Ana ekrandaki sayaç hedefi (örn: 100 zikir çek)
- Hedefe ulaşınca "Maşallah" dialogu çıkar
- Bu sadece sayaç hedefidir, trophy değildir

### 3. **Trophy (Kupa)**
- Kullanıcının belirlediği özel hedefler
- 3 tip: Günlük, Haftalık, Aylık
- Örnek: "Günlük 300 Sübhanallah çek"
- Trophy tamamlanınca bildirim gösterilir

### 4. **Streak (Seri)**
- Ardışık trophy tamamlama serisi
- Sadece trophy'ler için geçerlidir
- Günlük streak: Ardışık günlerde günlük trophy tamamlama
- Haftalık streak: Ardışık haftalarda haftalık trophy tamamlama
- Aylık streak: Ardışık aylarda aylık trophy tamamlama

---

## Mevcut Sorunlar

1. ❌ Hedef (target) ve Trophy karışıyor
2. ❌ Streak mantığı yanlış - her zikir çekişte streak artıyor
3. ❌ Aynı gün birden fazla trophy tamamlama streak sayılıyor
4. ❌ Success dialog'da streak gösteriliyor ama bu kafa karıştırıcı

---

## Yeni Mantık (Correct Logic)

### A. Ana Ekran Sayacı (Main Counter)
```
Kullanıcı zikir çeker → Sayaç artar → Hedefe ulaşır
→ "Maşallah" dialogu (konfeti + ses + titreşim)
→ STREAK YOK, sadece tebrik mesajı
```

**Örnek:**
- Kullanıcı Sübhanallah seçti (hedef: 33)
- 33 kez tıkladı
- "Maşallah! 33 zikir tamamlandı" mesajı
- Devam Et / Sıfırla seçenekleri

### B. Trophy Sistemi (Trophy System)

#### B.1. Trophy Oluşturma
```
Kullanıcı → Hedefler (🏆) → Yeni Hedef Ekle
→ Tip seç (Günlük/Haftalık/Aylık)
→ Zikir seç (Sübhanallah, Elhamdülillah, vb.)
→ Adet gir (örn: 300)
→ Kaydet
```

#### B.2. Trophy Tamamlama
```
Kullanıcı zikir çeker → Trophy progress güncellenir
→ Trophy hedefine ulaşır
→ SnackBar: "🏆 Trophy Tamamlandı! 300 Sübhanallah"
→ Trophy "completed" olarak işaretlenir
```

**Önemli:**
- Aynı gün birden fazla aynı tip trophy tamamlanabilir
- Ama streak için sadece ilki sayılır

#### B.3. Streak Hesaplama

**Günlük Trophy Streak:**
```
Bugün günlük trophy tamamladı → streak_last_date = bugün
Yarın günlük trophy tamamladı → streak++
İki gün sonra günlük trophy tamamladı → streak = 1 (sıfırlandı)
```

**Haftalık Trophy Streak:**
```
Bu hafta haftalık trophy tamamladı → streak_last_week = bu hafta
Gelecek hafta haftalık trophy tamamladı → streak++
İki hafta sonra haftalık trophy tamamladı → streak = 1 (sıfırlandı)
```

**Aylık Trophy Streak:**
```
Bu ay aylık trophy tamamladı → streak_last_month = bu ay
Gelecek ay aylık trophy tamamladı → streak++
İki ay sonra aylık trophy tamamladı → streak = 1 (sıfırlandı)
```

---

## Veri Yapısı (Data Structure)

### SharedPreferences Keys

```dart
// Trophy data
'goals' → List<Goal> (JSON)

// Streak tracking (per trophy type)
'trophy_streak_daily' → int (current streak)
'trophy_streak_weekly' → int
'trophy_streak_monthly' → int

'trophy_best_daily' → int (best streak ever)
'trophy_best_weekly' → int
'trophy_best_monthly' → int

'trophy_last_daily' → String (date: "2025_1_17")
'trophy_last_weekly' → String (week: "2025_W03")
'trophy_last_monthly' → String (month: "2025_1")

'trophy_completed_today_daily' → int (count of daily trophies completed today)
'trophy_completed_today_weekly' → int
'trophy_completed_today_monthly' → int
```

### Goal Model
```dart
class Goal {
  String id;
  String type; // 'daily', 'weekly', 'monthly'
  String zikrId;
  int targetCount;
  int currentProgress;
  bool isCompleted;
  DateTime? completedDate;
  DateTime createdDate;
  DateTime expiryDate;
}
```

---

## Kullanıcı Senaryoları (User Scenarios)

### Senaryo 1: Basit Zikir Çekme (No Trophy)
```
1. Kullanıcı Sübhanallah seçer (hedef: 33)
2. 33 kez tıklar
3. "Maşallah! 33 zikir tamamlandı" dialogu
4. Devam Et → Sayaç sıfırlanır
5. STREAK YOK
```

### Senaryo 2: Günlük Trophy ile Zikir
```
1. Kullanıcı günlük trophy ekler: "300 Sübhanallah"
2. Zikir çeker → Progress: 150/300
3. Devam eder → Progress: 300/300
4. SnackBar: "🏆 Günlük Trophy Tamamlandı! 300 Sübhanallah"
5. trophy_last_daily = "2025_1_17"
6. trophy_completed_today_daily = 1
7. STREAK = 0 (ilk gün)
```

### Senaryo 3: Ardışık Günlerde Trophy (Streak Başlar)
```
Gün 1: Günlük trophy tamamla → streak = 0
Gün 2: Günlük trophy tamamla → streak = 1 (🔥 1 gün streak!)
Gün 3: Günlük trophy tamamla → streak = 2 (🔥 2 gün streak!)
Gün 5: Günlük trophy tamamla → streak = 1 (ara verildi, sıfırlandı)
```

### Senaryo 4: Aynı Gün Birden Fazla Trophy
```
1. Kullanıcı 2 günlük trophy ekler:
   - Trophy A: 300 Sübhanallah
   - Trophy B: 100 Elhamdülillah
2. İkisini de bugün tamamlar
3. Her ikisi için bildirim gösterilir
4. Ama streak için sadece ilk tamamlanan sayılır
5. trophy_completed_today_daily = 2
```

### Senaryo 5: Haftalık Trophy Streak
```
Hafta 1 (Ocak 13-19): Haftalık trophy tamamla → streak = 0
Hafta 2 (Ocak 20-26): Haftalık trophy tamamla → streak = 1
Hafta 3 (Ocak 27-Feb 2): Haftalık trophy tamamla → streak = 2
Hafta 5: Haftalık trophy tamamla → streak = 1 (ara verildi)
```

---

## UI Değişiklikleri (UI Changes)

### 1. Success Dialog (Maşallah Sayfası)
**ŞU AN:**
- Streak bilgisi gösteriliyor (YANLIŞ)

**OLMALI:**
- Sadece tebrik mesajı
- Streak bilgisi YOK
- Basit ve temiz

```dart
SuccessDialog(
  count: _counter,
  onContinue: () { ... },
  onReset: () { ... },
  // streakInfo: null, // KALDIR
)
```

### 2. Trophy Completion SnackBar
**ŞU AN:**
- Basit snackbar

**OLMALI:**
- Daha göze çarpan
- Streak bilgisi varsa göster
- Yeni rekor varsa göster

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Column(
      children: [
        Text('🏆 Günlük Trophy Tamamlandı!'),
        Text('300 Sübhanallah'),
        if (streak > 0) Text('🔥 $streak gün streak!'),
        if (isNewBest) Text('⭐ Yeni rekor!'),
      ],
    ),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 5),
    behavior: SnackBarBehavior.floating,
  ),
);
```

### 3. Statistics Screen
**Yeni Bölüm: Trophy Streaks**
```
📊 İstatistikler
├── Bugün: 150 zikir
├── Toplam: 5,420 zikir
├── 🏆 Trophy Başarıları
│   ├── Günlük Streak: 🔥 5 gün (En iyi: 12)
│   ├── Haftalık Streak: 🔥 2 hafta (En iyi: 4)
│   └── Aylık Streak: 🔥 0 ay (En iyi: 2)
└── Grafikler...
```

---

## Kod Değişiklikleri (Code Changes)

### 1. settings_service.dart
```dart
// Yeni metodlar
Future<Map<String, dynamic>?> completeTrophy(String goalId, String type) async {
  // Trophy tamamlandığında çağrılır
  // Streak hesaplar
  // Bildirim için veri döner
}

Future<Map<String, int>> getTrophyStreaks() async {
  // Tüm streak bilgilerini döner
}

bool _isConsecutivePeriod(String type, String lastDate, String currentDate) {
  // Ardışık mı kontrol eder
}
```

### 2. counter_logic.dart
```dart
Future<Map<String, dynamic>> updateGoalProgress(
  List<Goal> goals,
  String? zikrId,
) async {
  // Trophy progress günceller
  // Tamamlananları tespit eder
  // Streak bilgisini döner
}
```

### 3. home_page.dart
```dart
void _showGoalCompletedNotification(Goal goal, Map<String, dynamic>? streakInfo) {
  // Trophy tamamlama bildirimi
  // Streak varsa göster
  // Success dialog'dan AYRI
}

void _showSuccessAnimation() {
  // Sadece sayaç hedefi için
  // Streak bilgisi YOK
}
```

---

## Test Senaryoları (Test Scenarios)

### Test 1: Basit Zikir
- [ ] 33 zikir çek
- [ ] "Maşallah" dialogu çıksın
- [ ] Streak bilgisi OLMASIN

### Test 2: İlk Trophy
- [ ] Günlük trophy ekle
- [ ] Tamamla
- [ ] SnackBar göster
- [ ] Streak = 0

### Test 3: Ardışık Trophy
- [ ] Bugün günlük trophy tamamla
- [ ] Yarın günlük trophy tamamla
- [ ] Streak = 1 göster

### Test 4: Ara Verme
- [ ] Bugün trophy tamamla
- [ ] 2 gün ara ver
- [ ] 3. gün trophy tamamla
- [ ] Streak = 1 (sıfırlandı)

### Test 5: Aynı Gün Çoklu Trophy
- [ ] 2 günlük trophy ekle
- [ ] İkisini de tamamla
- [ ] Her ikisi için bildirim
- [ ] Streak sadece ilki için

---

## Özet (Summary)

**3 Ayrı Kavram:**
1. **Sayaç Hedefi** → Maşallah dialogu, streak YOK
2. **Trophy** → SnackBar bildirimi, tamamlama kaydı
3. **Streak** → Sadece trophy'ler için, ardışık tamamlama

**Streak Kuralları:**
- Günlük: Her gün en az 1 günlük trophy tamamla
- Haftalık: Her hafta en az 1 haftalık trophy tamamla
- Aylık: Her ay en az 1 aylık trophy tamamla
- Ara verilirse streak sıfırlanır
- Aynı gün birden fazla trophy → sadece ilki streak'e sayılır

**UI Ayrımı:**
- Success Dialog = Sayaç hedefi (streak YOK)
- SnackBar = Trophy tamamlama (streak VAR)
- Statistics = Trophy streak gösterimi
