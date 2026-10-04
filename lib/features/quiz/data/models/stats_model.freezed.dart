// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CategoryStat {

 int get answered; int get correct; int get mistakes;
/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryStatCopyWith<CategoryStat> get copyWith => _$CategoryStatCopyWithImpl<CategoryStat>(this as CategoryStat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryStat&&(identical(other.answered, answered) || other.answered == answered)&&(identical(other.correct, correct) || other.correct == correct)&&(identical(other.mistakes, mistakes) || other.mistakes == mistakes));
}


@override
int get hashCode => Object.hash(runtimeType,answered,correct,mistakes);

@override
String toString() {
  return 'CategoryStat(answered: $answered, correct: $correct, mistakes: $mistakes)';
}


}

/// @nodoc
abstract mixin class $CategoryStatCopyWith<$Res>  {
  factory $CategoryStatCopyWith(CategoryStat value, $Res Function(CategoryStat) _then) = _$CategoryStatCopyWithImpl;
@useResult
$Res call({
 int answered, int correct, int mistakes
});




}
/// @nodoc
class _$CategoryStatCopyWithImpl<$Res>
    implements $CategoryStatCopyWith<$Res> {
  _$CategoryStatCopyWithImpl(this._self, this._then);

  final CategoryStat _self;
  final $Res Function(CategoryStat) _then;

/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? answered = null,Object? correct = null,Object? mistakes = null,}) {
  return _then(_self.copyWith(
answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as int,correct: null == correct ? _self.correct : correct // ignore: cast_nullable_to_non_nullable
as int,mistakes: null == mistakes ? _self.mistakes : mistakes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryStat].
extension CategoryStatPatterns on CategoryStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryStat value)  $default,){
final _that = this;
switch (_that) {
case _CategoryStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryStat value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int answered,  int correct,  int mistakes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
return $default(_that.answered,_that.correct,_that.mistakes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int answered,  int correct,  int mistakes)  $default,) {final _that = this;
switch (_that) {
case _CategoryStat():
return $default(_that.answered,_that.correct,_that.mistakes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int answered,  int correct,  int mistakes)?  $default,) {final _that = this;
switch (_that) {
case _CategoryStat() when $default != null:
return $default(_that.answered,_that.correct,_that.mistakes);case _:
  return null;

}
}

}

/// @nodoc


class _CategoryStat extends CategoryStat {
  const _CategoryStat({this.answered = 0, this.correct = 0, this.mistakes = 0}): super._();
  

@override@JsonKey() final  int answered;
@override@JsonKey() final  int correct;
@override@JsonKey() final  int mistakes;

/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryStatCopyWith<_CategoryStat> get copyWith => __$CategoryStatCopyWithImpl<_CategoryStat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryStat&&(identical(other.answered, answered) || other.answered == answered)&&(identical(other.correct, correct) || other.correct == correct)&&(identical(other.mistakes, mistakes) || other.mistakes == mistakes));
}


@override
int get hashCode => Object.hash(runtimeType,answered,correct,mistakes);

@override
String toString() {
  return 'CategoryStat(answered: $answered, correct: $correct, mistakes: $mistakes)';
}


}

