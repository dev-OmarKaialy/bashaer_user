import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/type_defs.dart';
import 'error_handeler.dart';
import 'failure.dart';

mixin HandlingApiManager {
  Future<T> wrapHandlingApi<T>({
    required Future<Response> Function() tryCall,
    required FromJson<T> jsonConvert,
  }) async {
    try {
      final response = await tryCall();
      if (response.statusCode == ResponseCode.SUCCESS) {
        return jsonConvert(jsonEncode(response.data));
      } else {
        throw ServerFailure(
          message: response.data["message"].toString(),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
