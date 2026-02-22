import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/theme_model.dart';
import '../utils/localizations.dart';

class SuccessDialog extends StatelessWidget {
  final int count;
  final VoidCallback onContinue;
  final VoidCallback onReset;
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const SuccessDialog({
    super.key,
    required this.count,
    required this.onContinue,
    required this.onReset,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeConfig.textColor.withValues(alpha: 0.08),
          image: (() {
            final isLightTheme = themeConfig.textColor.computeLuminance() < 0.5;
            final asset = isLightTheme ? themeConfig.lightBackgroundAsset : themeConfig.darkBackgroundAsset;
            return asset != null
                ? DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  )
                : null;
          })(),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: themeConfig.accentColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: themeConfig.accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: themeConfig.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: themeConfig.accentColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: 48,
                color: themeConfig.textColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              localizations.successTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeConfig.accentColor,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              localizations.successMessage,
              style: TextStyle(
                fontSize: 18,
                color: themeConfig.textColor.withValues(alpha: 0.9),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: themeConfig.textColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count ${localizations.zikrCount}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeConfig.accentColor.withValues(alpha: 0.9),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: _buildButton(
                    context: context,
                    label: localizations.reset,
                    icon: Icons.refresh_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        onReset();
                      });
                    },
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    context: context,
                    label: localizations.continueText,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        onContinue();
                      });
                    },
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
      decoration: BoxDecoration(
        gradient: isPrimary ? themeConfig.goldGradient : themeConfig.buttonGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isPrimary ? themeConfig.accentColor : themeConfig.primaryColor).withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: themeConfig.textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: themeConfig.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
