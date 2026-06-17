import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';
import '../models/zikr_model.dart';

class ZikrSelectionDialog extends StatelessWidget {
  final List<ZikrModel> defaultZikrs;
  final List<ZikrModel> customZikrs;
  final ZikrModel? selectedZikr;
  final String currentLanguage; // YENİ
  final Function(ZikrModel) onZikrSelected;
  final Function(ZikrModel) onEditZikr;
  final VoidCallback onAddCustomZikr;
  final Function(ZikrModel) onDeleteZikr;
  final Map<String, int> zikrTargets;
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const ZikrSelectionDialog({
    super.key,
    required this.defaultZikrs,
    required this.customZikrs,
    required this.selectedZikr,
    required this.currentLanguage,
    required this.onZikrSelected,
    required this.onEditZikr,
    required this.onAddCustomZikr,
    required this.onDeleteZikr,
    required this.zikrTargets,
    required this.themeConfig,
    required this.localizations,
  });

  // YENİ: Dile göre zikir adını getir
  String _getZikrName(ZikrModel zikr) {
    return zikr.getNameForLanguage(currentLanguage);
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
                  DynamicLocalizationHelper.getText({
                    'tr': 'Zikir Seç',
                    'en': 'Select Dhikr',
                    'ar': 'اختر الذكر',
                  }),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: themeConfig.textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Zikr List
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: defaultZikrs.length + (customZikrs.isNotEmpty ? customZikrs.length + 1 : 0),
                itemBuilder: (context, index) {
                  if (index < defaultZikrs.length) {
                    return _buildZikrItem(context, defaultZikrs[index], false);
                  }
                  final customIndex = index - defaultZikrs.length;
                  if (customIndex == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          DynamicLocalizationHelper.getText({
                            'tr': 'Özel Zikirler',
                            'en': 'Custom Dhikrs',
                            'ar': 'أذكار مخصصة',
                          }),
                          style: TextStyle(
                            fontSize: 14,
                            color: themeConfig.accentColor.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  }
                  return _buildZikrItem(context, customZikrs[customIndex - 1], true);
                },
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
    final currentTarget = zikrTargets[zikr.id] ?? zikr.defaultCount;

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
                color: isSelected ? null : themeConfig.textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? themeConfig.accentColor
                      : themeConfig.textColor.withOpacity(0.2),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeConfig.textColor,
                          ),
                          textDirection: currentLanguage == 'ar' 
                            ? TextDirection.rtl 
                            : TextDirection.ltr,
                        ),
                        
                        // İkincil dil - küçük gösterim (sadece Türkçe ve İngilizce için)
                        if (currentLanguage != 'ar') ...[
                          const SizedBox(height: 4),
                          Text(
                            zikr.getNameForLanguage('ar'),
                            style: TextStyle(
                              fontSize: 14,
                              color: themeConfig.textColor.withOpacity(0.7),
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
                      color: themeConfig.textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$currentTarget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeConfig.textColor,
                      ),
                    ),
                  ),
                  // Sağ aksiyon alanı için boşluk bırak
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onEditZikr(zikr);
                    },
                    child: Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: themeConfig.accentColor.withOpacity(0.85),
                        borderRadius: BorderRadius.only(
                          topRight: const Radius.circular(12),
                          bottomRight: canDelete ? Radius.zero : const Radius.circular(12),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (canDelete)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onDeleteZikr(zikr);
                      },
                      child: Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD64A4A),
                          borderRadius: BorderRadius.only(
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
                  DynamicLocalizationHelper.getText({
                    'tr': 'Zikir Ekle',
                    'en': 'Add Dhikr',
                    'ar': 'إضافة ذكر',
                  }),
                  style: TextStyle(
                    color: themeConfig.textColor,
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
