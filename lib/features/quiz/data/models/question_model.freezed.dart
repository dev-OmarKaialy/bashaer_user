// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'question_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnswerModel {

 String get id; String get text; bool get isCorrect; String? get image; String? get description;
/// Create a copy of AnswerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnswerModelCopyWith<AnswerModel> get copyWith => _$AnswerModelCopyWithImpl<AnswerModel>(this as AnswerModel, _$identity);

  /// Serializes this AnswerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.image, image) || other.image == image)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,isCorrect,image,description);

@override
String toString() {
  return 'AnswerModel(id: $id, text: $text, isCorrect: $isCorrect, image: $image, description: $description)';
}


}

/// @nodoc
abstract mixin class $AnswerModelCopyWith<$Res>  {
  factory $AnswerModelCopyWith(AnswerModel value, $Res Function(AnswerModel) _then) = _$AnswerModelCopyWithImpl;
@useResult
$Res call({
 String id, String text, bool isCorrect, String? image, String? description
});




}
/// @nodoc
class _$AnswerModelCopyWithImpl<$Res>
    implements $AnswerModelCopyWith<$Res> {
  _$AnswerModelCopyWithImpl(this._self, this._then);

  final AnswerModel _self;
  final $Res Function(AnswerModel) _then;

/// Create a copy of AnswerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? text = null,Object? isCorrect = null,Object? image = freezed,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AnswerModel].
extension AnswerModelPatterns on AnswerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnswerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnswerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnswerModel value)  $default,){
final _that = this;
switch (_that) {
case _AnswerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnswerModel value)?  $default,){
final _that = this;
switch (_that) {
case _AnswerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String text,  bool isCorrect,  String? image,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnswerModel() when $default != null:
return $default(_that.id,_that.text,_that.isCorrect,_that.image,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String text,  bool isCorrect,  String? image,  String? description)  $default,) {final _that = this;
switch (_that) {
case _AnswerModel():
return $default(_that.id,_that.text,_that.isCorrect,_that.image,_that.description);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String text,  bool isCorrect,  String? image,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _AnswerModel() when $default != null:
return $default(_that.id,_that.text,_that.isCorrect,_that.image,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnswerModel extends AnswerModel {
  const _AnswerModel({required this.id, required this.text, this.isCorrect = false, this.image, this.description}): super._();
  factory _AnswerModel.fromJson(Map<String, dynamic> json) => _$AnswerModelFromJson(json);

@override final  String id;
@override final  String text;
@override@JsonKey() final  bool isCorrect;
@override final  String? image;
@override final  String? description;

/// Create a copy of AnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnswerModelCopyWith<_AnswerModel> get copyWith => __$AnswerModelCopyWithImpl<_AnswerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnswerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnswerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.text, text) || other.text == text)&&(identical(other.isCorrect, isCorrect) || other.isCorrect == isCorrect)&&(identical(other.image, image) || other.image == image)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,text,isCorrect,image,description);

@override
String toString() {
  return 'AnswerModel(id: $id, text: $text, isCorrect: $isCorrect, image: $image, description: $description)';
}


}

/// @nodoc
abstract mixin class _$AnswerModelCopyWith<$Res> implements $AnswerModelCopyWith<$Res> {
  factory _$AnswerModelCopyWith(_AnswerModel value, $Res Function(_AnswerModel) _then) = __$AnswerModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String text, bool isCorrect, String? image, String? description
});




}
/// @nodoc
class __$AnswerModelCopyWithImpl<$Res>
    implements _$AnswerModelCopyWith<$Res> {
  __$AnswerModelCopyWithImpl(this._self, this._then);

  final _AnswerModel _self;
  final $Res Function(_AnswerModel) _then;

/// Create a copy of AnswerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? text = null,Object? isCorrect = null,Object? image = freezed,Object? description = freezed,}) {
  return _then(_AnswerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isCorrect: null == isCorrect ? _self.isCorrect : isCorrect // ignore: cast_nullable_to_non_nullable
as bool,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$QuestionModel {

 String get id; String get categoryId;@JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson) QuestionType get type; String get title;/// Optional media URL (Firestore Storage / HTTPS). Title is always required.
 String? get image;/// Optional pre-recorded question audio (Firestore Storage / HTTPS).
/// When set, Listen mode plays this instead of device TTS.
 String? get audio; String? get description; List<AnswerModel> get answers; List<String> get correctAnswerIds; String? get hint; String? get explanation; String? get difficulty; int get points;
/// Create a copy of QuestionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuestionModelCopyWith<QuestionModel> get copyWith => _$QuestionModelCopyWithImpl<QuestionModel>(this as QuestionModel, _$identity);

  /// Serializes this QuestionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.image, image) || other.image == image)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.answers, answers)&&const DeepCollectionEquality().equals(other.correctAnswerIds, correctAnswerIds)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.points, points) || other.points == points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,type,title,image,audio,description,const DeepCollectionEquality().hash(answers),const DeepCollectionEquality().hash(correctAnswerIds),hint,explanation,difficulty,points);

@override
String toString() {
  return 'QuestionModel(id: $id, categoryId: $categoryId, type: $type, title: $title, image: $image, audio: $audio, description: $description, answers: $answers, correctAnswerIds: $correctAnswerIds, hint: $hint, explanation: $explanation, difficulty: $difficulty, points: $points)';
}


}

/// @nodoc
abstract mixin class $QuestionModelCopyWith<$Res>  {
  factory $QuestionModelCopyWith(QuestionModel value, $Res Function(QuestionModel) _then) = _$QuestionModelCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId,@JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson) QuestionType type, String title, String? image, String? audio, String? description, List<AnswerModel> answers, List<String> correctAnswerIds, String? hint, String? explanation, String? difficulty, int points
});




}
/// @nodoc
class _$QuestionModelCopyWithImpl<$Res>
    implements $QuestionModelCopyWith<$Res> {
  _$QuestionModelCopyWithImpl(this._self, this._then);

  final QuestionModel _self;
  final $Res Function(QuestionModel) _then;

/// Create a copy of QuestionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? type = null,Object? title = null,Object? image = freezed,Object? audio = freezed,Object? description = freezed,Object? answers = null,Object? correctAnswerIds = null,Object? hint = freezed,Object? explanation = freezed,Object? difficulty = freezed,Object? points = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuestionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as List<AnswerModel>,correctAnswerIds: null == correctAnswerIds ? _self.correctAnswerIds : correctAnswerIds // ignore: cast_nullable_to_non_nullable
as List<String>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [QuestionModel].
extension QuestionModelPatterns on QuestionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuestionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuestionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuestionModel value)  $default,){
final _that = this;
switch (_that) {
case _QuestionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuestionModel value)?  $default,){
final _that = this;
switch (_that) {
case _QuestionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId, @JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson)  QuestionType type,  String title,  String? image,  String? audio,  String? description,  List<AnswerModel> answers,  List<String> correctAnswerIds,  String? hint,  String? explanation,  String? difficulty,  int points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuestionModel() when $default != null:
return $default(_that.id,_that.categoryId,_that.type,_that.title,_that.image,_that.audio,_that.description,_that.answers,_that.correctAnswerIds,_that.hint,_that.explanation,_that.difficulty,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId, @JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson)  QuestionType type,  String title,  String? image,  String? audio,  String? description,  List<AnswerModel> answers,  List<String> correctAnswerIds,  String? hint,  String? explanation,  String? difficulty,  int points)  $default,) {final _that = this;
switch (_that) {
case _QuestionModel():
return $default(_that.id,_that.categoryId,_that.type,_that.title,_that.image,_that.audio,_that.description,_that.answers,_that.correctAnswerIds,_that.hint,_that.explanation,_that.difficulty,_that.points);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId, @JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson)  QuestionType type,  String title,  String? image,  String? audio,  String? description,  List<AnswerModel> answers,  List<String> correctAnswerIds,  String? hint,  String? explanation,  String? difficulty,  int points)?  $default,) {final _that = this;
switch (_that) {
case _QuestionModel() when $default != null:
return $default(_that.id,_that.categoryId,_that.type,_that.title,_that.image,_that.audio,_that.description,_that.answers,_that.correctAnswerIds,_that.hint,_that.explanation,_that.difficulty,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuestionModel extends QuestionModel {
  const _QuestionModel({required this.id, required this.categoryId, @JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson) required this.type, required this.title, this.image, this.audio, this.description, required final  List<AnswerModel> answers, final  List<String> correctAnswerIds = const <String>[], this.hint, this.explanation, this.difficulty, this.points = 1}): _answers = answers,_correctAnswerIds = correctAnswerIds,super._();
  factory _QuestionModel.fromJson(Map<String, dynamic> json) => _$QuestionModelFromJson(json);

@override final  String id;
@override final  String categoryId;
@override@JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson) final  QuestionType type;
@override final  String title;
/// Optional media URL (Firestore Storage / HTTPS). Title is always required.
@override final  String? image;
/// Optional pre-recorded question audio (Firestore Storage / HTTPS).
/// When set, Listen mode plays this instead of device TTS.
@override final  String? audio;
@override final  String? description;
 final  List<AnswerModel> _answers;
@override List<AnswerModel> get answers {
  if (_answers is EqualUnmodifiableListView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_answers);
}

 final  List<String> _correctAnswerIds;
@override@JsonKey() List<String> get correctAnswerIds {
  if (_correctAnswerIds is EqualUnmodifiableListView) return _correctAnswerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_correctAnswerIds);
}

@override final  String? hint;
@override final  String? explanation;
@override final  String? difficulty;
@override@JsonKey() final  int points;

/// Create a copy of QuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuestionModelCopyWith<_QuestionModel> get copyWith => __$QuestionModelCopyWithImpl<_QuestionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuestionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuestionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.image, image) || other.image == image)&&(identical(other.audio, audio) || other.audio == audio)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._answers, _answers)&&const DeepCollectionEquality().equals(other._correctAnswerIds, _correctAnswerIds)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.points, points) || other.points == points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,categoryId,type,title,image,audio,description,const DeepCollectionEquality().hash(_answers),const DeepCollectionEquality().hash(_correctAnswerIds),hint,explanation,difficulty,points);

@override
String toString() {
  return 'QuestionModel(id: $id, categoryId: $categoryId, type: $type, title: $title, image: $image, audio: $audio, description: $description, answers: $answers, correctAnswerIds: $correctAnswerIds, hint: $hint, explanation: $explanation, difficulty: $difficulty, points: $points)';
}


}

