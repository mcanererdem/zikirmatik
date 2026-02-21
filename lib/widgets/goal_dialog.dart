import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../models/goal_model.dart';
import '../models/zikr_model.dart';
import '../utils/localizations.dart';

class GoalDialog extends StatefulWidget {
  final ThemeConfig themeConfig;
  final AppLocalizations localizations;
  final List<Goal> currentGoals;
  final Function(Goal) onGoalSet;
  final List<ZikrModel> availableZikrs;
  final String currentLanguage;

  const GoalDialog({
    super.key,
    required this.themeConfig,
    required this.localizations,
    required this.currentGoals,
    required this.onGoalSet,
    required this.availableZikrs,
    required this.currentLanguage,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  String _selectedType = 'daily';
  final TextEditingController _targetController = TextEditingController();
  ZikrModel? _selectedZikr;

  @override
  void initState() {
    super.initState();
    _selectedZikr = widget.availableZikrs.isNotEmpty ? widget.availableZikrs[0] : null;
    _loadExistingGoal();
  }

  void _loadExistingGoal() {
    final existingGoal = widget.currentGoals.firstWhere(
      (g) => g.type == _selectedType && !g.isCompleted && !g.isExpired(),
      orElse: () => Goal(id: '', type: '', targetCount: 0, startDate: DateTime.now()),
    );
    if (existingGoal.id.isNotEmpty) {
      _targetController.text = existingGoal.targetCount.toString();
      if (existingGoal.zikrId != null) {
        _selectedZikr = widget.availableZikrs.firstWhere(
          (z) => z.id == existingGoal.zikrId,
          orElse: () => widget.availableZikrs[0],
        );
      }
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeGoals = widget.currentGoals
        .where((g) => !g.isCompleted && !g.isExpired())
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (activeGoals.isNotEmpty)
                ...activeGoals.map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildGoalCard(goal),
                )),
              if (activeGoals.isNotEmpty) const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildZikrSelector(),
              const SizedBox(height: 16),
              _buildTargetInput(),
              const SizedBox(height: 24),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    final zikr = widget.availableZikrs.firstWhere(
      (z) => z.id == goal.zikrId,
      orElse: () => widget.availableZikrs[0],
    );
    final zikrName = _getZikrName(zikr);
    final typeLabel = goal.type == 'daily'
        ? widget.localizations.dailyGoal
        : goal.type == 'weekly'
            ? widget.localizations.weeklyGoal
            : widget.localizations.monthlyGoal;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.themeConfig.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: widget.themeConfig.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  zikrName,
                  style: TextStyle(
                    color: widget.themeConfig.textColor.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${goal.currentProgress}/${goal.targetCount}',
            style: TextStyle(
              color: widget.themeConfig.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingGoalInfo(Goal goal) {
    final zikr = widget.availableZikrs.firstWhere(
      (z) => z.id == goal.zikrId,
      orElse: () => widget.availableZikrs[0],
    );
    final zikrName = _getZikrName(zikr);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.themeConfig.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${widget.localizations.progress}: ${goal.currentProgress}/${goal.targetCount}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            zikrName,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
        ],
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
        onTap: () {
          setState(() {
            _selectedType = type;
            _loadExistingGoal();
          });
        },
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

  Widget _buildZikrSelector() {
    return DropdownButtonFormField<ZikrModel>(
      value: _selectedZikr,
      dropdownColor: widget.themeConfig.primaryColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.themeConfig.textColor.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.themeConfig.accentColor.withOpacity(0.3),
          ),
        ),
      ),
      items: widget.availableZikrs.map((zikr) {
        return DropdownMenuItem(
          value: zikr,
          child: Text(
            _getZikrName(zikr),
            style: TextStyle(color: widget.themeConfig.textColor),
          ),
        );
      }).toList(),
      onChanged: (zikr) => setState(() => _selectedZikr = zikr),
    );
  }

  String _getZikrName(ZikrModel zikr) {
    switch (widget.currentLanguage) {
      case 'ar':
        return zikr.nameAr;
      case 'en':
        return zikr.nameEn;
      case 'id':
        return zikr.nameEn;
      default:
        return zikr.nameTr;
    }
  }

  Widget _buildTargetInput() {
    return TextField(
      controller: _targetController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      style: TextStyle(color: widget.themeConfig.textColor, fontSize: 18),
      decoration: InputDecoration(
        hintText: widget.localizations.enterTarget,
        hintStyle: TextStyle(color: widget.themeConfig.textColor.withOpacity(0.5)),
        filled: true,
        fillColor: widget.themeConfig.textColor.withOpacity(0.1),
        counterText: '',
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
              style: TextStyle(color: widget.themeConfig.textColor.withOpacity(0.7)),
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
                    style: TextStyle(
                      color: widget.themeConfig.textColor,
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
    if (target == null || target <= 0 || _selectedZikr == null) {
      return;
    }

    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      targetCount: target,
      startDate: DateTime.now(),
      zikrId: _selectedZikr!.id,
    );

    widget.onGoalSet(goal);
    Navigator.pop(context);
  }
}
