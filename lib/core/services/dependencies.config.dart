// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/license/data/datasources/device_id_service.dart'
    as _i535;
import '../../features/license/data/datasources/license_remote_datasource.dart'
    as _i862;
import '../../features/license/data/datasources/license_session_store.dart'
    as _i519;
import '../../features/license/data/repositories/license_repository_impl.dart'
    as _i14;
import '../../features/license/domain/repositories/license_repository.dart'
    as _i681;
import '../../features/license/domain/usecases/ensure_license_session_usecase.dart'
    as _i548;
import '../../features/license/presentation/cubit/license_cubit.dart' as _i447;
import '../../features/quiz/data/datasources/listen_mode_settings.dart'
    as _i310;
import '../../features/quiz/data/datasources/quiz_local_datasource.dart'
    as _i978;
import '../../features/quiz/data/datasources/quiz_media_cache.dart' as _i541;
import '../../features/quiz/data/datasources/quiz_narrator.dart' as _i169;
import '../../features/quiz/data/datasources/quiz_progress_migration.dart'
    as _i249;
import '../../features/quiz/data/datasources/quiz_remote_datasource.dart'
    as _i189;
import '../../features/quiz/data/repositories/quiz_repository_impl.dart'
    as _i656;
import '../../features/quiz/domain/repositories/quiz_repository.dart' as _i613;
import '../../features/quiz/domain/usecases/clear_bookmarks_usecase.dart'
    as _i739;
import '../../features/quiz/domain/usecases/clear_statistics_usecase.dart'
    as _i561;
import '../../features/quiz/domain/usecases/get_all_questions_usecase.dart'
    as _i912;
import '../../features/quiz/domain/usecases/get_answer_log_usecase.dart'
    as _i1014;
import '../../features/quiz/domain/usecases/get_bookmarked_ids_usecase.dart'
    as _i714;
import '../../features/quiz/domain/usecases/get_categories_usecase.dart'
    as _i564;
import '../../features/quiz/domain/usecases/get_results_usecase.dart' as _i912;
import '../../features/quiz/domain/usecases/get_stats_usecase.dart' as _i454;
import '../../features/quiz/domain/usecases/record_answer_usecase.dart'
    as _i694;
import '../../features/quiz/domain/usecases/save_result_usecase.dart' as _i344;
import '../../features/quiz/domain/usecases/sync_question_bank_usecase.dart'
    as _i415;
import '../../features/quiz/domain/usecases/toggle_bookmark_usecase.dart'
    as _i568;
