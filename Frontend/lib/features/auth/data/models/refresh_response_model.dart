class RefreshResponseModel {
  final String token; // Access token
  final String refreshToken; // Refresh token (nullable)


  RefreshResponseModel({
    required this.token,
    required this.refreshToken,
  });

  factory RefreshResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshResponseModel(
      token: json['access_token'] ?? json['token'],
      refreshToken: json['refresh_token'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'refresh_token': refreshToken,
    };
  }
}
