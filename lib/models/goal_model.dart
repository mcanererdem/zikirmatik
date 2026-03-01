class Goal {
  final String id;
  final String type;
  final int targetCount;
  final DateTime startDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final int currentProgress;
  final String? zikrId;

  Goal({
    required this.id,
    required this.type,
    required this.targetCount,
    required this.startDate,
    this.completedDate,
    this.isCompleted = false,
    this.currentProgress = 0,
    this.zikrId,
  });

  bool isTargetReached() => currentProgress >= targetCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'targetCount': targetCount,
        'startDate': startDate.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'isCompleted': isCompleted,
        'currentProgress': currentProgress,
        'zikrId': zikrId,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        type: json['type'],
        targetCount: json['targetCount'],
        startDate: DateTime.parse(json['startDate']),
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'])
            : null,
        isCompleted: json['isCompleted'] ?? false,
        currentProgress: json['currentProgress'] ?? 0,
        zikrId: json['zikrId'],
      );

  Goal copyWith({
    String? id,
    String? type,
    int? targetCount,
    DateTime? startDate,
    DateTime? completedDate,
    bool? isCompleted,
    int? currentProgress,
    String? zikrId,
  }) =>
      Goal(
        id: id ?? this.id,
        type: type ?? this.type,
        targetCount: targetCount ?? this.targetCount,
        startDate: startDate ?? this.startDate,
        completedDate: completedDate ?? this.completedDate,
        isCompleted: isCompleted ?? this.isCompleted,
        currentProgress: currentProgress ?? this.currentProgress,
        zikrId: zikrId ?? this.zikrId,
      );

  bool isExpired() {
    final now = DateTime.now();
    switch (type) {
      case 'daily':
        return !_isSameDay(startDate, now);
      case 'weekly':
        return now.difference(startDate).inDays >= 7;
      case 'monthly':
        return now.month != startDate.month || now.year != startDate.year;
      default:
        return false;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
