import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/zikr_model.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

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
  late TextEditingController _nameArController;
  late TextEditingController _nameTrController;
  late TextEditingController _nameEnController;
  late TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _nameArController = TextEditingController(text: widget.zikr.nameAr);
    _nameTrController = TextEditingController(text: widget.zikr.nameTr);
    _nameEnController = TextEditingController(text: widget.zikr.nameEn);
    _countController = TextEditingController(text: widget.zikr.defaultCount.toString());
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameTrController.dispose();
    _nameEnController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.themeConfig.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: widget.themeConfig.backgroundGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Text(
              'Zikri Düzenle',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.themeConfig.textColor,
              ),
            ),
            const SizedBox(height: 20),
            
            // Arapça isim
            _buildTextField(
              controller: _nameArController,
              label: 'Arapça',
              hint: 'سُبْحَانَ اللّٰهِ',
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            
            // Türkçe isim
            _buildTextField(
              controller: _nameTrController,
              label: 'Türkçe',
              hint: 'Sübhanallah',
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            
            // İngilizce isim
            _buildTextField(
              controller: _nameEnController,
              label: 'İngilizce',
              hint: 'Subhanallah',
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            
            // Sayı
            _buildTextField(
              controller: _countController,
              label: 'Adet',
              hint: '33',
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // İptal
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: GoogleFonts.notoSans(
                      color: widget.themeConfig.textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Kaydet
                ElevatedButton(
                  onPressed: _saveZikr,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeConfig.accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Kaydet',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          textDirection: textDirection,
          style: GoogleFonts.notoSans(
            color: widget.themeConfig.textColor,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(
              color: widget.themeConfig.textColor.withOpacity(0.5),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.themeConfig.textColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.themeConfig.textColor.withOpacity(0.3),
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
    final nameAr = _nameArController.text.trim();
    final nameTr = _nameTrController.text.trim();
    final nameEn = _nameEnController.text.trim();
    final countText = _countController.text.trim();
    
    if (nameAr.isEmpty || nameTr.isEmpty || nameEn.isEmpty || countText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tüm alanları doldurun!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final count = int.tryParse(countText);
    if (count == null || count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geçerli bir sayı girin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final updatedZikr = widget.zikr.copyWith(
      nameAr: nameAr,
      nameTr: nameTr,
      nameEn: nameEn,
      defaultCount: count,
    );
    
    widget.onZikrUpdated(updatedZikr);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zikir başarıyla güncellendi!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
