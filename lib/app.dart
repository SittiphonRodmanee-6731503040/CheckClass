import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/instructor/instructor_home_screen.dart';

class ClassCheckApp extends StatelessWidget {
  const ClassCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassCheck',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  late final StreamSubscription<User?> _authSub;

  bool _loading = true;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      if (mounted) setState(() { _userModel = null; _loading = false; });
      return;
    }

    if (mounted) setState(() => _loading = true);

    try {
      final profile = await _authService.getUserProfile(firebaseUser.uid);
      if (mounted) setState(() { _userModel = profile; _loading = false; });

      // Run session cleanup only when an authenticated user is available
      if (profile != null && profile.isInstructor) {
        FirestoreService().closeExpiredSessions();
      }
    } catch (_) {
      if (mounted) setState(() { _userModel = null; _loading = false; });
    }
  }

  Future<void> _retry() async {
    final user = _authService.currentUser;
    if (user != null) {
      _onAuthChanged(user);
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final firebaseUser = _authService.currentUser;

    // Not signed in
    if (firebaseUser == null) {
      return const LoginScreen();
    }

    // Signed in but profile not found — show retry instead of auto-signout
    if (_userModel == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load your profile.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retry,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await _authService.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    if (_userModel!.isInstructor) {
      return const InstructorHomeScreen();
    }
    return const StudentHomeScreen();
  }
}
