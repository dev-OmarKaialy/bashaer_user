import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../unified_api/error/failure.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  Map<String, dynamic> getBody() => {};

  Map<String, String> getParams() => {};

  @override
  List<Object> get props => [];
}
