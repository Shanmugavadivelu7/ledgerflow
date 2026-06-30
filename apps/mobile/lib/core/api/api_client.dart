import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = _build();

  static Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Content-Type": "application/json"},
      ),
    );

    if (kDebugMode) {
      d.interceptors.add(
        InterceptorsWrapper(
          onRequest: (opts, handler) {
            debugPrint('[API] ${opts.method} ${opts.path}');
            handler.next(opts);
          },
          onResponse: (res, handler) {
            debugPrint('[API] ${res.statusCode} ${res.requestOptions.path}');
            handler.next(res);
          },
          onError: (err, handler) {
            debugPrint('[API ERROR] ${err.requestOptions.path} → ${err.message}');
            if (err.response != null) {
              debugPrint('[API ERROR] body: ${err.response?.data}');
            }
            handler.next(err);
          },
        ),
      );
    }

    return d;
  }
}