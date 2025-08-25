import 'package:dio/dio.dart';
import 'package:new_note_app/features/auth/data/models/auth_response_model.dart';
import 'package:new_note_app/features/auth/data/models/refresh_response_model.dart';
import 'package:new_note_app/features/auth/data/models/user_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio});

  Future<AuthResponseModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/jwt/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponseModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/auth/jwt/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('Error during signup: ${e.message}');
      rethrow;

    }
  }

  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final response = await dio.post(
        '/auth/oauth/google',
        data: {'id_token': idToken},
        
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<RefreshResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      
      );
      return RefreshResponseModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser(String accessToken) async {
    try {
      final response = await dio.get(
        '/users/me',
       
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> logout({required String refreshToken}) async {
  try {
    final response = await dio.post(
      '/auth/logout',
      data: {
        'refresh_token': refreshToken,
      },
     
    );

    print('LOGOUT RESPONSE: ${response.data}');
  } catch (e) {
    rethrow;
  }
}
}
