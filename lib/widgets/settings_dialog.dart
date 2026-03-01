import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/settings_service.dart';

class SettingsDialog extends StatefulWidget {
  final ThemeConfig theme;
  final AppLocalizations localizations;

  const SettingsDialog({
    super.key,
    required this.theme,
    required this.localizations,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late ThemeConfig _selectedTheme;
  late AppLocalizations _localizations;
  bool _isVibrationOn = true;
  bool _isSoundOn = true;
  bool _isConfettiOn = true;
  bool _isReminderEnabled = false;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.theme;
    _localizations = widget.localizations;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final vibration = await _settingsService.getVibration();
    final sound = await _settingsService.getSound();
    final confetti = await _settingsService.getConfetti();
    final reminderEnabled = await _settingsService.getReminderEnabled();
    
    if (mounted) {
      setState(() {
        _isVibrationOn = vibration;
        _isSoundOn = sound;
        _isConfettiOn = confetti;
        _isReminderEnabled = reminderEnabled;
      });
    }
  }

  Widget _buildThemeOption(ThemeConfig theme) {
    final isSelected = _selectedTheme.id == theme.id;
    
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _selectedTheme = theme;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected ? theme.goldGradient : null,
          color: isSelected ? null : theme.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : theme.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: theme.buttonGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                theme.nameTr,
                style: TextStyle(
                  color: isSelected ? Colors.white : theme.textColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _selectedTheme.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedTheme.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: _selectedTheme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _selectedTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _selectedTheme.textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _selectedTheme.accentColor,
          ),
        ],
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _selectedTheme.textColor,
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
                'Ayarlar',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTheme.accentColor.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildToggleOption(
                title: 'Titreşim',
                subtitle: 'Titreşim bildirimleri',
                icon: Icons.vibration,
                value: _isVibrationOn,
                onChanged: (value) async {
                  await _settingsService.saveVibration(value);
                  if (mounted) {
                    setState(() => _isVibrationOn = value);
                  }
                },
              ),
              _buildToggleOption(
                title: 'Ses',
                subtitle: 'Ses efektleri',
                icon: Icons.volume_up,
                value: _isSoundOn,
                onChanged: (value) async {
                  await _settingsService.saveSound(value);
                  if (mounted) {
                    setState(() => _isSoundOn = value);
                  }
                },
              ),
              _buildToggleOption(
                title: 'Konfeti',
                subtitle: 'Konfeti animasyonları',
                icon: Icons.celebration,
                value: _isConfettiOn,
                onChanged: (value) async {
                  await _settingsService.saveConfetti(value);
                  if (mounted) {
                    setState(() => _isConfettiOn = value);
                  }
                },
              ),
              _buildToggleOption(
                title: 'Bildirimler',
                subtitle: 'Bildirim hatırlatıcıları',
                icon: Icons.notifications,
                value: _isReminderEnabled,
                onChanged: (value) async {
                  await _settingsService.saveReminderEnabled(value);
                  if (mounted) {
                    setState(() => _isReminderEnabled = value);
                  }
                },
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
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Tamam',
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
}
