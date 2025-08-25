import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_note_app/core/constants/constants.dart';
import 'package:new_note_app/features/auth/bloc/auth_bloc.dart';
import 'package:new_note_app/features/auth/bloc/auth_event.dart';
import 'package:new_note_app/features/auth/bloc/auth_state.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
  serverClientId: ApiConstants.googleServerClientId,
);

 
class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

 void _onGoogleLoginPressed() async {
  try {
    final account = await _googleSignIn.signIn();
    if (account == null) {
    
      return;
    }
    final googleAuth = await account.authentication;
    final idToken = googleAuth.idToken;

    if (idToken != null) {
      if (!mounted) return;
      context.read<AuthBloc>().add(
        LoginWithGoogle(idToken: idToken),
      );
    } else {
      print("the google id token cannot be taken.");
    }
  } catch (e) {
    print("google login error: $e");
  }
}


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

void _showErrorDialog(String message) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _onLoginPressed() {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showErrorDialog("Please fill in all fields.");
    return;
  }

  context.read<AuthBloc>().add(
    LoginWithEmail(email: email, password: password),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              _showErrorDialog(state.message);
            } else if (state is AuthSuccess) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height,
    ),
    child: IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/images/cute_asset.png',
              width: 200,
            ),
          ),
                  const SizedBox(height: 10),

                  // Email
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        }),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Remember me + Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                          ),
                          const Text("Remember Me"),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          
                        },
                        child: const Text("Forgot Password?"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Login button
                  ElevatedButton(
                    onPressed: state is AuthLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login"),
                  ),
                  const SizedBox(height: 20),

                  const Center(child: Text("or")),
                  const SizedBox(height: 10),

                  // Google Login
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          state is AuthLoading ? null : _onGoogleLoginPressed,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(10),
                        backgroundColor: Colors.white,
                        elevation: 3,
                      ),
                      child: Image.asset(
                        'assets/images/google_asset.png',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // navigate to Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          "Create one!",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
          },
        ),
      ),
    );
  }
}
