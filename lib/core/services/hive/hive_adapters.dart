import 'package:hive_ce/hive.dart';

import '../../../features/quiz/data/models/category_model.dart';
import '../../../features/quiz/data/models/question_model.dart';
import '../../../features/quiz/data/models/quiz_result_model.dart';

/// Central registry of every type persisted with Hive.
///
/// Hive assigns type ids by position, and a stored object records the id of the
/// adapter that wrote it. Only ever append to this list: reordering or removing
/// a spec re-points ids at different types and makes data already on disk
/// unreadable.
@GenerateAdapters([
  AdapterSpec<CategoryModel>(),
  AdapterSpec<AnswerModel>(),
  AdapterSpec<QuestionType>(),
  AdapterSpec<QuestionModel>(),
  AdapterSpec<QuizResultModel>(),
  AdapterSpec<AnswerLogEntry>(),
])
part 'hive_adapters.g.dart';