import '../../features/quiz/presentation/bloc/bootstrap_bloc.dart' as _i940;
import '../../features/quiz/presentation/bloc/progress_bloc.dart' as _i567;
import '../../features/quiz/presentation/bloc/quiz_bloc.dart' as _i505;
import '../unified_api/dio/api_client.dart' as _i357;
import '../unified_api/dio/logger_interceptor.dart' as _i614;
import '../unified_api/dio/register_module.dart' as _i305;
import 'app_info_service.dart' as _i835;
import 'dependencies.dart' as _i372;
import 'hive/hive_boxes.dart' as _i324;
import 'sfx/app_sfx.dart' as _i407;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final registerModule = _$RegisterModule();
    gh.factory<_i558.FlutterSecureStorage>(() => storageModule.secureStorage);
    gh.lazySingleton<_i835.AppInfoService>(() => _i835.AppInfoService());
    gh.lazySingleton<_i324.HiveService>(() => _i324.HiveService());
    gh.lazySingleton<_i407.AppSfx>(() => _i407.AppSfx());
    gh.lazySingleton<_i614.LoggerInterceptor>(() => _i614.LoggerInterceptor());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.factory<_i862.LicenseRemoteDatasource>(
      () => _i862.LicenseRemoteDatasourceImpl(),
    );
    gh.lazySingleton<_i535.DeviceIdService>(
      () => _i535.DeviceIdService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i519.LicenseSessionStore>(
      () => _i519.LicenseSessionStore(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i189.QuizRemoteDatasource>(
      () => _i189.QuizRemoteDatasourceImpl(),
    );
    gh.factory<_i357.ApiClient>(
      () => _i357.ApiClient(
        gh<_i361.Dio>(),
        loggingInterceptor: gh<_i614.LoggerInterceptor>(),
        storage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i310.ListenModeSettings>(
      () => _i310.ListenModeSettings(gh<_i324.HiveService>()),
    );
    gh.factory<_i978.QuizLocalDatasource>(
      () => _i978.QuizLocalDatasourceImpl(gh<_i324.HiveService>()),
    );
    gh.factory<_i249.QuizProgressMigration>(
      () => _i249.QuizProgressMigration(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i324.HiveService>(),
      ),
    );
    gh.lazySingleton<_i541.QuizMediaCache>(
      () => _i541.QuizMediaCacheImpl(gh<_i324.HiveService>()),
    );
    gh.factory<_i681.LicenseRepository>(
      () => _i14.LicenseRepositoryImpl(
        gh<_i862.LicenseRemoteDatasource>(),
        gh<_i519.LicenseSessionStore>(),
        gh<_i535.DeviceIdService>(),
      ),
    );
    gh.lazySingleton<_i548.EnsureLicenseSessionUsecase>(
      () => _i548.EnsureLicenseSessionUsecase(gh<_i681.LicenseRepository>()),
    );
    gh.factory<_i447.LicenseCubit>(
      () => _i447.LicenseCubit(
        ensureSession: gh<_i548.EnsureLicenseSessionUsecase>(),
        repository: gh<_i681.LicenseRepository>(),
      ),
    );
    gh.lazySingleton<_i169.QuizNarrator>(
      () => _i169.QuizNarrator(gh<_i541.QuizMediaCache>()),
    );
    gh.factory<_i613.QuizRepository>(
      () => _i656.QuizRepositoryImpl(
        gh<_i189.QuizRemoteDatasource>(),
        gh<_i978.QuizLocalDatasource>(),
        gh<_i541.QuizMediaCache>(),
      ),
    );
    gh.factory<_i739.ClearBookmarksUsecase>(
      () => _i739.ClearBookmarksUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i561.ClearStatisticsUsecase>(
      () => _i561.ClearStatisticsUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i912.GetAllQuestionsUsecase>(
      () => _i912.GetAllQuestionsUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i1014.GetAnswerLogUsecase>(
      () => _i1014.GetAnswerLogUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i714.GetBookmarkedIdsUsecase>(
      () => _i714.GetBookmarkedIdsUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i564.GetCategoriesUsecase>(
      () => _i564.GetCategoriesUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i912.GetResultsUsecase>(
      () => _i912.GetResultsUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i454.GetStatsUsecase>(
      () => _i454.GetStatsUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i694.RecordAnswerUsecase>(
      () => _i694.RecordAnswerUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i344.SaveResultUsecase>(
      () => _i344.SaveResultUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i415.SyncQuestionBankUsecase>(
      () => _i415.SyncQuestionBankUsecase(gh<_i613.QuizRepository>()),
    );
    gh.factory<_i568.ToggleBookmarkUsecase>(
      () => _i568.ToggleBookmarkUsecase(gh<_i613.QuizRepository>()),
    );
    gh.lazySingleton<_i567.ProgressBloc>(
      () => _i567.ProgressBloc(
        getCategories: gh<_i564.GetCategoriesUsecase>(),
        getAllQuestions: gh<_i912.GetAllQuestionsUsecase>(),
        getBookmarkedIds: gh<_i714.GetBookmarkedIdsUsecase>(),
        toggleBookmark: gh<_i568.ToggleBookmarkUsecase>(),
        getAnswerLog: gh<_i1014.GetAnswerLogUsecase>(),
        getResults: gh<_i912.GetResultsUsecase>(),
        getStats: gh<_i454.GetStatsUsecase>(),
        saveResult: gh<_i344.SaveResultUsecase>(),
        syncQuestionBank: gh<_i415.SyncQuestionBankUsecase>(),
        clearStatistics: gh<_i561.ClearStatisticsUsecase>(),
        clearBookmarks: gh<_i739.ClearBookmarksUsecase>(),
      ),
    );
    gh.factory<_i505.QuizBloc>(
      () => _i505.QuizBloc(recordAnswer: gh<_i694.RecordAnswerUsecase>()),
    );
    gh.factory<_i940.BootstrapBloc>(
      () => _i940.BootstrapBloc(
        syncQuestionBank: gh<_i415.SyncQuestionBankUsecase>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i372.StorageModule {}

class _$RegisterModule extends _i305.RegisterModule {}
