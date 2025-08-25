import 'user_model.dart';

class AuthResponseModel {
  final String token; // Access token
  final String? refreshToken; // Refresh token (nullable)
  final UserModel user;

  AuthResponseModel({
    required this.token,
    required this.user,
    this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'refresh_token': refreshToken,
      'user': user.toJson(),
    };
  }
}
