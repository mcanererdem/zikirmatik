import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_page.dart';
import 'services/location_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bildirim servisi başlat
  await NotificationService.initialize();
  await WidgetService.initialize();

  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // İlk açılışta lokasyon bazlı dil ayarı
  final settingsService = SettingsService();
  final savedLanguage = await settingsService.getLanguage();
  
  // Eğer varsayılan dil hala İngilizce ise (ilk açılış), lokasyona göre belirle
  if (savedLanguage == 'en') {
    try {
      final locationService = LocationService();
      final locationLanguage = await locationService.getLanguageByLocation();
      // Sadece İngilizce dışında bir dil bulunduysa değiştir
      if (locationLanguage != 'en') {
        await settingsService.saveLanguage(locationLanguage);
      }
    } catch (e) {
      // Lokasyon alınamazsa veya hata olursa İngilizce kalır
      print('Location-based language detection failed: $e');
    }
  }

  // Run the app immediately to avoid delaying the first frame.
  runApp(const MyApp());

  // Initialize AdMob in background (don't await here to avoid blocking UI).
  // Configure test device(s) to ensure test ads are returned while developing.
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: [
      '877E869F3262F1F3869B6957DB237A75', // device id shown in logs
    ]),
  ).then((_) => MobileAds.instance.initialize());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final settingsService = SettingsService();
    final mode = await settingsService.getThemeMode();
    setState(() {
      _themeMode = mode == 'light' ? ThemeMode.light : mode == 'dark' ? ThemeMode.dark : ThemeMode.system;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zikirmatik',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: _themeMode,
      home: HomePage(onThemeModeChanged: (mode) {
        setState(() => _themeMode = mode);
      }),
    );
  }
}