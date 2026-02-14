import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/theme_model.dart';
import '../utils/localizations.dart';

class TargetDialog extends StatefulWidget {
  final int currentTarget;
  final Function(int) onTargetChanged;
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;

  const TargetDialog({
    super.key,
    required this.currentTarget,
    required this.onTargetChanged,
    required this.themeConfig,
    required this.localizations,
  });

  @override
  State<TargetDialog> createState() => _TargetDialogState();
}

class _TargetDialogState extends State<TargetDialog> {
  late TextEditingController _controller;
  final List<int> _quickTargets = [33, 99, 100, 500, 1000];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTarget.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setTarget(int target) {
    if (target > 0 && target <= 999999) {
      widget.onTargetChanged(target);
      Navigator.pop(context);
    }
  }

  void _updateTarget(int target) {
    _controller.text = target.toString();
    setState(() {});
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: widget.themeConfig.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.localizations.setTarget,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick Targets
            Text(
              widget.localizations.quickSelect,
              style: TextStyle(
                fontSize: 14,
                color: widget.themeConfig.accentColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickTargets.map((target) {
                return _buildQuickTargetButton(target);
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Custom Input
            Text(
              widget.localizations.customTarget,
              style: TextStyle(
                fontSize: 14,
                color: widget.themeConfig.accentColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.themeConfig.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  hintText: widget.localizations.enterTarget,
                  hintStyle: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
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
                    label: widget.localizations.ok,
                    onPressed: () {
                      final value = int.tryParse(_controller.text);
                      if (value != null) {
                        _setTarget(value);
                      }
                    },
                    isPrimary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTargetButton(int target) {
    final isSelected = target.toString() == _controller.text;
    
    return InkWell(
      onTap: () => _updateTarget(target),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? widget.themeConfig.goldGradient : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? widget.themeConfig.accentColor
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          target.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
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