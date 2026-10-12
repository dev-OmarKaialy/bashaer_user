// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CategoryRoundResult {

 String get categoryId; String get categoryName; int get correctAttempts; int get totalAttempts;
/// Create a copy of CategoryRoundResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryRoundResultCopyWith<CategoryRoundResult> get copyWith => _$CategoryRoundResultCopyWithImpl<CategoryRoundResult>(this as CategoryRoundResult, _$identity);

  /// Serializes this CategoryRoundResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRoundResult&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.correctAttempts, correctAttempts) || other.correctAttempts == correctAttempts)&&(identical(other.totalAttempts, totalAttempts) || other.totalAttempts == totalAttempts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,correctAttempts,totalAttempts);

@override
String toString() {
  return 'CategoryRoundResult(categoryId: $categoryId, categoryName: $categoryName, correctAttempts: $correctAttempts, totalAttempts: $totalAttempts)';
}


}

/// @nodoc
abstract mixin class $CategoryRoundResultCopyWith<$Res>  {
  factory $CategoryRoundResultCopyWith(CategoryRoundResult value, $Res Function(CategoryRoundResult) _then) = _$CategoryRoundResultCopyWithImpl;
@useResult
$Res call({
 String categoryId, String categoryName, int correctAttempts, int totalAttempts
});




}
/// @nodoc
class _$CategoryRoundResultCopyWithImpl<$Res>
    implements $CategoryRoundResultCopyWith<$Res> {
  _$CategoryRoundResultCopyWithImpl(this._self, this._then);

  final CategoryRoundResult _self;
  final $Res Function(CategoryRoundResult) _then;

/// Create a copy of CategoryRoundResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? categoryName = null,Object? correctAttempts = null,Object? totalAttempts = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,correctAttempts: null == correctAttempts ? _self.correctAttempts : correctAttempts // ignore: cast_nullable_to_non_nullable
as int,totalAttempts: null == totalAttempts ? _self.totalAttempts : totalAttempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryRoundResult].
extension CategoryRoundResultPatterns on CategoryRoundResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryRoundResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryRoundResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryRoundResult value)  $default,){
final _that = this;
switch (_that) {
case _CategoryRoundResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryRoundResult value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryRoundResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String categoryName,  int correctAttempts,  int totalAttempts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryRoundResult() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.correctAttempts,_that.totalAttempts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String categoryName,  int correctAttempts,  int totalAttempts)  $default,) {final _that = this;
switch (_that) {
case _CategoryRoundResult():
return $default(_that.categoryId,_that.categoryName,_that.correctAttempts,_that.totalAttempts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String categoryName,  int correctAttempts,  int totalAttempts)?  $default,) {final _that = this;
switch (_that) {
case _CategoryRoundResult() when $default != null:
return $default(_that.categoryId,_that.categoryName,_that.correctAttempts,_that.totalAttempts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryRoundResult extends CategoryRoundResult {
  const _CategoryRoundResult({required this.categoryId, required this.categoryName, required this.correctAttempts, required this.totalAttempts}): super._();
  factory _CategoryRoundResult.fromJson(Map<String, dynamic> json) => _$CategoryRoundResultFromJson(json);

@override final  String categoryId;
@override final  String categoryName;
@override final  int correctAttempts;
@override final  int totalAttempts;

/// Create a copy of CategoryRoundResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryRoundResultCopyWith<_CategoryRoundResult> get copyWith => __$CategoryRoundResultCopyWithImpl<_CategoryRoundResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryRoundResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryRoundResult&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.correctAttempts, correctAttempts) || other.correctAttempts == correctAttempts)&&(identical(other.totalAttempts, totalAttempts) || other.totalAttempts == totalAttempts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,categoryName,correctAttempts,totalAttempts);

@override
String toString() {
  return 'CategoryRoundResult(categoryId: $categoryId, categoryName: $categoryName, correctAttempts: $correctAttempts, totalAttempts: $totalAttempts)';
}


}

/// @nodoc
abstract mixin class _$CategoryRoundResultCopyWith<$Res> implements $CategoryRoundResultCopyWith<$Res> {
  factory _$CategoryRoundResultCopyWith(_CategoryRoundResult value, $Res Function(_CategoryRoundResult) _then) = __$CategoryRoundResultCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String categoryName, int correctAttempts, int totalAttempts
});




}
/// @nodoc
class __$CategoryRoundResultCopyWithImpl<$Res>
    implements _$CategoryRoundResultCopyWith<$Res> {
  __$CategoryRoundResultCopyWithImpl(this._self, this._then);

  final _CategoryRoundResult _self;
  final $Res Function(_CategoryRoundResult) _then;

/// Create a copy of CategoryRoundResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? categoryName = null,Object? correctAttempts = null,Object? totalAttempts = null,}) {
  return _then(_CategoryRoundResult(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,correctAttempts: null == correctAttempts ? _self.correctAttempts : correctAttempts // ignore: cast_nullable_to_non_nullable
as int,totalAttempts: null == totalAttempts ? _self.totalAttempts : totalAttempts // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrainingSessionModel {

 String get id; int get startedAt; int? get endedAt; TrainingSessionStatus get status; List<String> get categoryIds; int get currentCategoryIndex;/// Session total, never below zero.
 int get points;/// Attempts made so far in the current (unfinished) category.
 int get currentCorrectAttempts; int get currentTotalAttempts;/// Questions already answered correctly in the current category.
 List<String> get solvedQuestionIds; List<CategoryRoundResult> get categoryResults;
/// Create a copy of TrainingSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainingSessionModelCopyWith<TrainingSessionModel> get copyWith => _$TrainingSessionModelCopyWithImpl<TrainingSessionModel>(this as TrainingSessionModel, _$identity);

  /// Serializes this TrainingSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainingSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.currentCategoryIndex, currentCategoryIndex) || other.currentCategoryIndex == currentCategoryIndex)&&(identical(other.points, points) || other.points == points)&&(identical(other.currentCorrectAttempts, currentCorrectAttempts) || other.currentCorrectAttempts == currentCorrectAttempts)&&(identical(other.currentTotalAttempts, currentTotalAttempts) || other.currentTotalAttempts == currentTotalAttempts)&&const DeepCollectionEquality().equals(other.solvedQuestionIds, solvedQuestionIds)&&const DeepCollectionEquality().equals(other.categoryResults, categoryResults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startedAt,endedAt,status,const DeepCollectionEquality().hash(categoryIds),currentCategoryIndex,points,currentCorrectAttempts,currentTotalAttempts,const DeepCollectionEquality().hash(solvedQuestionIds),const DeepCollectionEquality().hash(categoryResults));

@override
String toString() {
  return 'TrainingSessionModel(id: $id, startedAt: $startedAt, endedAt: $endedAt, status: $status, categoryIds: $categoryIds, currentCategoryIndex: $currentCategoryIndex, points: $points, currentCorrectAttempts: $currentCorrectAttempts, currentTotalAttempts: $currentTotalAttempts, solvedQuestionIds: $solvedQuestionIds, categoryResults: $categoryResults)';
}


}

/// @nodoc
abstract mixin class $TrainingSessionModelCopyWith<$Res>  {
  factory $TrainingSessionModelCopyWith(TrainingSessionModel value, $Res Function(TrainingSessionModel) _then) = _$TrainingSessionModelCopyWithImpl;
@useResult
$Res call({
 String id, int startedAt, int? endedAt, TrainingSessionStatus status, List<String> categoryIds, int currentCategoryIndex, int points, int currentCorrectAttempts, int currentTotalAttempts, List<String> solvedQuestionIds, List<CategoryRoundResult> categoryResults
});




}
/// @nodoc
class _$TrainingSessionModelCopyWithImpl<$Res>
    implements $TrainingSessionModelCopyWith<$Res> {
  _$TrainingSessionModelCopyWithImpl(this._self, this._then);

  final TrainingSessionModel _self;
  final $Res Function(TrainingSessionModel) _then;

/// Create a copy of TrainingSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startedAt = null,Object? endedAt = freezed,Object? status = null,Object? categoryIds = null,Object? currentCategoryIndex = null,Object? points = null,Object? currentCorrectAttempts = null,Object? currentTotalAttempts = null,Object? solvedQuestionIds = null,Object? categoryResults = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TrainingSessionStatus,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,currentCategoryIndex: null == currentCategoryIndex ? _self.currentCategoryIndex : currentCategoryIndex // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,currentCorrectAttempts: null == currentCorrectAttempts ? _self.currentCorrectAttempts : currentCorrectAttempts // ignore: cast_nullable_to_non_nullable
as int,currentTotalAttempts: null == currentTotalAttempts ? _self.currentTotalAttempts : currentTotalAttempts // ignore: cast_nullable_to_non_nullable
as int,solvedQuestionIds: null == solvedQuestionIds ? _self.solvedQuestionIds : solvedQuestionIds // ignore: cast_nullable_to_non_nullable
as List<String>,categoryResults: null == categoryResults ? _self.categoryResults : categoryResults // ignore: cast_nullable_to_non_nullable
as List<CategoryRoundResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainingSessionModel].
extension TrainingSessionModelPatterns on TrainingSessionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainingSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainingSessionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainingSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainingSessionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainingSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainingSessionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int startedAt,  int? endedAt,  TrainingSessionStatus status,  List<String> categoryIds,  int currentCategoryIndex,  int points,  int currentCorrectAttempts,  int currentTotalAttempts,  List<String> solvedQuestionIds,  List<CategoryRoundResult> categoryResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainingSessionModel() when $default != null:
return $default(_that.id,_that.startedAt,_that.endedAt,_that.status,_that.categoryIds,_that.currentCategoryIndex,_that.points,_that.currentCorrectAttempts,_that.currentTotalAttempts,_that.solvedQuestionIds,_that.categoryResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int startedAt,  int? endedAt,  TrainingSessionStatus status,  List<String> categoryIds,  int currentCategoryIndex,  int points,  int currentCorrectAttempts,  int currentTotalAttempts,  List<String> solvedQuestionIds,  List<CategoryRoundResult> categoryResults)  $default,) {final _that = this;
switch (_that) {
case _TrainingSessionModel():
return $default(_that.id,_that.startedAt,_that.endedAt,_that.status,_that.categoryIds,_that.currentCategoryIndex,_that.points,_that.currentCorrectAttempts,_that.currentTotalAttempts,_that.solvedQuestionIds,_that.categoryResults);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int startedAt,  int? endedAt,  TrainingSessionStatus status,  List<String> categoryIds,  int currentCategoryIndex,  int points,  int currentCorrectAttempts,  int currentTotalAttempts,  List<String> solvedQuestionIds,  List<CategoryRoundResult> categoryResults)?  $default,) {final _that = this;
switch (_that) {
case _TrainingSessionModel() when $default != null:
return $default(_that.id,_that.startedAt,_that.endedAt,_that.status,_that.categoryIds,_that.currentCategoryIndex,_that.points,_that.currentCorrectAttempts,_that.currentTotalAttempts,_that.solvedQuestionIds,_that.categoryResults);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainingSessionModel extends TrainingSessionModel {
  const _TrainingSessionModel({required this.id, required this.startedAt, this.endedAt, this.status = TrainingSessionStatus.active, final  List<String> categoryIds = const <String>[], this.currentCategoryIndex = 0, this.points = 0, this.currentCorrectAttempts = 0, this.currentTotalAttempts = 0, final  List<String> solvedQuestionIds = const <String>[], final  List<CategoryRoundResult> categoryResults = const <CategoryRoundResult>[]}): _categoryIds = categoryIds,_solvedQuestionIds = solvedQuestionIds,_categoryResults = categoryResults,super._();
  factory _TrainingSessionModel.fromJson(Map<String, dynamic> json) => _$TrainingSessionModelFromJson(json);

@override final  String id;
@override final  int startedAt;
@override final  int? endedAt;
@override@JsonKey() final  TrainingSessionStatus status;
 final  List<String> _categoryIds;
@override@JsonKey() List<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableListView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryIds);
}

@override@JsonKey() final  int currentCategoryIndex;
/// Session total, never below zero.
@override@JsonKey() final  int points;
/// Attempts made so far in the current (unfinished) category.
@override@JsonKey() final  int currentCorrectAttempts;
@override@JsonKey() final  int currentTotalAttempts;
/// Questions already answered correctly in the current category.
 final  List<String> _solvedQuestionIds;
/// Questions already answered correctly in the current category.
@override@JsonKey() List<String> get solvedQuestionIds {
  if (_solvedQuestionIds is EqualUnmodifiableListView) return _solvedQuestionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_solvedQuestionIds);
}

 final  List<CategoryRoundResult> _categoryResults;
@override@JsonKey() List<CategoryRoundResult> get categoryResults {
  if (_categoryResults is EqualUnmodifiableListView) return _categoryResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categoryResults);
}


/// Create a copy of TrainingSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainingSessionModelCopyWith<_TrainingSessionModel> get copyWith => __$TrainingSessionModelCopyWithImpl<_TrainingSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainingSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainingSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.currentCategoryIndex, currentCategoryIndex) || other.currentCategoryIndex == currentCategoryIndex)&&(identical(other.points, points) || other.points == points)&&(identical(other.currentCorrectAttempts, currentCorrectAttempts) || other.currentCorrectAttempts == currentCorrectAttempts)&&(identical(other.currentTotalAttempts, currentTotalAttempts) || other.currentTotalAttempts == currentTotalAttempts)&&const DeepCollectionEquality().equals(other._solvedQuestionIds, _solvedQuestionIds)&&const DeepCollectionEquality().equals(other._categoryResults, _categoryResults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startedAt,endedAt,status,const DeepCollectionEquality().hash(_categoryIds),currentCategoryIndex,points,currentCorrectAttempts,currentTotalAttempts,const DeepCollectionEquality().hash(_solvedQuestionIds),const DeepCollectionEquality().hash(_categoryResults));

@override
String toString() {
  return 'TrainingSessionModel(id: $id, startedAt: $startedAt, endedAt: $endedAt, status: $status, categoryIds: $categoryIds, currentCategoryIndex: $currentCategoryIndex, points: $points, currentCorrectAttempts: $currentCorrectAttempts, currentTotalAttempts: $currentTotalAttempts, solvedQuestionIds: $solvedQuestionIds, categoryResults: $categoryResults)';
}


}

/// @nodoc
abstract mixin class _$TrainingSessionModelCopyWith<$Res> implements $TrainingSessionModelCopyWith<$Res> {
  factory _$TrainingSessionModelCopyWith(_TrainingSessionModel value, $Res Function(_TrainingSessionModel) _then) = __$TrainingSessionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, int startedAt, int? endedAt, TrainingSessionStatus status, List<String> categoryIds, int currentCategoryIndex, int points, int currentCorrectAttempts, int currentTotalAttempts, List<String> solvedQuestionIds, List<CategoryRoundResult> categoryResults
});




}
/// @nodoc
class __$TrainingSessionModelCopyWithImpl<$Res>
    implements _$TrainingSessionModelCopyWith<$Res> {
  __$TrainingSessionModelCopyWithImpl(this._self, this._then);

  final _TrainingSessionModel _self;
  final $Res Function(_TrainingSessionModel) _then;

/// Create a copy of TrainingSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startedAt = null,Object? endedAt = freezed,Object? status = null,Object? categoryIds = null,Object? currentCategoryIndex = null,Object? points = null,Object? currentCorrectAttempts = null,Object? currentTotalAttempts = null,Object? solvedQuestionIds = null,Object? categoryResults = null,}) {
  return _then(_TrainingSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as int,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TrainingSessionStatus,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as List<String>,currentCategoryIndex: null == currentCategoryIndex ? _self.currentCategoryIndex : currentCategoryIndex // ignore: cast_nullable_to_non_nullable
as int,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,currentCorrectAttempts: null == currentCorrectAttempts ? _self.currentCorrectAttempts : currentCorrectAttempts // ignore: cast_nullable_to_non_nullable
as int,currentTotalAttempts: null == currentTotalAttempts ? _self.currentTotalAttempts : currentTotalAttempts // ignore: cast_nullable_to_non_nullable
as int,solvedQuestionIds: null == solvedQuestionIds ? _self._solvedQuestionIds : solvedQuestionIds // ignore: cast_nullable_to_non_nullable
as List<String>,categoryResults: null == categoryResults ? _self._categoryResults : categoryResults // ignore: cast_nullable_to_non_nullable
as List<CategoryRoundResult>,
  ));
}


}

// dart format on
