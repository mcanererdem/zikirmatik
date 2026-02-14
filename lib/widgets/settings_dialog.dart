import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import 'custom_about_dialog.dart';

class SettingsDialog extends StatefulWidget {
  final ThemeConfig currentTheme;
  final String currentLanguage;
  final Function(ThemeConfig) onThemeChanged;
  final Function(String) onLanguageChanged;
  final AppLocalizations localizations;

  const SettingsDialog({
    super.key,
    required this.currentTheme,
    required this.currentLanguage,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.localizations,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ThemeConfig _selectedTheme;
  late String _selectedLanguage;
  late AppLocalizations _localizations;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
    _selectedLanguage = widget.currentLanguage;
    _localizations = widget.localizations;
  }

  void _updateTheme(ThemeConfig theme) {
    setState(() {
      _selectedTheme = theme;
    });
    widget.onThemeChanged(theme);
  }

  void _updateLanguage(String languageCode) {
    // Arapça seçilirse direkt değiştir
    if (languageCode == 'ar') {
      setState(() {
        _selectedLanguage = languageCode;
        _localizations = AppLocalizations(languageCode);
      });
      widget.onLanguageChanged(languageCode);
      return;
    }

    // Diğer diller için seçenek sun
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _selectedTheme.primaryColor,
        title: Text(
          _localizations.language,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageSelectButton(ctx, 'en', _localizations.english),
            const SizedBox(height: 8),
            _buildLanguageSelectButton(ctx, 'tr', _localizations.turkish),
            const SizedBox(height: 8),
            _buildLanguageSelectButton(ctx, 'id', _localizations.indonesian),
          ],
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
              // Header
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
                  Text(
                    _localizations.settings,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Theme Selection
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

              // Language Selection
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

              // About Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close settings
                  showDialog(
                    context: context,
                    builder: (context) => CustomAboutDialog(
                      currentTheme: _selectedTheme,
                      localizations: _localizations,
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
                        _localizations.translate('about'), // You'll need to add 'about' to your localizations
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

              // Close Button
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
            ],
          ),
        ),
      ),
    );
  }

  String _getSecondaryLanguage() {
    // Mevcut dil TR/ID ise onu göster, değilse EN göster
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
    final themeName = _selectedLanguage == 'tr' ? theme.nameTr : theme.nameEn;

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