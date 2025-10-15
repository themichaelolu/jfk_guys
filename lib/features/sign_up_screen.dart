import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/controllers/sign_in_anonymously_controller.dart';
import 'package:jfk_guys/domain/controllers/sign_up_controller.dart';
import 'package:jfk_guys/features/home_screen.dart';
import 'package:jfk_guys/utils/asyncvalue_ui.dart';
import 'package:jfk_guys/utils/custom_loader.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showToast("Please fill in all fields", isError: true);
      return;
    }

    if (!email.contains("@")) {
      _showToast("Please enter a valid email", isError: true);
      return;
    }

    if (password.length < 6) {
      _showToast("Password must be at least 6 characters", isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showToast("Passwords do not match", isError: true);
      return;
    }

    ref
        .read(signUpControllerProvider.notifier)
        .signUp(
          email: email,
          name: name,
          password: password,
          afterFetched: () => Navigator.of(
            context,
          ).push(CupertinoPageRoute(builder: (context) => HomeScreen())),
        );
  }

  void _showToast(String message, {bool isError = false}) {
    final color = isError ? Colors.red : Colors.green;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      signUpControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    final loading = ref.watch(signUpControllerProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                    label: const Text(
                      "Back to Login",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
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
                        child:
                            ref
                                .watch(signInAnonymouslyControllerProvider)
                                .isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: customLoader(Colors.grey),
                              )
                            : const Text(
                                "Skip",
                                style: TextStyle(color: Colors.grey),
                              ),
                      ),
                    ],
                  ),
                  const Text(
                    "JFK with your guys, no stress",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                    // Full Name
                    const Text("Full Name"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "John Doe",
                      ),
                      onSubmitted: (_) => _handleSignup(),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    const Text("Email"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "you@example.com",
                      ),
                      onSubmitted: (_) => _handleSignup(),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    const Text("Password"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "At least 6 characters",
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
                      onSubmitted: (_) => _handleSignup(),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password
                    const Text("Confirm Password"),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Re-enter your password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _handleSignup(),
                    ),
                    const SizedBox(height: 30),

                    // Create Account Button
                    ElevatedButton(
                      onPressed: loading ? null : _handleSignup,

                      child: loading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: customLoader(
                                Theme.of(context).colorScheme.surface,
                              ),
                            )
                          : Text(
                              "Create Account",
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
                onPressed: () {},
                child: const Text("Already have an account? Sign in"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
