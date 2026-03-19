import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio {
    String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    if (!baseUrl.endsWith('/')) {
      baseUrl += '/';
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': dotenv.env['API_KEY'] ?? '',
          if ((dotenv.env['PROVIDER_ARL'] ?? '').isNotEmpty)
            'X-Stream-Auth': dotenv.env['PROVIDER_ARL']!,
        },
      ),
    );

    return dio;
  }
}
