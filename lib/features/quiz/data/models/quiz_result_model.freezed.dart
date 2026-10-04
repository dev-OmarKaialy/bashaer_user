// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quiz_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuizResultModel {

 String get id; String get examTitle; int get dateTime; int get totalQuestions; int get answered; int get correct; int get wrong; int get unanswered; int get totalTimeSeconds; int get timeUsedSeconds; int get passingScore; bool get passed; Map<String, int> get correctByCategory; Map<String, int> get totalByCategory;
/// Create a copy of QuizResultModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuizResultModelCopyWith<QuizResultModel> get copyWith => _$QuizResultModelCopyWithImpl<QuizResultModel>(this as QuizResultModel, _$identity);

  /// Serializes this QuizResultModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuizResultModel&&(identical(other.id, id) || other.id == id)&&(identical(other.examTitle, examTitle) || other.examTitle == examTitle)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.answered, answered) || other.answered == answered)&&(identical(other.correct, correct) || other.correct == correct)&&(identical(other.wrong, wrong) || other.wrong == wrong)&&(identical(other.unanswered, unanswered) || other.unanswered == unanswered)&&(identical(other.totalTimeSeconds, totalTimeSeconds) || other.totalTimeSeconds == totalTimeSeconds)&&(identical(other.timeUsedSeconds, timeUsedSeconds) || other.timeUsedSeconds == timeUsedSeconds)&&(identical(other.passingScore, passingScore) || other.passingScore == passingScore)&&(identical(other.passed, passed) || other.passed == passed)&&const DeepCollectionEquality().equals(other.correctByCategory, correctByCategory)&&const DeepCollectionEquality().equals(other.totalByCategory, totalByCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,examTitle,dateTime,totalQuestions,answered,correct,wrong,unanswered,totalTimeSeconds,timeUsedSeconds,passingScore,passed,const DeepCollectionEquality().hash(correctByCategory),const DeepCollectionEquality().hash(totalByCategory));

@override
String toString() {
  return 'QuizResultModel(id: $id, examTitle: $examTitle, dateTime: $dateTime, totalQuestions: $totalQuestions, answered: $answered, correct: $correct, wrong: $wrong, unanswered: $unanswered, totalTimeSeconds: $totalTimeSeconds, timeUsedSeconds: $timeUsedSeconds, passingScore: $passingScore, passed: $passed, correctByCategory: $correctByCategory, totalByCategory: $totalByCategory)';
}


}

