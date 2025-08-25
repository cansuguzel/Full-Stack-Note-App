import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// login with email and password
class LoginWithEmail extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// login with Google ID Token
class LoginWithGoogle extends AuthEvent {
  final String idToken;

  const LoginWithGoogle({required this.idToken});

  @override
  List<Object?> get props => [idToken];
}

class AuthCheckRequested extends AuthEvent {}
class RefreshTokenRequested extends AuthEvent {}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

   
  const SignupRequested({
    required this.email,
    required this.password,
    required this.name,
  });
  
  @override
  List<Object?> get props => [email, password, name];
}


// logout
class LogoutRequested extends AuthEvent {}