/// @nodoc
abstract mixin class _$QuestionModelCopyWith<$Res> implements $QuestionModelCopyWith<$Res> {
  factory _$QuestionModelCopyWith(_QuestionModel value, $Res Function(_QuestionModel) _then) = __$QuestionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId,@JsonKey(fromJson: questionTypeFromJson, toJson: questionTypeToJson) QuestionType type, String title, String? image, String? audio, String? description, List<AnswerModel> answers, List<String> correctAnswerIds, String? hint, String? explanation, String? difficulty, int points
});




}
/// @nodoc
class __$QuestionModelCopyWithImpl<$Res>
    implements _$QuestionModelCopyWith<$Res> {
  __$QuestionModelCopyWithImpl(this._self, this._then);

  final _QuestionModel _self;
  final $Res Function(_QuestionModel) _then;

/// Create a copy of QuestionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? type = null,Object? title = null,Object? image = freezed,Object? audio = freezed,Object? description = freezed,Object? answers = null,Object? correctAnswerIds = null,Object? hint = freezed,Object? explanation = freezed,Object? difficulty = freezed,Object? points = null,}) {
  return _then(_QuestionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as QuestionType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,audio: freezed == audio ? _self.audio : audio // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as List<AnswerModel>,correctAnswerIds: null == correctAnswerIds ? _self._correctAnswerIds : correctAnswerIds // ignore: cast_nullable_to_non_nullable
as List<String>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,difficulty: freezed == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
