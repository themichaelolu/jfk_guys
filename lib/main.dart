import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/domain/providers/theme_provider.dart';
import 'package:jfk_guys/features/home_screen.dart';
import 'package:jfk_guys/features/sign_in_screen.dart';
import 'package:jfk_guys/firebase_options.dart';
import 'constants/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseFirestore.instance.settings = const Settings(
  //   persistenceEnabled: false,
  // );
  runApp(const ProviderScope(child: JFKGuysApp()));
}

class JFKGuysApp extends ConsumerWidget {
  const JFKGuysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeControllerProvider);

    return themeModeAsync.when(
      data: (themeMode) => MaterialApp(
        title: 'SplitEasy',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeAnimationDuration: Duration.zero, // 👈 prevents animation
        themeAnimationCurve: Curves.linear,
        themeMode: themeMode,
        home: const AuthGate(),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const MaterialApp(
        home: Scaffold(body: Center(child: Text("Error loading theme"))),
      ),
    );
  }
}

/// AuthGate listens to FirebaseAuth user state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // ✅ User is logged in → go to home
          return const HomeScreen();
        } else {
          // ❌ User not logged in → go to login
          return const LoginScreen();
        }
      },
    );
  }
}
