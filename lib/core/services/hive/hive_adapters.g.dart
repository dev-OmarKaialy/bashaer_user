// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final typeId = 0;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String?,
      description: fields[3] as String?,
      questionCount: fields[4] == null ? 0 : (fields[4] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.questionCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnswerModelAdapter extends TypeAdapter<AnswerModel> {
  @override
  final typeId = 1;

  @override
  AnswerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnswerModel(
      id: fields[0] as String,
      text: fields[1] as String,
      isCorrect: fields[2] == null ? false : fields[2] as bool,
      image: fields[3] as String?,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AnswerModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isCorrect)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionTypeAdapter extends TypeAdapter<QuestionType> {
  @override
  final typeId = 2;

  @override
  QuestionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return QuestionType.singleChoice;
      case 1:
        return QuestionType.multipleChoice;
      case 2:
        return QuestionType.trueFalse;
      default:
        return QuestionType.singleChoice;
    }
  }

  @override
  void write(BinaryWriter writer, QuestionType obj) {
    switch (obj) {
      case QuestionType.singleChoice:
        writer.writeByte(0);
      case QuestionType.multipleChoice:
        writer.writeByte(1);
      case QuestionType.trueFalse:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final typeId = 3;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionModel(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      type: fields[2] as QuestionType,
      title: fields[3] as String,
      image: fields[11] as String?,
      audio: fields[12] as String?,
      description: fields[4] as String?,
      answers: (fields[5] as List).cast<AnswerModel>(),
      correctAnswerIds: fields[6] == null
          ? []
          : (fields[6] as List).cast<String>(),
      hint: fields[7] as String?,
      explanation: fields[8] as String?,
      difficulty: fields[9] as String?,
      points: fields[10] == null ? 1 : (fields[10] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.answers)
      ..writeByte(6)
      ..write(obj.correctAnswerIds)
      ..writeByte(7)
      ..write(obj.hint)
      ..writeByte(8)
      ..write(obj.explanation)
      ..writeByte(9)
      ..write(obj.difficulty)
      ..writeByte(10)
      ..write(obj.points)
      ..writeByte(11)
      ..write(obj.image)
      ..writeByte(12)
      ..write(obj.audio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizResultModelAdapter extends TypeAdapter<QuizResultModel> {
  @override
  final typeId = 4;

  @override
  QuizResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizResultModel(
      id: fields[0] as String,
      examTitle: fields[1] as String,
      dateTime: (fields[2] as num).toInt(),
      totalQuestions: (fields[3] as num).toInt(),
      answered: (fields[4] as num).toInt(),
      correct: (fields[5] as num).toInt(),
      wrong: (fields[6] as num).toInt(),
      unanswered: (fields[7] as num).toInt(),
      totalTimeSeconds: (fields[8] as num).toInt(),
      timeUsedSeconds: (fields[9] as num).toInt(),
      passingScore: fields[10] == null ? 0 : (fields[10] as num).toInt(),
      passed: fields[11] == null ? false : fields[11] as bool,
      correctByCategory: fields[12] == null
          ? {}
          : (fields[12] as Map).cast<String, int>(),
      totalByCategory: fields[13] == null
          ? {}
          : (fields[13] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizResultModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.examTitle)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.totalQuestions)
      ..writeByte(4)
      ..write(obj.answered)
      ..writeByte(5)
      ..write(obj.correct)
      ..writeByte(6)
      ..write(obj.wrong)
      ..writeByte(7)
      ..write(obj.unanswered)
      ..writeByte(8)
      ..write(obj.totalTimeSeconds)
      ..writeByte(9)
      ..write(obj.timeUsedSeconds)
      ..writeByte(10)
      ..write(obj.passingScore)
      ..writeByte(11)
      ..write(obj.passed)
      ..writeByte(12)
      ..write(obj.correctByCategory)
      ..writeByte(13)
      ..write(obj.totalByCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnswerLogEntryAdapter extends TypeAdapter<AnswerLogEntry> {
  @override
  final typeId = 5;

  @override
  AnswerLogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnswerLogEntry(
      questionId: fields[0] as String,
      correct: fields[1] as bool,
      dateTime: (fields[2] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AnswerLogEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.correct)
      ..writeByte(2)
      ..write(obj.dateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnswerLogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
