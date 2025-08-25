import 'package:new_note_app/features/auth/data/models/refresh_response_model.dart';

import 'data/models/user_model.dart';
import 'data/auth_remote_data_source.dart';
import 'data/models/auth_response_model.dart';
import '../../core/secure_storage.dart';
import 'package:dio/dio.dart';


class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepository({required this.remoteDataSource, required this.secureStorage});

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.loginWithEmail(
      email: email,
      password: password,
    );
    await _saveTokens(result);
    return result.user;
  }

  Future<UserModel> loginWithGoogle({required String idToken}) async {
    final result = await remoteDataSource.loginWithGoogle(idToken: idToken);
    await _saveTokens(result);
    return result.user;
  }

  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await remoteDataSource.signup(
      email: email,
      password: password,
      name: name,
    );
    await _saveTokens(result);
    return result.user;
  }

  Future<void> logout() async {
  final refreshToken = await secureStorage.readRefreshToken();
  if (refreshToken != null) {
    await remoteDataSource.logout(refreshToken: refreshToken);
  }
}


Future<String?> refreshAccessToken() async {
  try {
    final refreshToken = await secureStorage.readRefreshToken();
    if (refreshToken == null) return null;

    final result = await remoteDataSource.refreshToken(refreshToken);
    await _saveRefreshTokens(result);

    // come back with new access token
    return result.token;
  } on DioException catch (e) {
    // logout for just refresh token is invalid
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      await secureStorage.clearAll(); 
      return null;
    }
    rethrow;
  }
}


  Future<UserModel> getCurrentUser() async {
    final accessToken = await secureStorage.readAccessToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }
    final user = await remoteDataSource.getCurrentUser(accessToken);
    return user;
  }

Future<void> _saveTokens(AuthResponseModel result) async {
  await secureStorage.writeAccessToken(result.token);
  if (result.refreshToken != null) {
    await secureStorage.writeRefreshToken(result.refreshToken!);
  }
}

Future<void> _saveRefreshTokens(RefreshResponseModel result) async {
  await secureStorage.writeAccessToken(result.token);
  await secureStorage.writeRefreshToken(result.refreshToken);
  
}
}
