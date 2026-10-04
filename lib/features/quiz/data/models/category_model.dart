import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
sealed class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    String? icon,
    String? description,
    @Default(0) int questionCount,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

  static CategoryModel CategoryModelFromJson(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return CategoryModel.fromJson(decoded);
  }
}
