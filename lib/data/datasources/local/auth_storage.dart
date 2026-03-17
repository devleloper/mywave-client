import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class AuthStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}

@LazySingleton(as: AuthStorage)
class AuthStorageImpl implements AuthStorage {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'auth_token';

  AuthStorageImpl() : _storage = const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
