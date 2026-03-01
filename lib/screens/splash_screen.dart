import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const SplashScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _progressAnimation;
  
  late Animation<Color> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = Tween<Color>(
      begin: widget.themeConfig.accentColor.withOpacity(0.3),
      end: widget.themeConfig.accentColor,
    ).animate(_progressController);

    _startAnimations();
  }

  void _startAnimations() async {
    // Logo animasyonu başlat
    _logoController.forward();
    
    // 500ms sonra text animasyonu başlat
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    
    // 1000ms sonra progress animasyonu başlat
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
    
    // 3 saniye sonra ana ekrana geç
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ve İkon
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: widget.themeConfig.goldGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: widget.themeConfig.accentColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Uygulama Adı
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - _textAnimation.value)),
                        child: Column(
                          children: [
                            Text(
                              'Zikirmatik',
                              style: GoogleFonts.notoSans(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: widget.themeConfig.textColor,
                                shadows: [
                                  Shadow(
                                    color: widget.themeConfig.accentColor.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Zikir Huzuru',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                color: widget.themeConfig.textColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Loading Progress
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 200,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.themeConfig.textColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _colorAnimation.value ?? widget.themeConfig.accentColor,
                                widget.themeConfig.accentColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Loading Text
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _progressAnimation.value,
                      child: Text(
                        'Yükleniyor...',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: widget.themeConfig.textColor.withOpacity(0.6),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Versiyon Bilgisi
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value * 0.7,
                      child: Text(
                        'v1.0.0',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          color: widget.themeConfig.textColor.withOpacity(0.4),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
