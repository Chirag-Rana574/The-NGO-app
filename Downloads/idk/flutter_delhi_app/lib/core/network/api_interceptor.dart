import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiInterceptor extends Interceptor {
  final String? authToken;

  ApiInterceptor({this.authToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (authToken != null) {
      options.headers['Authorization'] = 'Bearer $authToken';
    }
    options.headers['Content-Type'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful responses in debug mode
    assert(() {
      debugPrint('API Response: ${response.statusCode} ${response.requestOptions.path}');
      return true;
    }());
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log errors in debug mode
    assert(() {
      debugPrint('API Error: ${err.response?.statusCode} ${err.requestOptions.path}');
      debugPrint('Error message: ${err.message}');
      return true;
    }());
    super.onError(err, handler);
  }
}
