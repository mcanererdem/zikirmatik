import 'package:flutter/material.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

class ZikrSelectionDialog extends StatelessWidget {
  final List<ZikrModel> defaultZikrs;
  final List<ZikrModel> customZikrs;
  final ZikrModel? selectedZikr;
  final String currentLanguage; // YENİ
  final Function(ZikrModel) onZikrSelected;
  final VoidCallback onAddCustomZikr;
  final Function(ZikrModel) onDeleteZikr;
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const ZikrSelectionDialog({
    super.key,
    required this.defaultZikrs,
    required this.customZikrs,
    required this.selectedZikr,
    required this.currentLanguage,
    required this.onZikrSelected,
    required this.onAddCustomZikr,
    required this.onDeleteZikr,
    required this.themeConfig,
    required this.localizations,
  });

  // YENİ: Dile göre zikir adını getir
  String _getZikrName(ZikrModel zikr) {
    switch (currentLanguage) {
      case 'ar':
        return zikr.nameAr;
      case 'en':
        return zikr.nameEn;
      default:
        return zikr.nameTr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: themeConfig.backgroundGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: themeConfig.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: themeConfig.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
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
                    gradient: themeConfig.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.selectZikr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Zikr List
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Default Zikrs
                    ...defaultZikrs.map((zikr) => _buildZikrItem(context, zikr, false)),

                    if (customZikrs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        localizations.customZikrs,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeConfig.accentColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...customZikrs.map((zikr) => _buildZikrItem(context, zikr, true)),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Add Custom Button
            _buildAddButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildZikrItem(BuildContext context, ZikrModel zikr, bool canDelete) {
    final isSelected = selectedZikr?.id == zikr.id;
    final displayName = _getZikrName(zikr);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => onZikrSelected(zikr),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isSelected ? themeConfig.goldGradient : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? themeConfig.accentColor
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ana dil - büyük gösterim
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textDirection: currentLanguage == 'ar' 
                            ? TextDirection.rtl 
                            : TextDirection.ltr,
                        ),
                        
                        // İkincil dil - küçük gösterim (sadece Türkçe ve İngilizce için)
                        if (currentLanguage != 'ar') ...[
                          const SizedBox(height: 4),
                          Text(
                            zikr.nameAr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${zikr.defaultCount}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Silme butonu için boşluk bırak
                  if (canDelete) const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          
          // Silme butonu (sadece custom zikirler için)
          if (canDelete)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onDeleteZikr(zikr);
                },
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: themeConfig.buttonGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeConfig.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onAddCustomZikr();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  localizations.addZikr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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