import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class RandomNameGenerator {
  static final List<String> _consonants = [
    'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 
    'n', 'p', 'r', 's', 't', 'v', 'y', 'z', 'w', 'x'
  ];

  static final List<String> _vowels = [
    'a', 'e', 'i', 'o', 'u'
  ];

  static final List<String> _syllables = [
    'ba', 'be', 'bi', 'bo', 'bu', 'ca', 'ce', 'ci', 'co', 'cu',
    'da', 'de', 'di', 'do', 'du', 'fa', 'fe', 'fi', 'fo', 'fu',
    'ga', 'ge', 'gi', 'go', 'gu', 'ha', 'he', 'hi', 'ho', 'hu',
    'ja', 'je', 'ji', 'jo', 'ju', 'ka', 'ke', 'ki', 'ko', 'ku',
    'la', 'le', 'li', 'lo', 'lu', 'ma', 'me', 'mi', 'mo', 'mu',
    'na', 'ne', 'ni', 'no', 'nu', 'pa', 'pe', 'pi', 'po', 'pu',
    'ra', 're', 'ri', 'ro', 'ru', 'sa', 'se', 'si', 'so', 'su',
    'ta', 'te', 'ti', 'to', 'tu', 'va', 've', 'vi', 'vo', 'vu',
    'ya', 'ye', 'yi', 'yo', 'yu', 'za', 'ze', 'zi', 'zo', 'zu',
    'xab', 'xec', 'yid', 'zof', 'qum', 'lix', 'kyt', 'wop', 'nij', 'mex'
  ];

  static Future<String> generateRandomUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();
    
    String username = '';
    
    // 3-7 hece arasında rastgele isim oluştur
    final syllableCount = random.nextInt(5) + 3; // 3-7 arası
    
    for (int i = 0; i < syllableCount; i++) {
      if (random.nextDouble() < 0.8) {
        // %80 ihtimalle normal heceler
        username += _syllables[random.nextInt(_syllables.length - 10)]; // Normal heceler
      } else {
        // %20 ihtimalle anlamsız heceler
        username += _syllables[random.nextInt(10) + (_syllables.length - 10)]; // Anlamsız heceler
      }
    }
    
    // İlk harfi büyüt
    if (username.isNotEmpty) {
      username = username[0].toUpperCase() + username.substring(1);
    }
    
    // Sayı ekleme ihtimali (%40)
    if (random.nextDouble() < 0.4) {
      final number = random.nextInt(9999) + 1;
      username = '$username$number';
    }
    
    // Kullanılmış isimleri kontrol et
    final usedNames = prefs.getStringList('used_usernames') ?? [];
    int attempts = 0;
    
    while (usedNames.contains(username) && attempts < 100) {
      // Farklı bir isim dene
      username = '';
      final newSyllableCount = random.nextInt(5) + 3;
      
      for (int i = 0; i < newSyllableCount; i++) {
        if (random.nextDouble() < 0.8) {
          username += _syllables[random.nextInt(_syllables.length - 10)];
        } else {
          username += _syllables[random.nextInt(10) + (_syllables.length - 10)];
        }
      }
      
      if (username.isNotEmpty) {
        username = username[0].toUpperCase() + username.substring(1);
      }
      
      if (random.nextDouble() < 0.4) {
        final number = random.nextInt(9999) + 1;
        username = '$username$number';
      }
      
      attempts++;
    }
    
    // Kullanılan isimleri kaydet
    usedNames.add(username);
    if (usedNames.length > 1000) {
      usedNames.removeAt(0); // En eski ismi sil
    }
    await prefs.setStringList('used_usernames', usedNames);
    
    return username;
  }

  static String generateDisplayName() {
    final random = Random();
    
    // 2-4 hece arasında display name oluştur
    final syllableCount = random.nextInt(3) + 2; // 2-4 arası
    String displayName = '';
    
    for (int i = 0; i < syllableCount; i++) {
      if (random.nextDouble() < 0.7) {
        displayName += _syllables[random.nextInt(_syllables.length - 10)];
      } else {
        displayName += _syllables[random.nextInt(10) + (_syllables.length - 10)];
      }
    }
    
    // İlk harfi büyüt
    if (displayName.isNotEmpty) {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }
    
    return displayName;
  }

  static List<String> getAllCategories() {
    return [
      'Rastgele Harfler',
      'Hece Kombinasyonları',
      'Karışık İsimler'
    ];
  }

  static List<String> getNamesByCategory(String category) {
    final random = Random();
    final List<String> names = [];
    
    for (int i = 0; i < 20; i++) {
      String name = '';
      final syllableCount = random.nextInt(4) + 2; // 2-5 arası
      
      for (int j = 0; j < syllableCount; j++) {
        if (random.nextDouble() < 0.8) {
          name += _syllables[random.nextInt(_syllables.length - 10)];
        } else {
          name += _syllables[random.nextInt(10) + (_syllables.length - 10)];
        }
      }
      
      if (name.isNotEmpty) {
        name = name[0].toUpperCase() + name.substring(1);
        names.add(name);
      }
    }
    
    return names;
  }
}
