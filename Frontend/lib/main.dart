import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:new_note_app/core/network/token_interceptor.dart';
import 'package:new_note_app/core/constants/constants.dart';

// Auth imports
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/data/auth_remote_data_source.dart';

// Notes imports
import 'features/notes/bloc/note_bloc.dart';
import 'features/notes/data/note_remote_data_source.dart';
import 'features/notes/note_repository.dart';

// common
import 'core/secure_storage.dart';

// UI
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/signup_page.dart';

///  description of Global RouteObserver 
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // create dio instance
    final dio = Dio(BaseOptions(
  baseUrl: ApiConstants.baseUrl,
  headers: {'Content-Type': 'application/json'},
  connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
  receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
));

    // common services
    final secureStorage = SecureStorage();

     final authRepository = AuthRepository(
      remoteDataSource: AuthRemoteDataSource(dio: dio),
      secureStorage: secureStorage,
    );

     final noteRepository = NoteRepository(
      remoteDataSource: NoteRemoteDataSource(dio: dio, secureStorage: secureStorage),
    );

    return MultiRepositoryProvider(
      providers: [
        // Auth Repository
        RepositoryProvider<AuthRepository>(
          create: (_) => authRepository,
        ),
        // Note Repository
        RepositoryProvider<NoteRepository>(
          create: (_) => noteRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<NoteBloc>(
            create: (context) => NoteBloc(
              noteRepository: context.read<NoteRepository>(),
            ),
          ),
        ],
          child: Builder( 
      builder: (context) {
        dio.interceptors.add(
          TokenInterceptor(
            dio: dio,
            authRepository: authRepository,
            secureStorage: secureStorage,
            onLogout: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Note App',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomePage(),
            '/signup': (context) => const SignupPage(),
          },

          ///  adding RouteObserver 
          navigatorObservers: [routeObserver],
         );
      },
    ),
  ),
);
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess) {
          return const HomePage();
        } else if (state is AuthFailure || state is AuthInitial) {
          return const LoginPage();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
