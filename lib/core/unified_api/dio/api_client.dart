import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'logger_interceptor.dart';

@injectable
class ApiClient {
  final LoggerInterceptor loggingInterceptor;
  late Dio dio;
  final FlutterSecureStorage storage;
  ApiClient(Dio dioC, {required this.loggingInterceptor, required this.storage}) {
    dio = dioC;
    dio
      ..options.connectTimeout = const Duration(milliseconds: 30000)
      ..options.receiveTimeout = const Duration(milliseconds: 30000)
      ..httpClientAdapter
      ..options.headers = {'Accept': 'application/json', "token": ''};
    log(dio.options.headers.toString());
    dio.interceptors.clear();
    dio.interceptors.addAll([loggingInterceptor]);
  }
  Future<void> resetHeader() async {
    dio
      ..options.connectTimeout = const Duration(milliseconds: 30000)
      ..options.receiveTimeout = const Duration(milliseconds: 30000)
      ..httpClientAdapter
      ..options.headers = {
        'Accept': 'application/json',
        if ((await storage.read(key: 'token')) != null) "token": (await storage.read(key: 'token')),
      };
    dio.interceptors.clear();
    dio.interceptors.add(loggingInterceptor);
  }

  Future<Response> get(
    Uri uri, {
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    data,
  }) async {
    await resetHeader();
    return await dio.getUri(
      uri,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> post(
    Uri uri, {
    data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await resetHeader();
    return await dio.postUri(
      uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> put(
    Uri uri, {
    data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    await resetHeader();

    return await dio.putUri(
      uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response> delete(
    Uri uri, {

    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await resetHeader();

    return await dio.deleteUri(uri, data: data, options: options, cancelToken: cancelToken);
  }
}
