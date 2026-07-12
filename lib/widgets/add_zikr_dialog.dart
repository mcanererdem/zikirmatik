import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';
import '../utils/dynamic_localization_helper.dart';

class AddZikrDialog extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final Function(ZikrModel) onZikrAdded;
  final String currentLanguage;

  const AddZikrDialog({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.onZikrAdded,
    required this.currentLanguage,
  });

  @override
  State<AddZikrDialog> createState() => _AddZikrDialogState();
}

class _AddZikrDialogState extends State<AddZikrDialog> {
  static const int _maxZikrCount = 100000;
  static const int _maxTextLength = 80;
  final _primaryController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _countController = TextEditingController(text: '33');

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    _countController.dispose();
    super.dispose();
  }

  String get _primaryLabel {
    switch (widget.currentLanguage) {
      case 'ar':
        return widget.localizations.zikrNameAr;
      case 'en':
        return widget.localizations.zikrNameEn;
      case 'tr':
      case 'id':
      case 'ur':
      case 'bn':
      case 'ms':
      case 'fa':
      case 'fr':
      case 'zh':
      case 'ja':
      case 'ru':
      case 'de':
      case 'sw':
      case 'ha':
        return widget.localizations.translate('zikr_name_${widget.currentLanguage}');
      default:
        return widget.localizations.zikrNameTr;
    }
  }

  String get _secondaryLabel {
    if (widget.currentLanguage == 'ar') {
      return '${widget.localizations.translate('transliteration')} (${widget.localizations.translate('optional')})';
    }
    return '${widget.localizations.zikrNameAr} (${widget.localizations.translate('optional')})';
  }

  String get _primaryHint {
    switch (widget.currentLanguage) {
      case 'ar':
        return 'سُبْحَانَ اللّٰهِ';
      case 'en':
        return 'Glory be to Allah';
      case 'tr':
        return 'Sübhanallah';
      case 'id':
        return 'Subhanallah';
      case 'ur':
        return 'سبحان اللہ';
      case 'bn':
        return 'সুবহানাল্লাহ';
      case 'ms':
        return 'Subhanallah';
      case 'fa':
        return 'سبحان الله';
      case 'fr':
        return 'Gloire à Allah';
      case 'zh':
        return '赞美真主';
      case 'ja':
        return 'アッラーに栄光あれ';
      case 'ru':
        return 'Слава Аллаху';
      case 'de':
        return 'Ehre sei Allah';
      case 'sw':
        return 'Subhanallah';
      case 'ha':
        return 'Subhanallah';
      default:
        return 'Sübhanallah';
    }
  }

  String get _secondaryHint {
    if (widget.currentLanguage == 'ar') {
      return 'Subhanallah';
    }
    return 'سُبْحَانَ اللّٰهِ';
  }

  void _saveZikr() {
    final primaryText = _primaryController.text.trim();
    final secondaryText = _secondaryController.text.trim();

    if (primaryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            DynamicLocalizationHelper.getText({
              'tr': '$_primaryLabel gerekli',
              'en': '$_primaryLabel is required',
              'ar': '$_primaryLabel مطلوب',
              'id': '$_primaryLabel wajib diisi',
              'ur': '$_primaryLabel ضروری ہے',
              'bn': '$_primaryLabel আবশ্যক',
              'ms': '$_primaryLabel diperlukan',
              'fa': '$_primaryLabel الزامی است',
              'fr': '$_primaryLabel est requis',
              'zh': '$_primaryLabel 为必填项',
              'ja': '$_primaryLabel は必須です',
              'ru': '$_primaryLabel обязательно',
              'de': '$_primaryLabel ist erforderlich',
              'sw': '$_primaryLabel inahitajika',
              'ha': '$_primaryLabel ana bukata',
            }),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidZikrText(primaryText)) {
      _showValidationError(widget.localizations.translate('zikr_text_invalid'));
      return;
    }

    if (secondaryText.isNotEmpty && !_isValidZikrText(secondaryText)) {
      _showValidationError(widget.localizations.translate('zikr_secondary_invalid'));
      return;
    }

    final count = int.tryParse(_countController.text);
    if (count == null || count <= 0 || count > _maxZikrCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.localizations.translate('zikr_count_range_error'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String nameAr, nameTr, nameEn;
    
    if (widget.currentLanguage == 'ar') {
      nameAr = primaryText;
      nameTr = secondaryText.isEmpty ? primaryText : secondaryText;
      nameEn = secondaryText.isEmpty ? primaryText : secondaryText;
    } else if (widget.currentLanguage == 'en') {
      nameEn = primaryText;
      nameAr = secondaryText.isEmpty ? primaryText : secondaryText;
      nameTr = primaryText;
    } else {
      nameTr = primaryText;
      nameAr = secondaryText.isEmpty ? primaryText : secondaryText;
      nameEn = primaryText;
    }

    final newZikr = ZikrModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameAr: nameAr,
      nameTr: nameTr,
      nameEn: nameEn,
      localizedNames: {
        widget.currentLanguage: primaryText,
        'ar': nameAr,
      },
      defaultCount: count,
      isCustom: true,
      isEditable: true,
    );

    widget.onZikrAdded(newZikr);
    Navigator.pop(context);
  }

  bool _isValidZikrText(String text) {
    if (text.length < 2 || text.length > _maxTextLength) return false;
    // Allow multilingual letters while blocking common unsafe/scripting symbols.
    final safePattern = RegExp(r"^[^<>[\]{};`|\\$%]+$");
    return safePattern.hasMatch(text);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: widget.themeConfig.primaryColor.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
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
                      gradient: widget.themeConfig.goldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.localizations.addZikr,
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

              // Primary Field (Required - based on language)
              _buildTextField(
                controller: _primaryController,
                label: '$_primaryLabel *',
                hint: _primaryHint,
                textDirection: widget.currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
              ),

              if (widget.currentLanguage != 'ar') ...[
                const SizedBox(height: 16),
                // Secondary Field (Optional - Arabic or Transliteration)
                _buildTextField(
                  controller: _secondaryController,
                  label: _secondaryLabel,
                  hint: _secondaryHint,
                  textDirection: TextDirection.rtl,
                ),
              ],

              const SizedBox(height: 16),

              // Default Count
              _buildTextField(
                controller: _countController,
                label: widget.localizations.defaultCount,
                hint: '100',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: widget.localizations.cancel,
                      onPressed: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: widget.localizations.save,
                      onPressed: _saveZikr,
                      isPrimary: true,
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
    TextDirection textDirection = TextDirection.ltr,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: widget.themeConfig.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.themeConfig.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textDirection: textDirection,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
              hintTextDirection: textDirection,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary ? widget.themeConfig.goldGradient : null,
        color: isPrimary ? null : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: widget.themeConfig.accentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}