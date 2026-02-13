import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

class AddZikrDialog extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final String currentLanguage; // YENİ
  final Function(ZikrModel) onZikrAdded;

  const AddZikrDialog({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentLanguage,
    required this.onZikrAdded,
  });

  @override
  State<AddZikrDialog> createState() => _AddZikrDialogState();
}

class _AddZikrDialogState extends State<AddZikrDialog> {
  final _nameArController = TextEditingController();
  final _nameTrController = TextEditingController();
  final _nameEnController = TextEditingController();
  final _countController = TextEditingController(text: '100');

  @override
  void dispose() {
    _nameArController.dispose();
    _nameTrController.dispose();
    _nameEnController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _saveZikr() {
    // Ana dil kontrolü - seçili dilde mutlaka doldurulmalı
    TextEditingController primaryController;
    String primaryFieldName;
    
    switch (widget.currentLanguage) {
      case 'ar':
        primaryController = _nameArController;
        primaryFieldName = widget.localizations.zikrNameAr;
        break;
      case 'en':
        primaryController = _nameEnController;
        primaryFieldName = widget.localizations.zikrNameEn;
        break;
      default:
        primaryController = _nameTrController;
        primaryFieldName = widget.localizations.zikrNameTr;
    }

    if (primaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.currentLanguage == 'tr'
                ? '$primaryFieldName alanını doldurun'
                : widget.currentLanguage == 'en'
                    ? 'Fill in the $primaryFieldName field'
                    : 'املأ حقل $primaryFieldName',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final count = int.tryParse(_countController.text) ?? 100;

    // Doldurulmayan dilleri ana dilden kopyala
    final nameAr = _nameArController.text.trim().isEmpty 
        ? primaryController.text.trim() 
        : _nameArController.text.trim();
    
    final nameTr = _nameTrController.text.trim().isEmpty 
        ? primaryController.text.trim() 
        : _nameTrController.text.trim();
    
    final nameEn = _nameEnController.text.trim().isEmpty 
        ? primaryController.text.trim() 
        : _nameEnController.text.trim();

    final newZikr = ZikrModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nameAr: nameAr,
      nameTr: nameTr,
      nameEn: nameEn,
      defaultCount: count,
    );

    widget.onZikrAdded(newZikr);
    Navigator.pop(context);
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
              color: widget.themeConfig.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
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
                  Text(
                    widget.localizations.addZikr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // DİLE GÖRE SADECE İLGİLİ ALAN GÖSTERİLİR
              
              // Ana Dil Alanı (Seçili dile göre)
              if (widget.currentLanguage == 'ar')
                _buildTextField(
                  controller: _nameArController,
                  label: '${widget.localizations.zikrNameAr} *',
                  hint: 'سُبْحَانَ اللّٰهِ',
                  textDirection: TextDirection.rtl,
                  isPrimary: true,
                ),
              
              if (widget.currentLanguage == 'tr')
                _buildTextField(
                  controller: _nameTrController,
                  label: '${widget.localizations.zikrNameTr} *',
                  hint: 'Sübhanallah',
                  isPrimary: true,
                ),
              
              if (widget.currentLanguage == 'en')
                _buildTextField(
                  controller: _nameEnController,
                  label: '${widget.localizations.zikrNameEn} *',
                  hint: 'Subhanallah',
                  isPrimary: true,
                ),

              const SizedBox(height: 16),

              // Opsiyonel: Diğer diller (接katlanabilir)
              ExpansionTile(
                title: Text(
                  widget.currentLanguage == 'tr'
                      ? 'Diğer Diller (Opsiyonel)'
                      : widget.currentLanguage == 'en'
                          ? 'Other Languages (Optional)'
                          : 'لغات أخرى (اختياري)',
                  style: TextStyle(
                    color: widget.themeConfig.accentColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: Colors.white,
                collapsedIconColor: Colors.white70,
                children: [
                  const SizedBox(height: 8),
                  
                  // Arapça (ana dil değilse)
                  if (widget.currentLanguage != 'ar') ...[
                    _buildTextField(
                      controller: _nameArController,
                      label: widget.localizations.zikrNameAr,
                      hint: 'سُبْحَانَ اللّٰهِ',
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Türkçe (ana dil değilse)
                  if (widget.currentLanguage != 'tr') ...[
                    _buildTextField(
                      controller: _nameTrController,
                      label: widget.localizations.zikrNameTr,
                      hint: 'Sübhanallah',
                    ),
                    const SizedBox(height: 16),
                  ],

                  // İngilizce (ana dil değilse)
                  if (widget.currentLanguage != 'en') ...[
                    _buildTextField(
                      controller: _nameEnController,
                      label: widget.localizations.zikrNameEn,
                      hint: 'Subhanallah',
                    ),
                  ],
                ],
              ),

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
    bool isPrimary = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isPrimary 
                ? widget.themeConfig.accentColor 
                : widget.themeConfig.accentColor.withOpacity(0.6),
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary
                  ? widget.themeConfig.accentColor.withOpacity(0.5)
                  : widget.themeConfig.accentColor.withOpacity(0.3),
              width: isPrimary ? 2 : 1,
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
                color: Colors.white.withOpacity(0.5),
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
        color: isPrimary ? null : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: widget.themeConfig.accentColor.withOpacity(0.3),
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