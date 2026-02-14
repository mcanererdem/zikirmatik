class StatisticsModel {
  final DateTime date;
  final int count;

  StatisticsModel({
    required this.date,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'count': count,
    };
  }

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      date: DateTime.parse(json['date']),
      count: json['count'],
    );
  }
}
