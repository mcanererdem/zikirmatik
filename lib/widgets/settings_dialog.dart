import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

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
    setState(() {
      _selectedLanguage = languageCode;
      _localizations = AppLocalizations(languageCode);
    });
    widget.onLanguageChanged(languageCode);
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
                    child: _buildLanguageOption('tr', _localizations.turkish),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLanguageOption('en', _localizations.english),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildLanguageOption('ar', _localizations.arabic),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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

  Widget _buildLanguageOption(String languageCode, String languageName) {
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
        child: Text(
          languageName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}