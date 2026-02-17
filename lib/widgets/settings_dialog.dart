import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/settings_service.dart';
import '../services/ad_service.dart';
import '../services/export_service.dart';
import '../widgets/confetti_animation.dart';
import '../screens/about_screen.dart';

class SettingsDialog extends StatefulWidget {
  final ThemeConfig currentTheme;
  final String currentLanguage;
  final Function(ThemeConfig) onThemeChanged;
  final Function(String) onLanguageChanged;
  final Function(ThemeMode)? onThemeModeChanged;
  final AppLocalizations localizations;

  const SettingsDialog({
    super.key,
    required this.currentTheme,
    required this.currentLanguage,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    this.onThemeModeChanged,
    required this.localizations,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ThemeConfig _selectedTheme;
  late String _selectedLanguage;
  late AppLocalizations _localizations;
  late ThemeMode _currentThemeMode;
  final AdService _adService = AdService();
  bool _isLoadingAd = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _selectedLanguage = widget.currentLanguage.isEmpty ? 'en' : widget.currentLanguage;
    _localizations = widget.localizations;
    _loadThemeMode();
  }

  void _showRewardedAd() {
    setState(() => _isLoadingAd = true);
    _adService.loadRewardedAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() => _isLoadingAd = false);
          _adService.showRewardedAd(
            onUserEarnedReward: () {
              if (mounted) {
                _showThankYouDialog();
              }
            },
            onAdDismissed: () {
              // Dialog kapatıldığında hiçbir şey yapma
            },
          );
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) {
          setState(() => _isLoadingAd = false);
          Navigator.pop(context); // Ayarlar sayfasını kapat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _localizations.translate('ad_not_ready') ?? 'Ad not ready',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.fixed,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              action: SnackBarAction(
                label: _localizations.ok,
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
    );
  }

  void _showThankYouDialog() {
    setState(() => _showConfetti = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          if (_showConfetti)
            ConfettiAnimation(
              onComplete: () {
                if (mounted) setState(() => _showConfetti = false);
              },
            ),
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: _selectedTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _selectedTheme.accentColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: _selectedTheme.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _localizations.translate('thank_you_support') ?? 'Thank you! 🙏',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _selectedTheme.accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _localizations.translate('support_description') ?? 'Your support means a lot!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: _selectedTheme.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() => _showConfetti = false);
                          Navigator.pop(context); // Teşekkür dialogunu kapat
                          Navigator.pop(context); // Ayarlar sayfasını kapat
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _localizations.ok,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadThemeMode() async {
    final settingsService = SettingsService();
    final mode = await settingsService.getThemeMode();
    if (mounted) {
      setState(() {
        _currentThemeMode = mode == 'light' ? ThemeMode.light : mode == 'dark' ? ThemeMode.dark : ThemeMode.system;
      });
    }
  }

  void _updateTheme(ThemeConfig theme) {
    setState(() {
      _selectedTheme = theme;
    });
    widget.onThemeChanged(theme);
  }

  void _updateLanguage(String languageCode) {
    if (languageCode == 'ar') {
      setState(() {
        _selectedLanguage = languageCode;
        _localizations = AppLocalizations(languageCode);
      });
      widget.onLanguageChanged(languageCode);
      return;
    }

    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'id', 'name': 'Bahasa Indonesia'},
      {'code': 'ur', 'name': 'اردو (Urdu)'},
      {'code': 'bn', 'name': 'বাংলা (Bengali)'},
      {'code': 'ms', 'name': 'Bahasa Melayu'},
      {'code': 'fa', 'name': 'فارسی (Persian)'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'zh', 'name': '中文 (Chinese)'},
      {'code': 'ja', 'name': '日本語 (Japanese)'},
      {'code': 'ru', 'name': 'Русский (Russian)'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'sw', 'name': 'Kiswahili'},
      {'code': 'ha', 'name': 'Hausa'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _selectedTheme.primaryColor,
        title: Text(
          _localizations.language,
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: languages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final lang = languages[index];
              return _buildLanguageSelectButton(
                ctx,
                lang['code']!,
                lang['name']!,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelectButton(BuildContext ctx, String code, String name) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        setState(() {
          _selectedLanguage = code;
          _localizations = AppLocalizations(code);
        });
        widget.onLanguageChanged(code);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: _selectedTheme.backgroundGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _selectedTheme.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _selectedTheme.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: _selectedTheme.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _localizations.settings,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                _localizations.theme,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTheme.accentColor.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppThemes.themes.map((theme) {
                  return _buildThemeOption(theme);
                }).toList(),
              ),

              const SizedBox(height: 24),

              Text(
                _localizations.language,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTheme.accentColor.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildLanguageOption('ar', _localizations.arabic, Icons.language),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _updateLanguage(''),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.translate, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _getSecondaryLanguageName(),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _selectedTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedTheme.accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _localizations.ok,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedTheme.accentColor.withOpacity(0.2),
                      _selectedTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedTheme.accentColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: _selectedTheme.accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _localizations.translate('support_us') ?? 'Support Us',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _selectedTheme.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _localizations.translate('support_description') ?? 'Help us by watching a short ad',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isLoadingAd ? null : _showRewardedAd,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: _selectedTheme.goldGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoadingAd)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else
                              const Icon(
                                Icons.play_circle_filled_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _localizations.translate('watch_ad') ?? 'Watch Ad',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.orange.shade300,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedLanguage == 'tr' ? 'Huawei Cihazlar İçin' : 'For Huawei Devices',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedLanguage == 'tr'
                          ? 'Bildirimler için: Ayarlar → Uygulamalar → BILDIRICIM → Pil → Uygulama başlatma → Manuel yönet → tüm seçenekleri açın'
                          : 'For notifications: Settings → Apps → BILDIRICIM → Battery → App launch → Manage manually → enable all options',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async {
                  final exportService = ExportService(SettingsService());
                  await exportService.exportData();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _localizations.translate('export_data') ?? 'Export Data',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () async {
                  final exportService = ExportService(SettingsService());
                  final data = await exportService.importFromFile();
                  if (data != null && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_localizations.translate('import_success') ?? 'Import successful!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_localizations.translate('import_failed') ?? 'Import failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Import',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutScreen(
                        themeConfig: _selectedTheme,
                        localizations: _localizations,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _localizations.about,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSecondaryLanguage() {
    if (_selectedLanguage == 'tr' || _selectedLanguage == 'id') {
      return _selectedLanguage;
    }
    return 'en';
  }

  String _getSecondaryLanguageName() {
    final lang = _getSecondaryLanguage();
    switch (lang) {
      case 'tr':
        return _localizations.turkish;
      case 'id':
        return _localizations.indonesian;
      default:
        return _localizations.english;
    }
  }

  Widget _buildThemeOption(ThemeConfig theme) {
    final isSelected = theme.id == _selectedTheme.id;
    String themeName;
    switch (_selectedLanguage) {
      case 'ar':
        themeName = theme.nameAr;
        break;
      case 'id':
        themeName = theme.nameId;
        break;
      case 'tr':
        themeName = theme.nameTr;
        break;
      default:
        themeName = theme.nameEn;
    }

    return GestureDetector(
      onTap: () => _updateTheme(theme),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? _selectedTheme.goldGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _selectedTheme.accentColor
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: theme.buttonGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              themeName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String languageCode, String languageName, [IconData? icon]) {
    final isSelected = languageCode == _selectedLanguage;

    return GestureDetector(
      onTap: () => _updateLanguage(languageCode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? _selectedTheme.goldGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? _selectedTheme.accentColor
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              languageName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