/// @nodoc
abstract mixin class _$CategoryStatCopyWith<$Res> implements $CategoryStatCopyWith<$Res> {
  factory _$CategoryStatCopyWith(_CategoryStat value, $Res Function(_CategoryStat) _then) = __$CategoryStatCopyWithImpl;
@override @useResult
$Res call({
 int answered, int correct, int mistakes
});




}
/// @nodoc
class __$CategoryStatCopyWithImpl<$Res>
    implements _$CategoryStatCopyWith<$Res> {
  __$CategoryStatCopyWithImpl(this._self, this._then);

  final _CategoryStat _self;
  final $Res Function(_CategoryStat) _then;

/// Create a copy of CategoryStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? answered = null,Object? correct = null,Object? mistakes = null,}) {
  return _then(_CategoryStat(
answered: null == answered ? _self.answered : answered // ignore: cast_nullable_to_non_nullable
as int,correct: null == correct ? _self.correct : correct // ignore: cast_nullable_to_non_nullable
as int,mistakes: null == mistakes ? _self.mistakes : mistakes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StatsModel {

 int get totalAnswered; int get totalCorrect; int get totalWrong; int get examsTaken; int get bestExamScore; double get averageExamScore; double get accuracy; Map<String, CategoryStat> get categoryStats; int get bookmarkedCount; int get mistakeCount;
/// Create a copy of StatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsModelCopyWith<StatsModel> get copyWith => _$StatsModelCopyWithImpl<StatsModel>(this as StatsModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsModel&&(identical(other.totalAnswered, totalAnswered) || other.totalAnswered == totalAnswered)&&(identical(other.totalCorrect, totalCorrect) || other.totalCorrect == totalCorrect)&&(identical(other.totalWrong, totalWrong) || other.totalWrong == totalWrong)&&(identical(other.examsTaken, examsTaken) || other.examsTaken == examsTaken)&&(identical(other.bestExamScore, bestExamScore) || other.bestExamScore == bestExamScore)&&(identical(other.averageExamScore, averageExamScore) || other.averageExamScore == averageExamScore)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&const DeepCollectionEquality().equals(other.categoryStats, categoryStats)&&(identical(other.bookmarkedCount, bookmarkedCount) || other.bookmarkedCount == bookmarkedCount)&&(identical(other.mistakeCount, mistakeCount) || other.mistakeCount == mistakeCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalAnswered,totalCorrect,totalWrong,examsTaken,bestExamScore,averageExamScore,accuracy,const DeepCollectionEquality().hash(categoryStats),bookmarkedCount,mistakeCount);

@override
String toString() {
  return 'StatsModel(totalAnswered: $totalAnswered, totalCorrect: $totalCorrect, totalWrong: $totalWrong, examsTaken: $examsTaken, bestExamScore: $bestExamScore, averageExamScore: $averageExamScore, accuracy: $accuracy, categoryStats: $categoryStats, bookmarkedCount: $bookmarkedCount, mistakeCount: $mistakeCount)';
}


}

/// @nodoc
abstract mixin class $StatsModelCopyWith<$Res>  {
  factory $StatsModelCopyWith(StatsModel value, $Res Function(StatsModel) _then) = _$StatsModelCopyWithImpl;
@useResult
$Res call({
 int totalAnswered, int totalCorrect, int totalWrong, int examsTaken, int bestExamScore, double averageExamScore, double accuracy, Map<String, CategoryStat> categoryStats, int bookmarkedCount, int mistakeCount
});




}
/// @nodoc
class _$StatsModelCopyWithImpl<$Res>
    implements $StatsModelCopyWith<$Res> {
  _$StatsModelCopyWithImpl(this._self, this._then);

  final StatsModel _self;
  final $Res Function(StatsModel) _then;

/// Create a copy of StatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalAnswered = null,Object? totalCorrect = null,Object? totalWrong = null,Object? examsTaken = null,Object? bestExamScore = null,Object? averageExamScore = null,Object? accuracy = null,Object? categoryStats = null,Object? bookmarkedCount = null,Object? mistakeCount = null,}) {
  return _then(_self.copyWith(
totalAnswered: null == totalAnswered ? _self.totalAnswered : totalAnswered // ignore: cast_nullable_to_non_nullable
as int,totalCorrect: null == totalCorrect ? _self.totalCorrect : totalCorrect // ignore: cast_nullable_to_non_nullable
as int,totalWrong: null == totalWrong ? _self.totalWrong : totalWrong // ignore: cast_nullable_to_non_nullable
as int,examsTaken: null == examsTaken ? _self.examsTaken : examsTaken // ignore: cast_nullable_to_non_nullable
as int,bestExamScore: null == bestExamScore ? _self.bestExamScore : bestExamScore // ignore: cast_nullable_to_non_nullable
as int,averageExamScore: null == averageExamScore ? _self.averageExamScore : averageExamScore // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,categoryStats: null == categoryStats ? _self.categoryStats : categoryStats // ignore: cast_nullable_to_non_nullable
as Map<String, CategoryStat>,bookmarkedCount: null == bookmarkedCount ? _self.bookmarkedCount : bookmarkedCount // ignore: cast_nullable_to_non_nullable
as int,mistakeCount: null == mistakeCount ? _self.mistakeCount : mistakeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsModel].
extension StatsModelPatterns on StatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsModel value)  $default,){
final _that = this;
switch (_that) {
case _StatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _StatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalAnswered,  int totalCorrect,  int totalWrong,  int examsTaken,  int bestExamScore,  double averageExamScore,  double accuracy,  Map<String, CategoryStat> categoryStats,  int bookmarkedCount,  int mistakeCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsModel() when $default != null:
return $default(_that.totalAnswered,_that.totalCorrect,_that.totalWrong,_that.examsTaken,_that.bestExamScore,_that.averageExamScore,_that.accuracy,_that.categoryStats,_that.bookmarkedCount,_that.mistakeCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalAnswered,  int totalCorrect,  int totalWrong,  int examsTaken,  int bestExamScore,  double averageExamScore,  double accuracy,  Map<String, CategoryStat> categoryStats,  int bookmarkedCount,  int mistakeCount)  $default,) {final _that = this;
switch (_that) {
case _StatsModel():
return $default(_that.totalAnswered,_that.totalCorrect,_that.totalWrong,_that.examsTaken,_that.bestExamScore,_that.averageExamScore,_that.accuracy,_that.categoryStats,_that.bookmarkedCount,_that.mistakeCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalAnswered,  int totalCorrect,  int totalWrong,  int examsTaken,  int bestExamScore,  double averageExamScore,  double accuracy,  Map<String, CategoryStat> categoryStats,  int bookmarkedCount,  int mistakeCount)?  $default,) {final _that = this;
switch (_that) {
case _StatsModel() when $default != null:
return $default(_that.totalAnswered,_that.totalCorrect,_that.totalWrong,_that.examsTaken,_that.bestExamScore,_that.averageExamScore,_that.accuracy,_that.categoryStats,_that.bookmarkedCount,_that.mistakeCount);case _:
  return null;

}
}

}

/// @nodoc


class _StatsModel extends StatsModel {
  const _StatsModel({this.totalAnswered = 0, this.totalCorrect = 0, this.totalWrong = 0, this.examsTaken = 0, this.bestExamScore = 0, this.averageExamScore = 0, this.accuracy = 0, final  Map<String, CategoryStat> categoryStats = const <String, CategoryStat>{}, this.bookmarkedCount = 0, this.mistakeCount = 0}): _categoryStats = categoryStats,super._();
  

@override@JsonKey() final  int totalAnswered;
@override@JsonKey() final  int totalCorrect;
@override@JsonKey() final  int totalWrong;
@override@JsonKey() final  int examsTaken;
@override@JsonKey() final  int bestExamScore;
@override@JsonKey() final  double averageExamScore;
@override@JsonKey() final  double accuracy;
 final  Map<String, CategoryStat> _categoryStats;
@override@JsonKey() Map<String, CategoryStat> get categoryStats {
  if (_categoryStats is EqualUnmodifiableMapView) return _categoryStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_categoryStats);
}

@override@JsonKey() final  int bookmarkedCount;
@override@JsonKey() final  int mistakeCount;

/// Create a copy of StatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsModelCopyWith<_StatsModel> get copyWith => __$StatsModelCopyWithImpl<_StatsModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsModel&&(identical(other.totalAnswered, totalAnswered) || other.totalAnswered == totalAnswered)&&(identical(other.totalCorrect, totalCorrect) || other.totalCorrect == totalCorrect)&&(identical(other.totalWrong, totalWrong) || other.totalWrong == totalWrong)&&(identical(other.examsTaken, examsTaken) || other.examsTaken == examsTaken)&&(identical(other.bestExamScore, bestExamScore) || other.bestExamScore == bestExamScore)&&(identical(other.averageExamScore, averageExamScore) || other.averageExamScore == averageExamScore)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&const DeepCollectionEquality().equals(other._categoryStats, _categoryStats)&&(identical(other.bookmarkedCount, bookmarkedCount) || other.bookmarkedCount == bookmarkedCount)&&(identical(other.mistakeCount, mistakeCount) || other.mistakeCount == mistakeCount));
}


@override
int get hashCode => Object.hash(runtimeType,totalAnswered,totalCorrect,totalWrong,examsTaken,bestExamScore,averageExamScore,accuracy,const DeepCollectionEquality().hash(_categoryStats),bookmarkedCount,mistakeCount);

@override
String toString() {
  return 'StatsModel(totalAnswered: $totalAnswered, totalCorrect: $totalCorrect, totalWrong: $totalWrong, examsTaken: $examsTaken, bestExamScore: $bestExamScore, averageExamScore: $averageExamScore, accuracy: $accuracy, categoryStats: $categoryStats, bookmarkedCount: $bookmarkedCount, mistakeCount: $mistakeCount)';
}


}

/// @nodoc
abstract mixin class _$StatsModelCopyWith<$Res> implements $StatsModelCopyWith<$Res> {
  factory _$StatsModelCopyWith(_StatsModel value, $Res Function(_StatsModel) _then) = __$StatsModelCopyWithImpl;
@override @useResult
$Res call({
 int totalAnswered, int totalCorrect, int totalWrong, int examsTaken, int bestExamScore, double averageExamScore, double accuracy, Map<String, CategoryStat> categoryStats, int bookmarkedCount, int mistakeCount
});




}
/// @nodoc
class __$StatsModelCopyWithImpl<$Res>
    implements _$StatsModelCopyWith<$Res> {
  __$StatsModelCopyWithImpl(this._self, this._then);

  final _StatsModel _self;
  final $Res Function(_StatsModel) _then;

/// Create a copy of StatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalAnswered = null,Object? totalCorrect = null,Object? totalWrong = null,Object? examsTaken = null,Object? bestExamScore = null,Object? averageExamScore = null,Object? accuracy = null,Object? categoryStats = null,Object? bookmarkedCount = null,Object? mistakeCount = null,}) {
  return _then(_StatsModel(
totalAnswered: null == totalAnswered ? _self.totalAnswered : totalAnswered // ignore: cast_nullable_to_non_nullable
as int,totalCorrect: null == totalCorrect ? _self.totalCorrect : totalCorrect // ignore: cast_nullable_to_non_nullable
as int,totalWrong: null == totalWrong ? _self.totalWrong : totalWrong // ignore: cast_nullable_to_non_nullable
as int,examsTaken: null == examsTaken ? _self.examsTaken : examsTaken // ignore: cast_nullable_to_non_nullable
as int,bestExamScore: null == bestExamScore ? _self.bestExamScore : bestExamScore // ignore: cast_nullable_to_non_nullable
as int,averageExamScore: null == averageExamScore ? _self.averageExamScore : averageExamScore // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,categoryStats: null == categoryStats ? _self._categoryStats : categoryStats // ignore: cast_nullable_to_non_nullable
as Map<String, CategoryStat>,bookmarkedCount: null == bookmarkedCount ? _self.bookmarkedCount : bookmarkedCount // ignore: cast_nullable_to_non_nullable
as int,mistakeCount: null == mistakeCount ? _self.mistakeCount : mistakeCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
