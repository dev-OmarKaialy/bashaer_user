import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/unified_api/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/quiz_repository.dart';

@injectable
class GetCategoriesUsecase implements UseCase<List<CategoryModel>, NoParams> {
  GetCategoriesUsecase(this._repository);

  final QuizRepository _repository;

  @override
  Future<Either<Failure, List<CategoryModel>>> call(NoParams params) {
    return _repository.getCategories();
  }
}
