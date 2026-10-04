import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/extensions/log_colors_extension.dart';
import '../../../../core/unified_api/error/error_handeler.dart';
import '../../../../core/unified_api/error/failure.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';

/// Reads the question bank from Cloud Firestore.
///
/// Uses the Firestore SDK directly (not the REST API). Called only during
/// app-start sync — a single `get()` per collection is enough for the bundled
/// bank (8 categories, ~83 questions).
abstract class QuizRemoteDatasource {
  Future<List<CategoryModel>> getCategories();

  Future<List<QuestionModel>> getQuestions();
}

@Injectable(as: QuizRemoteDatasource)
class QuizRemoteDatasourceImpl implements QuizRemoteDatasource {
  QuizRemoteDatasourceImpl();

  static const _categoriesCollection = 'categories';

  static const _questionsCollection = 'questions';

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(_categoriesCollection)
          .orderBy('order')
          .get();
      return snapshot.docs.map((doc) => _categoryFrom(doc.data())).toList();
    } on FirebaseException catch (e) {
      log('Firestore categories fetch failed: ${e.message}'.logRed);
      throw ServerFailure(
        message: _previewMessage(e) ?? 'Firestore categories fetch failed',
        statusCode: ResponseCode.DEFAULT,
      );
    }
  }

  @override
  Future<List<QuestionModel>> getQuestions() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection(_questionsCollection).get();
      final questions = snapshot.docs.map((doc) => _questionFrom(doc.data())).toList();
      questions.sort((a, b) => a.id.compareTo(b.id));
      return questions;
    } on FirebaseException catch (e) {
      log('Firestore questions fetch failed: ${e.message}'.logRed);
      throw ServerFailure(
        message: _previewMessage(e) ?? 'Firestore questions fetch failed',
        statusCode: ResponseCode.DEFAULT,
      );
    }
  }

  String? _previewMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore read denied — check the security rules.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Firestore is temporarily unavailable — check network and retry.';
      default:
        final message = error.message;
        return message == null || message.isEmpty ? null : message;
    }
  }

  CategoryModel _categoryFrom(Map<String, dynamic> object) => CategoryModel(
    id: object['slug'] as String? ?? object['id'] as String? ?? '',
    name: object['name'] as String? ?? '',
    icon: object['icon'] as String?,
    description: object['description'] as String?,
    questionCount: (_numOf(object, 'questionCount')).toInt(),
  );

  QuestionModel _questionFrom(Map<String, dynamic> object) => QuestionModel(
    id: object['qid'] as String? ?? object['id'] as String? ?? '',
    categoryId: object['categorySlug'] as String? ?? '',
    type: questionTypeFromJson(object['type'] as String?),
    title: object['title'] as String? ?? '',
    image: _mediaUrl(object['image']),
    audio: _mediaUrl(object['audio']),
    description: object['description'] as String?,
    answers: _answersFrom(object['answers'] as List<dynamic>?),
    correctAnswerIds: _stringsFrom(object['correctAnswerIds'] as List<dynamic>?),
    hint: object['hint'] as String?,
    explanation: object['explanation'] as String?,
    difficulty: object['difficulty'] as String?,
    points: (_numOf(object, 'points', fallback: 1)).toInt(),
  );

  /// Accepts a plain URL string (firestorage.googleapis.com / HTTPS) or a
  /// legacy Parse File map `{ url, name, __type }` for decommissioned rows.
  String? _mediaUrl(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      final value = raw.trim();
      return value.isEmpty ? null : value;
    }
    if (raw is Map) {
      final url = raw['url'];
      if (url is String && url.trim().isNotEmpty) return url.trim();
    }
    return null;
  }

  List<AnswerModel> _answersFrom(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw.whereType<Map>().map((e) {
      final map = Map<String, dynamic>.from(e);
      final image = _mediaUrl(map['image']);
      if (image != null) map['image'] = image;
      return AnswerModel.fromJson(map);
    }).toList();
  }

  List<String> _stringsFrom(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  num _numOf(Map<String, dynamic> object, String key, {num fallback = 0}) {
    final value = object[key];
    if (value is num) return value;
    return fallback;
  }
}
