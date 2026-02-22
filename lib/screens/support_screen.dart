import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../services/ad_service.dart';

class SupportScreen extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const SupportScreen({
    super.key,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final AdService _adService = AdService();
  bool _isLoading = false;

  void _watchAd() {
    setState(() => _isLoading = true);
    _adService.loadRewardedAd(
      onAdLoaded: () {
        setState(() => _isLoading = false);
        _adService.showRewardedAd(
          onUserEarnedReward: () {
            _showThankYou();
          },
          onAdDismissed: () {},
        );
      },
      onAdFailedToLoad: (_) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.localizations.translate('ad_not_ready') ?? 'Ad is not ready yet.'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );
  }

  void _showThankYou() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: widget.themeConfig.backgroundGradient,
                image: (() {
                  final isLightTheme = widget.themeConfig.textColor.computeLuminance() < 0.5;
                  final asset = isLightTheme ? widget.themeConfig.lightBackgroundAsset : widget.themeConfig.darkBackgroundAsset;
                  return asset != null
                      ? DecorationImage(
                          image: AssetImage(asset),
                          fit: BoxFit.cover,
                          opacity: 0.12,
                        )
                      : null;
                })(),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: widget.themeConfig.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_rounded, color: widget.themeConfig.textColor, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.localizations.translate('thank_you_support') ?? 'Thank you for your support! 🙏',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.themeConfig.accentColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.localizations.translate('support_description') ?? 'Your support keeps this app free.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: widget.themeConfig.textColor.withValues(alpha: 0.85)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: widget.themeConfig.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Semantics(
                        button: true,
                        label: widget.localizations.translate('ok') ?? 'OK',
                        child: InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'OK',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: widget.themeConfig.textColor, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          image: (() {
            final isLightTheme = widget.themeConfig.textColor.computeLuminance() < 0.5;
            final asset = isLightTheme ? widget.themeConfig.lightBackgroundAsset : widget.themeConfig.darkBackgroundAsset;
            return asset != null
                ? DecorationImage(
                    image: AssetImage(asset),
                    fit: BoxFit.cover,
                    opacity: 0.12,
                  )
                : null;
          })(),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: widget.themeConfig.textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.localizations.translate('support_us') ?? 'Support Us',
                      style: TextStyle(color: widget.themeConfig.textColor, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.themeConfig.textColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.localizations.translate('support_description') ?? 'Help us by watching a short ad',
                        style: TextStyle(color: widget.themeConfig.textColor, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: widget.themeConfig.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _watchAd,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(widget.themeConfig.textColor),
                                      ),
                                    )
                                  else
                                    Icon(Icons.play_circle_fill_rounded, color: widget.themeConfig.textColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.localizations.translate('watch_ad') ?? 'Watch Ad',
                                    style: TextStyle(color: widget.themeConfig.textColor, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
