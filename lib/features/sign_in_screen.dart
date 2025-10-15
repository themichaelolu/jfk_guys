import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/controllers/sign_in_anonymously_controller.dart';
import 'package:jfk_guys/domain/controllers/sign_in_controller.dart';
import 'package:jfk_guys/features/home_screen.dart';
import 'package:jfk_guys/features/sign_up_screen.dart';
import 'package:jfk_guys/utils/asyncvalue_ui.dart';
import 'package:jfk_guys/utils/custom_loader.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isAnonymousLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast(context, "Please fill in all fields", isError: true);
      return;
    }

    if (!email.contains("@")) {
      _showToast(context, "Please enter a valid email", isError: true);
      return;
    }

    ref
        .read(loginControllerProvider.notifier)
        .signIn(
          email: email,
          password: password,
          context: context,
          afterFetched: () => Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const HomeScreen()),
          ),
        );
  }

  void _showToast(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      loginControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final loading = ref.watch(loginControllerProvider).isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _isAnonymousLoading
                        ? null
                        : () {
                            ref
                                .read(
                                  signInAnonymouslyControllerProvider.notifier,
                                )
                                .signInAnonymously(
                                  () => Navigator.of(context).pushReplacement(
                                    CupertinoPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  ),
                                );
                          },
                    child: currentUser == null
                        ? ref
                                  .watch(signInAnonymouslyControllerProvider)
                                  .isLoading
                              ? customLoader(Colors.grey)
                              : const Text(
                                  "Skip",
                                  style: TextStyle(color: Colors.grey),
                                )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Sign in to sync your jfk across devices",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Email"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "you@example.com",
                      ),
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 20),

                    const Text("Password"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      onSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: loading ? null : _handleLogin,
                      child: loading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: customLoader(
                                Theme.of(context).colorScheme.surface,
                              ),
                            )
                          : Text(
                              'Sign In',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const SignupScreen(),
                    ),
                  );
                },
                child: Text(
                  "Don't have an account? Sign up",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
