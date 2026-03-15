import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'services/supabase_service.dart';
import 'screens/home_page.dart';
import 'screens/splash_screen.dart';
import 'models/theme_model.dart';
import 'utils/localizations.dart';
import 'utils/dynamic_localization_helper.dart';

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

  tz.initializeTimeZones();
  try {
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (_) {}

  final notificationService = NotificationService();
  await notificationService.initialize();

  // Hatırlatıcılar açıksa (reboot / güncelleme sonrası) yeniden planla
  final settingsService = SettingsService();
  final remEnabled = await settingsService.getReminderEnabled();
  if (remEnabled) {
    try {
      final days = await settingsService.getNotificationDays();
      final morningTime = await settingsService.getMorningNotificationTime();
      final eveningTime = await settingsService.getEveningNotificationTime();
      final morningOn = await settingsService.getMorningNotificationEnabled();
      final eveningOn = await settingsService.getEveningNotificationEnabled();
      if (days.isNotEmpty) {
        await notificationService.requestExactAlarmsPermission();
        await notificationService.scheduleReminderNotifications(
          selectedDays: days,
          morningTime: morningTime,
          eveningTime: eveningTime,
          morningEnabled: morningOn,
          eveningEnabled: eveningOn,
        );
      }
    } catch (e) {
      debugPrint('Hatırlatıcı yeniden planlama: $e');
    }
  }

  // Dynamic localization helper'ı başlat
  await DynamicLocalizationHelper.initialize();

  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // İlk açılışta dil kontrolü ve ayarlama
  final savedLanguage = await settingsService.getLanguage();
  
  // Eğer dil hiç ayarlanmamışsa (ilk açılış), cihaz diline göre ayarla
  if (savedLanguage.isEmpty) {
    final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode.toLowerCase();
    const supported = {
      'tr','en','ar','id','ur','bn','ms','fa','fr','zh','ja','ru','de','sw','ha'
    };
    final initialLanguage = supported.contains(deviceLang) ? deviceLang : 'tr';
    await settingsService.saveLanguage(initialLanguage);
    await DynamicLocalizationHelper.setLanguage(initialLanguage);
  } else {
    // Kaydedilmiş dili ayarla
    await DynamicLocalizationHelper.setLanguage(savedLanguage);
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
  String _currentLanguage = 'tr';
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
    _loadThemeMode();
    _loadLanguage();
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

  Future<void> _loadLanguage() async {
    final settingsService = SettingsService();
    final language = await settingsService.getLanguage();
    setState(() {
      _currentLanguage = language;
    });
    
    // Dynamic localization helper'ı da güncelle
    await DynamicLocalizationHelper.setLanguage(language);
    
    print('🌐 MyApp: Language loaded: $_currentLanguage');
    
    // Helper'ın doğru çalıştığını kontrol et
    print('🌐 DynamicLocalizationHelper test: ${DynamicLocalizationHelper.getText({
      'tr': 'Test Türkçe',
      'en': 'Test English',
      'ar': 'Test Arabic',
      'id': 'Test Indonesian',
    })}');
  }

  // Sync app counter with widget counter on app start to reflect widget interactions
  Future<void> _syncWidgetCounter() async {
    try {
      await WidgetService.syncWidgetCounter();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations(_currentLanguage);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tasbih Counter',
      locale: Locale(_currentLanguage),
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
            final themeId = 'blue_gold'; // Varsayılan tema
            final themeConfig = AppThemes.getTheme(themeId);
            
            return SplashScreen(
              themeConfig: themeConfig,
              localizations: localizations,
            );
          }
          
          // Ana sayfaya geç
          return HomePage(
            onThemeModeChanged: (mode) {
              setState(() => _themeMode = mode);
            },
            onLanguageChanged: (language) {
              setState(() {
                _currentLanguage = language;
              });
              // Dynamic localization helper'ı güncelle
              DynamicLocalizationHelper.setLanguage(language);
              print('🌐 MyApp: Language changed to: $_currentLanguage');
            },
          );
        },
      ),
    );
  }
}
