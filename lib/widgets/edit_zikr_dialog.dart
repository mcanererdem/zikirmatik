import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

class EditZikrDialog extends StatefulWidget {
  final ZikrModel zikr;
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentLanguage;
  final Function(ZikrModel) onZikrUpdated;

  const EditZikrDialog({
    super.key,
    required this.zikr,
    required this.themeConfig,
    required this.localizations,
    required this.currentLanguage,
    required this.onZikrUpdated,
  });

  @override
  State<EditZikrDialog> createState() => _EditZikrDialogState();
}

class _EditZikrDialogState extends State<EditZikrDialog> {
  static const int _maxZikrCount = 100000;
  static const int _maxTextLength = 80;
  late TextEditingController _primaryController;
  late TextEditingController _secondaryController;
  late TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _primaryController = TextEditingController(
      text: widget.zikr.getNameForLanguage(widget.currentLanguage),
    );
    _secondaryController = TextEditingController(
      text: widget.currentLanguage == 'ar' ? '' : widget.zikr.nameAr,
    );
    _countController = TextEditingController(text: widget.zikr.defaultCount.toString());
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _countController.dispose();
    super.dispose();
  }

  String get _title => DynamicLocalizationHelper.getText({
        'tr': 'Zikri Düzenle',
        'en': 'Edit Dhikr',
        'ar': 'تعديل الذكر',
      });

  String get _primaryLabel => widget.currentLanguage == 'ar'
      ? DynamicLocalizationHelper.getText({'tr': 'Arapça', 'en': 'Arabic', 'ar': 'العربية'})
      : DynamicLocalizationHelper.getText({
          'tr': 'Okunuş / İsim',
          'en': 'Reading / Name',
          'ar': 'القراءة / الاسم',
        });

  String get _secondaryLabel => DynamicLocalizationHelper.getText({
        'tr': 'Arapça',
        'en': 'Arabic',
        'ar': 'العربية',
      });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.themeConfig.accentColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _title,
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.themeConfig.textColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _primaryController,
                label: _primaryLabel,
                hint: widget.currentLanguage == 'ar' ? 'سُبْحَانَ اللّٰهِ' : 'Subhanallah',
                textDirection: widget.currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              ),
              if (widget.currentLanguage != 'ar') ...[
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _secondaryController,
                  label: _secondaryLabel,
                  hint: 'سُبْحَانَ اللّٰهِ',
                  textDirection: TextDirection.rtl,
                ),
              ],
              const SizedBox(height: 14),
              _buildTextField(
                controller: _countController,
                label: DynamicLocalizationHelper.getText({'tr': 'Adet', 'en': 'Count', 'ar': 'العدد'}),
                hint: '33',
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        widget.localizations.cancel,
                        style: GoogleFonts.notoSans(
                          color: widget.themeConfig.textColor.withValues(alpha: 0.75),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveZikr,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeConfig.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.localizations.save,
                        style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextDirection textDirection,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textDirection: textDirection,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.themeConfig.textColor.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.themeConfig.textColor.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.themeConfig.accentColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveZikr() {
    final primary = _primaryController.text.trim();
    final secondary = _secondaryController.text.trim();
    final countText = _countController.text.trim();
    
    if (primary.isEmpty || countText.isEmpty || (widget.currentLanguage != 'ar' && secondary.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DynamicLocalizationHelper.getText({
            'tr': 'Lutfen gerekli alanlari doldurun.',
            'en': 'Please fill required fields.',
            'ar': 'يرجى ملء الحقول المطلوبة.',
          })),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidZikrText(primary) || (secondary.isNotEmpty && !_isValidZikrText(secondary))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.localizations.translate('zikr_text_invalid_short')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final count = int.tryParse(countText);
    if (count == null || count <= 0 || count > _maxZikrCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.localizations.translate('zikr_count_range_error')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String nameAr = widget.zikr.nameAr;
    String nameTr = widget.zikr.nameTr;
    String nameEn = widget.zikr.nameEn;
    if (widget.currentLanguage == 'ar') {
      nameAr = primary;
    } else if (widget.currentLanguage == 'en') {
      nameEn = primary;
      nameTr = primary;
      nameAr = secondary;
    } else {
      nameTr = primary;
      nameEn = primary;
      nameAr = secondary;
    }
    
    final updatedZikr = widget.zikr.copyWith(
      nameAr: nameAr,
      nameTr: nameTr,
      nameEn: nameEn,
      localizedNames: {
        ...widget.zikr.localizedNames,
        widget.currentLanguage: primary,
        if (widget.currentLanguage != 'ar') 'ar': secondary,
      },
      defaultCount: count,
    );
    
    widget.onZikrUpdated(updatedZikr);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(DynamicLocalizationHelper.getText({
          'tr': 'Zikir guncellendi.',
          'en': 'Dhikr updated.',
          'ar': 'تم تحديث الذكر.',
        })),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool _isValidZikrText(String text) {
    if (text.length < 2 || text.length > _maxTextLength) return false;
    final safePattern = RegExp(r"^[^<>[\]{};`|\\$%]+$");
    return safePattern.hasMatch(text);
  }
}
