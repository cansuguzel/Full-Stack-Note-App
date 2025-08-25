import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class SecureStorage {
  final _storage = const FlutterSecureStorage();

  // ACCESS TOKEN
  Future<void> writeAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  Future<String?> readAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
  }

  // REFRESH TOKEN
  Future<void> writeRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
