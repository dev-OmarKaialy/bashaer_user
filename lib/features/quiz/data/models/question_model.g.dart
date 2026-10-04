// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) => _AnswerModel(
  id: json['id'] as String,
  text: json['text'] as String,
  isCorrect: json['isCorrect'] as bool? ?? false,
  image: json['image'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$AnswerModelToJson(_AnswerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'isCorrect': instance.isCorrect,
      'image': instance.image,
      'description': instance.description,
    };

_QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    _QuestionModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      type: questionTypeFromJson(json['type']),
      title: json['title'] as String,
      image: json['image'] as String?,
      audio: json['audio'] as String?,
      description: json['description'] as String?,
      answers: (json['answers'] as List<dynamic>)
          .map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswerIds:
          (json['correctAnswerIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      hint: json['hint'] as String?,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$QuestionModelToJson(_QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'type': questionTypeToJson(instance.type),
      'title': instance.title,
      'image': instance.image,
      'audio': instance.audio,
      'description': instance.description,
      'answers': instance.answers,
      'correctAnswerIds': instance.correctAnswerIds,
      'hint': instance.hint,
      'explanation': instance.explanation,
      'difficulty': instance.difficulty,
      'points': instance.points,
    };
