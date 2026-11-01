import 'package:hive/hive.dart';
part 'daily_usage_model.g.dart';

@HiveType(typeId: 4)
class DailyUsageModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int requestCount;

  @HiveField(2)
  final int dailyCap;

  DailyUsageModel({
    required this.date, 
    required this.requestCount, 
    this.dailyCap = 1000
    });

    DailyUsageModel copyWith({
      DateTime? date,
      int? requestCount,
      int? dailyCap,
    }) {
      return DailyUsageModel(
        date: date ?? this.date,
        requestCount: requestCount ?? this.requestCount,
        dailyCap: dailyCap ?? this.dailyCap,
      );
    }
}