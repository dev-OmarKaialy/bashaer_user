import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'dependencies.config.dart';

final getIt = GetIt.instance;

@InjectableInit(initializerName: 'initGetIt', preferRelativeImports: true, asExtension: true)
void configureDependencies() {
  getIt.initGetIt();
}

@module
abstract class StorageModule {
  @injectable
  FlutterSecureStorage get secureStorage =>
      const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));
}
