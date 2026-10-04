import 'dart:developer';

import '../extensions/log_colors_extension.dart';
import '../utils/type_defs.dart';

class ApiVariables {
  /////////////
  ///General///
  /////////////
  final _scheme = 'https';
  final _host = 'islamicapi.com';
  // final _port = 5000;

  Uri _mainUri({required String path, Map<String, dynamic>? queryParameters}) {
    final uri = Uri(
      scheme: _scheme,
      host: _host,
      // port: _port,
      path: '/api/v1/$path',
      queryParameters: queryParameters,
    );
    log(uri.toString().logMagenta);
    return uri;
  }

  Uri getAsmaaAllahUri({ParamsMap? params}) =>
      _mainUri(path: 'asma-ul-husna/', queryParameters: params);

  Uri checkVersion() => _mainUri(path: 'app-version/check');

  Uri getAppFile() => _mainUri(path: 'app-version/download');
}
