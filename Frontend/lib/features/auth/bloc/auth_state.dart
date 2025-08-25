import 'package:equatable/equatable.dart';
import '../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// initial state
class AuthInitial extends AuthState {}

// loading state
class AuthLoading extends AuthState {}

// successful login state (user and token are stored)
class AuthSuccess extends AuthState {
  final UserModel user;


  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

// when an error occurs
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

