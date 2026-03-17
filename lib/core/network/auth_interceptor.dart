import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  // ARL Token/Cookie string. We need a way to retrieve it.
  // For now, we will assume the token manager provides it.
  String? _arlToken;

  void setArlToken(String token) {
    _arlToken = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_arlToken != null && _arlToken!.isNotEmpty) {
      if (options.uri.host.contains('API_HOST_FROM_ENV')) {
        // If connecting to the remote streaming provider, add auth cookie 
        // to bypass limits or access private data
        options.headers['Cookie'] = 'arl=$_arlToken'; // standard authentication
      }
    }
    super.onRequest(options, handler);
  }
}
