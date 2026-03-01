import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'services/supabase_service.dart';
import 'screens/home_page.dart';
import 'screens/splash_screen.dart';
import 'models/theme_model.dart';
import 'utils/localizations.dart';

@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) async {
  final settingsService = SettingsService();
  int counter = await settingsService.getCurrentCount();

  // Handle different widget button actions by host/path
  if (uri?.host == 'increment' || uri?.path == '/increment') {
    counter++;
    await settingsService.saveCurrentCount(counter);
    await WidgetService.updateWidget(counter);
    return;
  }

  if (uri?.host == 'decrement' || uri?.path == '/decrement') {
    if (counter > 0) counter--;
    await settingsService.saveCurrentCount(counter);
    await WidgetService.updateWidget(counter);
    return;
  }

  if (uri?.host == 'reset' || uri?.path == '/reset') {
    counter = 0;
    await settingsService.saveCurrentCount(counter);
    await WidgetService.updateWidget(counter);
    return;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(backgroundCallback);

  // Bildirim servisi başlat
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // İlk açılışta dil İngilizce olarak ayarlanır
  final settingsService = SettingsService();
  final savedLanguage = await settingsService.getLanguage();
  
  // Eğer dil hiç ayarlanmamışsa (ilk açılış), cihaz diline göre ayarla
  if (savedLanguage.isEmpty) {
    final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
    const supported = {
      'tr','en','ar','id','ur','bn','ms','fa','fr','zh','ja','ru','de','sw','ha'
    };
    await settingsService.saveLanguage(supported.contains(deviceLang) ? deviceLang : 'en');
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
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
    _loadThemeMode();
    _syncWidgetCounter();
  }

  Future<void> _initializeApp() async {
    // Gerekli başlangıç işlemleri
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _loadThemeMode() async {
    final settingsService = SettingsService();
    final mode = await settingsService.getThemeMode();
    setState(() {
      _themeMode = mode == 'light' ? ThemeMode.light : mode == 'dark' ? ThemeMode.dark : ThemeMode.system;
    });
  }

  // Sync app counter with widget counter on app start to reflect widget interactions
  Future<void> _syncWidgetCounter() async {
    try {
      await WidgetService.syncWidgetCounter();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasbih Counter',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      themeMode: _themeMode,
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Splash screen göster
            final settingsService = SettingsService();
            return FutureBuilder<String>(
              future: settingsService.getLanguage(),
              builder: (context, langSnapshot) {
                final languageCode = langSnapshot.data ?? 'tr';
                final localizations = AppLocalizations(languageCode);
                final themeId = 'blue_gold'; // Varsayılan tema
                final themeConfig = AppThemes.getTheme(themeId);
                
                return SplashScreen(
                  themeConfig: themeConfig,
                  localizations: localizations,
                );
              },
            );
          }
          
          // Ana sayfaya geç
          return HomePage(onThemeModeChanged: (mode) {
            setState(() => _themeMode = mode);
          });
        },
      ),
    );
  }
}
