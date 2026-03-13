import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/instructor/instructor_home_screen.dart';

class ClassCheckApp extends StatefulWidget {
  const ClassCheckApp({super.key});

  @override
  State<ClassCheckApp> createState() => _ClassCheckAppState();
}

class _ClassCheckAppState extends State<ClassCheckApp> {
  @override
  void initState() {
    super.initState();
    // Auto-close expired sessions on app start
    FirestoreService().closeExpiredSessions();
  }

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
  late final Stream<User?> _authStream;
  bool _pendingSignOut = false;

  @override
  void initState() {
    super.initState();
    // Cache stream to avoid re-subscriptions on rebuild
    _authStream = _authService.authStateChanges;
  }

  void _safeSignOut() {
    if (_pendingSignOut) return;
    _pendingSignOut = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authService.signOut();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserModel?>(
            future: _authService.getUserProfile(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError) {
                _safeSignOut();
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final user = userSnapshot.data;
              if (user == null) {
                _safeSignOut();
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Reset flag on successful profile load
              _pendingSignOut = false;

              if (user.isInstructor) {
                return const InstructorHomeScreen();
              }
              return const StudentHomeScreen();
            },
          );
        }

        // Not authenticated — reset flag and show login
        _pendingSignOut = false;
        return const LoginScreen();
      },
    );
  }
}
