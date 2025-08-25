import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Email/Password login
    on<LoginWithEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.loginWithEmail(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    // Google login
    on<LoginWithGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.loginWithGoogle(
          idToken: event.idToken,
        );
        emit(AuthSuccess(user: user));
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });


// auth check when app starts
on<AuthCheckRequested>((event, emit) async {
  //emit(AuthLoading());
  try {
    // take the user,if there is no access token then it will throw an exception
    final user = await authRepository.getCurrentUser();
    // user cannot be null,so directly AuthSuccess
    emit(AuthSuccess(user: user));
  } catch (e) {
    // if token is missing or invalid
    emit(AuthInitial()); 
  }
});

on<SignupRequested>((event, emit) async {
  emit(AuthLoading());
  try {
    final user = await authRepository.signup(
      email: event.email,
      password: event.password,
      name: event.name,
    );
    emit(AuthSuccess(user: user));
  } catch (e) {
    emit(AuthFailure(message: e.toString()));
  }
});


    // Logout
on<LogoutRequested>((event, emit) async {
  emit(AuthLoading()); 
  try {
    await authRepository.logout();
    emit(AuthInitial()); // user is now logged out
  } catch (e) {
    emit(AuthFailure(message: "Logout failed: $e"));
  }
});

}
}
