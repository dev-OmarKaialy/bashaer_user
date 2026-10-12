// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryRoundResult _$CategoryRoundResultFromJson(Map<String, dynamic> json) =>
    _CategoryRoundResult(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      correctAttempts: (json['correctAttempts'] as num).toInt(),
      totalAttempts: (json['totalAttempts'] as num).toInt(),
    );

Map<String, dynamic> _$CategoryRoundResultToJson(_CategoryRoundResult instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'correctAttempts': instance.correctAttempts,
      'totalAttempts': instance.totalAttempts,
    };

_TrainingSessionModel _$TrainingSessionModelFromJson(Map<String, dynamic> json) =>
    _TrainingSessionModel(
      id: json['id'] as String,
      startedAt: (json['startedAt'] as num).toInt(),
      endedAt: (json['endedAt'] as num?)?.toInt(),
      status:
          $enumDecodeNullable(_$TrainingSessionStatusEnumMap, json['status']) ??
          TrainingSessionStatus.active,
      categoryIds:
          (json['categoryIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      currentCategoryIndex: (json['currentCategoryIndex'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      currentCorrectAttempts: (json['currentCorrectAttempts'] as num?)?.toInt() ?? 0,
      currentTotalAttempts: (json['currentTotalAttempts'] as num?)?.toInt() ?? 0,
      solvedQuestionIds:
          (json['solvedQuestionIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      categoryResults:
          (json['categoryResults'] as List<dynamic>?)
              ?.map((e) => CategoryRoundResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CategoryRoundResult>[],
    );

Map<String, dynamic> _$TrainingSessionModelToJson(_TrainingSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt,
      'endedAt': instance.endedAt,
      'status': _$TrainingSessionStatusEnumMap[instance.status]!,
      'categoryIds': instance.categoryIds,
      'currentCategoryIndex': instance.currentCategoryIndex,
      'points': instance.points,
      'currentCorrectAttempts': instance.currentCorrectAttempts,
      'currentTotalAttempts': instance.currentTotalAttempts,
      'solvedQuestionIds': instance.solvedQuestionIds,
      'categoryResults': instance.categoryResults,
    };

const _$TrainingSessionStatusEnumMap = {
  TrainingSessionStatus.active: 'active',
  TrainingSessionStatus.completed: 'completed',
  TrainingSessionStatus.stopped: 'stopped',
};
