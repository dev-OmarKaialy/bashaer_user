import 'dart:core';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'error_model.dart';
import 'failure.dart';

mixin HandlingException {
  Future<Either<Failure, T>> wrapHandling<T>({required Future<T> Function() tryCall}) async {
    try {
      final result = await tryCall();
      // on succes
      log(result.toString());
      return Right(result);
    } catch (e) {
      return Left(ErrorHandler.handle(e).failure);
    }
    // final result = await fuction();
    // return Right(jsonConvert(result.data));
  }
}

class ErrorHandler implements Exception {
  late Failure failure;

  ErrorHandler.handle(error) {
    if (error is DioException) {
      // dio error so its an error from response of the API or from dio itself
      failure = _handleError(error);
    } else {
      log(error.toString());
      // default error
      failure = const ServerFailure(
        message: 'Default Error',
        statusCode: ResponseCode.BAD_REQUEST_Server,
      );
    }
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return DataSource.CONNECT_TIMEOUT.getFailure();
      case DioExceptionType.sendTimeout:
        return DataSource.SEND_TIMEOUT.getFailure();
      case DioExceptionType.receiveTimeout:
        return DataSource.RECIEVE_TIMEOUT.getFailure();
      case DioExceptionType.cancel:
        return DataSource.CANCEL.getFailure();
      case DioExceptionType.unknown:
        return DataSource.DEFAULT.getFailure();
      case DioExceptionType.badCertificate:
        return DataSource.BAD_REQUEST.getFailure();
      case DioExceptionType.connectionError:
        return DataSource.NO_INTERNET_CONNECTION.getFailure();
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case ResponseCode.INTERNAL_SERVER_ERROR:
            return DataSource.INTERNAL_SERVER_ERROR.getFailure();
          case ResponseCode.NOT_FOUND:
            return DataSource.NOT_FOUND.getFailure();
          case ResponseCode.FORBIDDEN:
            return DataSource.FORBIDDEN.getFailure();
          case ResponseCode.UNAUTHORISED:
            return UnauthenticatedFailure(message: error.message!);
          case ResponseCode.Bad_Content:
            return ServerFailure(
              message: ErrorMessageModel.fromJson(error.response?.data).statusMessage,
              statusCode: ResponseCode.Bad_Content,
            );
          case ResponseCode.BAD_REQUEST_Server:
            return ServerFailure(
              message: ErrorMessageModel.fromJson(error.response?.data).statusMessage,
              statusCode: ResponseCode.BAD_REQUEST_Server,
            );
          default:
            return ServerFailure(
              message: error.response?.data is! Map
                  ? 'Cant parse'
                  : error.response?.data["errors"]?.toString() ??
                        error.response?.data["message"]?.toString() ??
                        '',
              statusCode: error.response?.statusCode ?? ResponseCode.BAD_REQUEST,
            );
        }
      default:
        return DataSource.DEFAULT.getFailure();
    }
  }
}

extension DataSourceExtension on DataSource {
  Failure getFailure() {
    switch (this) {
      case DataSource.UNCONFIRMED:
        return const ServerFailure(message: '');
      case DataSource.SUCCESS:
        return const ServerFailure(statusCode: ResponseCode.SUCCESS, message: '');
      case DataSource.NO_CONTENT:
        return const ServerFailure(statusCode: ResponseCode.NO_CONTENT, message: '');
      case DataSource.BAD_REQUEST:
        return const ServerFailure(statusCode: ResponseCode.BAD_REQUEST, message: '');
      case DataSource.FORBIDDEN:
        return const ServerFailure(statusCode: ResponseCode.FORBIDDEN, message: '');
      case DataSource.UNAUTORISED:
        return const ServerFailure(statusCode: ResponseCode.UNAUTHORISED, message: '');
      case DataSource.NOT_FOUND:
        return const ServerFailure(statusCode: ResponseCode.NOT_FOUND, message: '');
      case DataSource.INTERNAL_SERVER_ERROR:
        return const ServerFailure(statusCode: ResponseCode.INTERNAL_SERVER_ERROR, message: '');
      case DataSource.CONNECT_TIMEOUT:
        return const ServerFailure(statusCode: ResponseCode.CONNECT_TIMEOUT, message: '');
      case DataSource.CANCEL:
        return const ServerFailure(statusCode: ResponseCode.CANCEL, message: '');
      case DataSource.RECIEVE_TIMEOUT:
        return const ServerFailure(statusCode: ResponseCode.RECIEVE_TIMEOUT, message: '');
      case DataSource.SEND_TIMEOUT:
        return const ServerFailure(statusCode: ResponseCode.SEND_TIMEOUT, message: '');
      case DataSource.CACHE_ERROR:
        return const ServerFailure(statusCode: ResponseCode.CACHE_ERROR, message: '');
      case DataSource.NO_INTERNET_CONNECTION:
        return const ServerFailure(statusCode: ResponseCode.NO_INTERNET_CONNECTION, message: '');
      case DataSource.DEFAULT:
        return const ServerFailure(statusCode: ResponseCode.DEFAULT, message: '');
    }
  }
}

class ResponseCode {
  static const int SUCCESS = 200; // success with data
  static const int NO_CONTENT = 201; // success with no data (no content)
  static const int BAD_REQUEST = 400; // ServerFailure, API rejected request
  static const int UNAUTHORISED = 401; // failure, user is not authorised
  static const int UNCONDIRMED = 409; // failure, user is not confirmed
  static const int FORBIDDEN = 403; //  failure, API rejected request
  static const int INTERNAL_SERVER_ERROR = 500; // failure, crash in server side
  static const int NOT_FOUND = 404; // failure, not found
  static const int NOT_ALLOWED = 405; // failure, not allowed
  static const int BLOCKED = 420; // failure,blocked
  static const int Bad_Content = 422; // failure, Bad_Content
  static const int BAD_REQUEST_Server = 402; // ServerFailure, API rejected request

  // local status code
  static const int CONNECT_TIMEOUT = -1;
  static const int CANCEL = -2;
  static const int RECIEVE_TIMEOUT = -3;
  static const int SEND_TIMEOUT = -4;
  static const int CACHE_ERROR = -5;
  static const int NO_INTERNET_CONNECTION = -6;
  static const int DEFAULT = -7;
}

class ApiInternalStatus {
  static const int SUCCESS = 0;
  static const int FAILURE = 1;
}

// ignore_for_file: constant_identifier_names
enum DataSource {
  SUCCESS,
  NO_CONTENT,
  BAD_REQUEST,
  FORBIDDEN,
  UNAUTORISED,
  UNCONFIRMED,
  NOT_FOUND,
  INTERNAL_SERVER_ERROR,
  CONNECT_TIMEOUT,
  CANCEL,
  RECIEVE_TIMEOUT,
  SEND_TIMEOUT,
  CACHE_ERROR,
  NO_INTERNET_CONNECTION,
  DEFAULT,
}