/// @nodoc
abstract mixin class $QuizResultModelCopyWith<$Res>  {
  factory $QuizResultModelCopyWith(QuizResultModel value, $Res Function(QuizResultModel) _then) = _$QuizResultModelCopyWithImpl;
@useResult
$Res call({
 String id, String examTitle, int dateTime, int totalQuestions, int answered, int correct, int wrong, int unanswered, int totalTimeSeconds, int timeUsedSeconds, int passingScore, bool passed, Map<String, int> correctByCategory, Map<String, int> totalByCategory
});




}
/// @nodoc
class _$QuizResultModelCopyWithImpl<$Res>
    implements $QuizResultModelCopyWith<$Res> {
  _$QuizResultModelCopyWithImpl(this._self, this._then);

  final QuizResultModel _self;
  final $Res Function(QuizResultModel) _then;

/// Create a copy of QuizResultModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? examTitle = null,Object? dateTime = null,Object? totalQuestions = null,Object? answered = null,Object? correct = null,Object? wrong = null,Object? unanswered = null,Object? totalTimeSeconds = null,Object? timeUsedSeconds = null,Object? passingScore = null,Object? passed = null,Object? correctByCategory = null,Object? totalByCategory = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,examTitle: null == examTitle ? _self.examTitle : examTitle // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as int,correct: null == correct ? _self.correct : correct // ignore: cast_nullable_to_non_nullable
as int,wrong: null == wrong ? _self.wrong : wrong // ignore: cast_nullable_to_non_nullable
as int,unanswered: null == unanswered ? _self.unanswered : unanswered // ignore: cast_nullable_to_non_nullable
as int,totalTimeSeconds: null == totalTimeSeconds ? _self.totalTimeSeconds : totalTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,timeUsedSeconds: null == timeUsedSeconds ? _self.timeUsedSeconds : timeUsedSeconds // ignore: cast_nullable_to_non_nullable
as int,passingScore: null == passingScore ? _self.passingScore : passingScore // ignore: cast_nullable_to_non_nullable
as int,passed: null == passed ? _self.passed : passed // ignore: cast_nullable_to_non_nullable
as bool,correctByCategory: null == correctByCategory ? _self.correctByCategory : correctByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalByCategory: null == totalByCategory ? _self.totalByCategory : totalByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [QuizResultModel].
extension QuizResultModelPatterns on QuizResultModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuizResultModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuizResultModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuizResultModel value)  $default,){
final _that = this;
switch (_that) {
case _QuizResultModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuizResultModel value)?  $default,){
final _that = this;
switch (_that) {
case _QuizResultModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String examTitle,  int dateTime,  int totalQuestions,  int answered,  int correct,  int wrong,  int unanswered,  int totalTimeSeconds,  int timeUsedSeconds,  int passingScore,  bool passed,  Map<String, int> correctByCategory,  Map<String, int> totalByCategory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuizResultModel() when $default != null:
return $default(_that.id,_that.examTitle,_that.dateTime,_that.totalQuestions,_that.answered,_that.correct,_that.wrong,_that.unanswered,_that.totalTimeSeconds,_that.timeUsedSeconds,_that.passingScore,_that.passed,_that.correctByCategory,_that.totalByCategory);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String examTitle,  int dateTime,  int totalQuestions,  int answered,  int correct,  int wrong,  int unanswered,  int totalTimeSeconds,  int timeUsedSeconds,  int passingScore,  bool passed,  Map<String, int> correctByCategory,  Map<String, int> totalByCategory)  $default,) {final _that = this;
switch (_that) {
case _QuizResultModel():
return $default(_that.id,_that.examTitle,_that.dateTime,_that.totalQuestions,_that.answered,_that.correct,_that.wrong,_that.unanswered,_that.totalTimeSeconds,_that.timeUsedSeconds,_that.passingScore,_that.passed,_that.correctByCategory,_that.totalByCategory);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String examTitle,  int dateTime,  int totalQuestions,  int answered,  int correct,  int wrong,  int unanswered,  int totalTimeSeconds,  int timeUsedSeconds,  int passingScore,  bool passed,  Map<String, int> correctByCategory,  Map<String, int> totalByCategory)?  $default,) {final _that = this;
switch (_that) {
case _QuizResultModel() when $default != null:
return $default(_that.id,_that.examTitle,_that.dateTime,_that.totalQuestions,_that.answered,_that.correct,_that.wrong,_that.unanswered,_that.totalTimeSeconds,_that.timeUsedSeconds,_that.passingScore,_that.passed,_that.correctByCategory,_that.totalByCategory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuizResultModel extends QuizResultModel {
  const _QuizResultModel({required this.id, required this.examTitle, required this.dateTime, required this.totalQuestions, required this.answered, required this.correct, required this.wrong, required this.unanswered, required this.totalTimeSeconds, required this.timeUsedSeconds, this.passingScore = 0, this.passed = false, final  Map<String, int> correctByCategory = const <String, int>{}, final  Map<String, int> totalByCategory = const <String, int>{}}): _correctByCategory = correctByCategory,_totalByCategory = totalByCategory,super._();
  factory _QuizResultModel.fromJson(Map<String, dynamic> json) => _$QuizResultModelFromJson(json);

@override final  String id;
@override final  String examTitle;
@override final  int dateTime;
@override final  int totalQuestions;
@override final  int answered;
@override final  int correct;
@override final  int wrong;
@override final  int unanswered;
@override final  int totalTimeSeconds;
@override final  int timeUsedSeconds;
@override@JsonKey() final  int passingScore;
@override@JsonKey() final  bool passed;
 final  Map<String, int> _correctByCategory;
@override@JsonKey() Map<String, int> get correctByCategory {
  if (_correctByCategory is EqualUnmodifiableMapView) return _correctByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_correctByCategory);
}

 final  Map<String, int> _totalByCategory;
@override@JsonKey() Map<String, int> get totalByCategory {
  if (_totalByCategory is EqualUnmodifiableMapView) return _totalByCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_totalByCategory);
}


/// Create a copy of QuizResultModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuizResultModelCopyWith<_QuizResultModel> get copyWith => __$QuizResultModelCopyWithImpl<_QuizResultModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuizResultModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuizResultModel&&(identical(other.id, id) || other.id == id)&&(identical(other.examTitle, examTitle) || other.examTitle == examTitle)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime)&&(identical(other.totalQuestions, totalQuestions) || other.totalQuestions == totalQuestions)&&(identical(other.answered, answered) || other.answered == answered)&&(identical(other.correct, correct) || other.correct == correct)&&(identical(other.wrong, wrong) || other.wrong == wrong)&&(identical(other.unanswered, unanswered) || other.unanswered == unanswered)&&(identical(other.totalTimeSeconds, totalTimeSeconds) || other.totalTimeSeconds == totalTimeSeconds)&&(identical(other.timeUsedSeconds, timeUsedSeconds) || other.timeUsedSeconds == timeUsedSeconds)&&(identical(other.passingScore, passingScore) || other.passingScore == passingScore)&&(identical(other.passed, passed) || other.passed == passed)&&const DeepCollectionEquality().equals(other._correctByCategory, _correctByCategory)&&const DeepCollectionEquality().equals(other._totalByCategory, _totalByCategory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,examTitle,dateTime,totalQuestions,answered,correct,wrong,unanswered,totalTimeSeconds,timeUsedSeconds,passingScore,passed,const DeepCollectionEquality().hash(_correctByCategory),const DeepCollectionEquality().hash(_totalByCategory));

@override
String toString() {
  return 'QuizResultModel(id: $id, examTitle: $examTitle, dateTime: $dateTime, totalQuestions: $totalQuestions, answered: $answered, correct: $correct, wrong: $wrong, unanswered: $unanswered, totalTimeSeconds: $totalTimeSeconds, timeUsedSeconds: $timeUsedSeconds, passingScore: $passingScore, passed: $passed, correctByCategory: $correctByCategory, totalByCategory: $totalByCategory)';
}


}

/// @nodoc
abstract mixin class _$QuizResultModelCopyWith<$Res> implements $QuizResultModelCopyWith<$Res> {
  factory _$QuizResultModelCopyWith(_QuizResultModel value, $Res Function(_QuizResultModel) _then) = __$QuizResultModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String examTitle, int dateTime, int totalQuestions, int answered, int correct, int wrong, int unanswered, int totalTimeSeconds, int timeUsedSeconds, int passingScore, bool passed, Map<String, int> correctByCategory, Map<String, int> totalByCategory
});




}
/// @nodoc
class __$QuizResultModelCopyWithImpl<$Res>
    implements _$QuizResultModelCopyWith<$Res> {
  __$QuizResultModelCopyWithImpl(this._self, this._then);

  final _QuizResultModel _self;
  final $Res Function(_QuizResultModel) _then;

/// Create a copy of QuizResultModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? examTitle = null,Object? dateTime = null,Object? totalQuestions = null,Object? answered = null,Object? correct = null,Object? wrong = null,Object? unanswered = null,Object? totalTimeSeconds = null,Object? timeUsedSeconds = null,Object? passingScore = null,Object? passed = null,Object? correctByCategory = null,Object? totalByCategory = null,}) {
  return _then(_QuizResultModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,examTitle: null == examTitle ? _self.examTitle : examTitle // ignore: cast_nullable_to_non_nullable
as String,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as int,totalQuestions: null == totalQuestions ? _self.totalQuestions : totalQuestions // ignore: cast_nullable_to_non_nullable
as int,answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as int,correct: null == correct ? _self.correct : correct // ignore: cast_nullable_to_non_nullable
as int,wrong: null == wrong ? _self.wrong : wrong // ignore: cast_nullable_to_non_nullable
as int,unanswered: null == unanswered ? _self.unanswered : unanswered // ignore: cast_nullable_to_non_nullable
as int,totalTimeSeconds: null == totalTimeSeconds ? _self.totalTimeSeconds : totalTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,timeUsedSeconds: null == timeUsedSeconds ? _self.timeUsedSeconds : timeUsedSeconds // ignore: cast_nullable_to_non_nullable
as int,passingScore: null == passingScore ? _self.passingScore : passingScore // ignore: cast_nullable_to_non_nullable
as int,passed: null == passed ? _self.passed : passed // ignore: cast_nullable_to_non_nullable
as bool,correctByCategory: null == correctByCategory ? _self._correctByCategory : correctByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,totalByCategory: null == totalByCategory ? _self._totalByCategory : totalByCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}


/// @nodoc
mixin _$AnswerLogEntry {

 String get questionId; bool get correct; int get dateTime;
/// Create a copy of AnswerLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerLogEntryCopyWith<AnswerLogEntry> get copyWith => _$AnswerLogEntryCopyWithImpl<AnswerLogEntry>(this as AnswerLogEntry, _$identity);

  /// Serializes this AnswerLogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerLogEntry&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.correct, correct) || other.correct == correct)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,correct,dateTime);

@override
String toString() {
  return 'AnswerLogEntry(questionId: $questionId, correct: $correct, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class $AnswerLogEntryCopyWith<$Res>  {
  factory $AnswerLogEntryCopyWith(AnswerLogEntry value, $Res Function(AnswerLogEntry) _then) = _$AnswerLogEntryCopyWithImpl;
@useResult
$Res call({
 String questionId, bool correct, int dateTime
});




}
/// @nodoc
class _$AnswerLogEntryCopyWithImpl<$Res>
    implements $AnswerLogEntryCopyWith<$Res> {
  _$AnswerLogEntryCopyWithImpl(this._self, this._then);

  final AnswerLogEntry _self;
  final $Res Function(AnswerLogEntry) _then;

/// Create a copy of AnswerLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionId = null,Object? correct = null,Object? dateTime = null,}) {
  return _then(_self.copyWith(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,correct: null == correct ? _self.correct : correct // ignore: cast_nullable_to_non_nullable
as bool,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AnswerLogEntry].
extension AnswerLogEntryPatterns on AnswerLogEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerLogEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AnswerLogEntry():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerLogEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String questionId,  bool correct,  int dateTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerLogEntry() when $default != null:
return $default(_that.questionId,_that.correct,_that.dateTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String questionId,  bool correct,  int dateTime)  $default,) {final _that = this;
switch (_that) {
case _AnswerLogEntry():
return $default(_that.questionId,_that.correct,_that.dateTime);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String questionId,  bool correct,  int dateTime)?  $default,) {final _that = this;
switch (_that) {
case _AnswerLogEntry() when $default != null:
return $default(_that.questionId,_that.correct,_that.dateTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerLogEntry extends AnswerLogEntry {
  const _AnswerLogEntry({required this.questionId, required this.correct, required this.dateTime}): super._();
  factory _AnswerLogEntry.fromJson(Map<String, dynamic> json) => _$AnswerLogEntryFromJson(json);

@override final  String questionId;
@override final  bool correct;
@override final  int dateTime;

/// Create a copy of AnswerLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerLogEntryCopyWith<_AnswerLogEntry> get copyWith => __$AnswerLogEntryCopyWithImpl<_AnswerLogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerLogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerLogEntry&&(identical(other.questionId, questionId) || other.questionId == questionId)&&(identical(other.correct, correct) || other.correct == correct)&&(identical(other.dateTime, dateTime) || other.dateTime == dateTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionId,correct,dateTime);

@override
String toString() {
  return 'AnswerLogEntry(questionId: $questionId, correct: $correct, dateTime: $dateTime)';
}


}

/// @nodoc
abstract mixin class _$AnswerLogEntryCopyWith<$Res> implements $AnswerLogEntryCopyWith<$Res> {
  factory _$AnswerLogEntryCopyWith(_AnswerLogEntry value, $Res Function(_AnswerLogEntry) _then) = __$AnswerLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String questionId, bool correct, int dateTime
});




}
/// @nodoc
class __$AnswerLogEntryCopyWithImpl<$Res>
    implements _$AnswerLogEntryCopyWith<$Res> {
  __$AnswerLogEntryCopyWithImpl(this._self, this._then);

  final _AnswerLogEntry _self;
  final $Res Function(_AnswerLogEntry) _then;

/// Create a copy of AnswerLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionId = null,Object? correct = null,Object? dateTime = null,}) {
  return _then(_AnswerLogEntry(
questionId: null == questionId ? _self.questionId : questionId // ignore: cast_nullable_to_non_nullable
as String,correct: null == correct ? _self.correct : correct // ignore: cast_nullable_to_non_nullable
as bool,dateTime: null == dateTime ? _self.dateTime : dateTime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
