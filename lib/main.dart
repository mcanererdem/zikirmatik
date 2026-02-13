import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_page.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zikirmatik',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}