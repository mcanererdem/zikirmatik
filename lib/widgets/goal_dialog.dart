import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../utils/localizations.dart';

class GoalDialog extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final List<Goal> currentGoals;
  final Function(Goal) onGoalSet;

  const GoalDialog({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentGoals,
    required this.onGoalSet,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  String _selectedType = 'daily';
  final TextEditingController _targetController = TextEditingController();

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
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
          border: Border.all(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.localizations.setGoal,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.themeConfig.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildTargetInput(),
            const SizedBox(height: 24),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildTypeButton('daily', widget.localizations.dailyGoal),
        const SizedBox(width: 8),
        _buildTypeButton('weekly', widget.localizations.weeklyGoal),
        const SizedBox(width: 8),
        _buildTypeButton('monthly', widget.localizations.monthlyGoal),
      ],
    );
  }

  Widget _buildTypeButton(String type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? widget.themeConfig.goldGradient : null,
            color: isSelected ? null : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? widget.themeConfig.accentColor
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetInput() {
    return TextField(
      controller: _targetController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintText: widget.localizations.enterTarget,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
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
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              widget.localizations.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.themeConfig.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _saveGoal,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.localizations.save,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveGoal() {
    final target = int.tryParse(_targetController.text);
    if (target == null || target <= 0) {
      return;
    }

    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      targetCount: target,
      startDate: DateTime.now(),
    );

    widget.onGoalSet(goal);
    Navigator.pop(context);
  }
}
