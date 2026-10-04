import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_model.freezed.dart';

/// Lightweight per-category practice statistics, derived from the answer log.
@freezed
sealed class CategoryStat with _$CategoryStat {
  const factory CategoryStat({
    @Default(0) int answered,
    @Default(0) int correct,
    @Default(0) int mistakes,
  }) = _CategoryStat;

  const CategoryStat._();

  double get accuracy => answered == 0 ? 0 : (correct / answered) * 100;
}

/// Overall study progress shown on the home and statistics screens.
@freezed
sealed class StatsModel with _$StatsModel {
  const factory StatsModel({
    @Default(0) int totalAnswered,
    @Default(0) int totalCorrect,
    @Default(0) int totalWrong,
    @Default(0) int examsTaken,
    @Default(0) int bestExamScore,
    @Default(0) double averageExamScore,
    @Default(0) double accuracy,
    @Default(<String, CategoryStat>{}) Map<String, CategoryStat> categoryStats,
    @Default(0) int bookmarkedCount,
    @Default(0) int mistakeCount,
  }) = _StatsModel;

  const StatsModel._();
}
