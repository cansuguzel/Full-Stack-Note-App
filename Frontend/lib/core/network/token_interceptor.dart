import 'package:dio/dio.dart';
import 'dart:async';
import 'package:new_note_app/core/secure_storage.dart';
import 'package:new_note_app/features/auth/auth_repository.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final AuthRepository authRepository;
  final SecureStorage secureStorage;
  final void Function()? onLogout;

  bool _isRefreshing = false;
  bool _refreshFailed = false;      // is refresh  take 401/403/400?
  bool _logoutInProgress = false;   // is it logout in progress?
  final List<Completer<Response>> _pendingRequests = [];

  TokenInterceptor({
    required this.dio,
    required this.authRepository,
    required this.secureStorage,
    this.onLogout,
  });

  bool _isRefreshRequest(RequestOptions o) => o.path.contains('/auth/refresh');
  bool _isAuthFailure(DioException e) {
    final sc = e.response?.statusCode;
    return sc == 401 || sc == 403 || sc == 400;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // add Authorization header for refresh token request
      if (_isRefreshRequest(options)) {
        handler.next(options);
        return;
      }

      final token = await secureStorage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (_) {
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {

    // 1) if refresh request failed with auth error then move to failure
    if (_isRefreshRequest(err.requestOptions) && _isAuthFailure(err)) {
      await _handleRefreshFailure(err, handler);
      return;
    }

    // 2) Protected endpoint take 401 
    if (err.response?.statusCode == 401) {
      
      // b) if refresh doesnt start yet -> start
      if (!_isRefreshing) {
        _isRefreshing = true;

        final completer = Completer<Response>();
        _pendingRequests.add(completer);

        try {
          final newAccessToken = await authRepository.refreshAccessToken();

          if (newAccessToken != null) {
            // Refresh is successful-> retry all pending requests
            for (var pending in _pendingRequests) {
              if (!pending.isCompleted) {
                pending.complete(await _retry(err.requestOptions, newAccessToken));
              }
            }
            _pendingRequests.clear();

            final response = await completer.future;
            handler.resolve(response);
            return;
          } else {
            //  refresh come back with null (repo caught 401/403/400 ) -> failure
            await _handleRefreshFailure(err, handler);
            return;
          }
        } catch (e) {
          await _handleRefreshFailure(err, handler);
          return;
        } finally {
          _isRefreshing = false; // reset for every scenario
        }
      }
         if (_refreshFailed || _logoutInProgress) {
        await _handleRefreshFailure(err, handler);
        return;
      }

      // if refresh failed or logout is in progress, we don't want to queue
      if (!_refreshFailed && !_logoutInProgress) {
        final completer = Completer<Response>();
        _pendingRequests.add(completer);
        completer.future.then((response) => handler.resolve(response)).catchError((e) => handler.reject(e));
        return;
      } else {
       //if refresh failed or logout is in progress, we don't want to queue
        await _handleRefreshFailure(err, handler);
        return;
      }
    }

    // 3) normal flow for other errors
    handler.next(err);
  }

  //  we called 400, 401, 403 from one point when refresh failed
  Future<void> _handleRefreshFailure(DioException err, ErrorInterceptorHandler handler) async {
    if (_logoutInProgress) {
      // İdempotent: run for two times
      handler.reject(err);
      return;
    }

    _refreshFailed = true;
    _logoutInProgress = true;
    _isRefreshing = false;

    // complete all pending requests with error
    for (var pending in _pendingRequests) {
      if (!pending.isCompleted) {
        pending.completeError(DioException(
          requestOptions: err.requestOptions,
          error: 'Session expired',
          response: Response(requestOptions: err.requestOptions, statusCode: 401),
          type: DioExceptionType.badResponse,
        ));
      }
    }
    _pendingRequests.clear();

    // clear secure storage and notify logout
    try {
      await secureStorage.clearAll();
    } catch (_) {}
    onLogout?.call();
  }

  Future<Response> _retry(RequestOptions requestOptions, String newToken) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newToken',
      },
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
    );

    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
