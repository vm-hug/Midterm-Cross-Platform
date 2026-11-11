import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/cloudinary_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/setup_screen.dart';
import 'widgets/common.dart';

class UserAdminApp extends StatelessWidget {
  const UserAdminApp({super.key, this.startupError});
  final Object? startupError;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'UserSpace • Quản lý sản phẩm',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: startupError != null
        ? SetupScreen(error: startupError!)
        : AuthGate(auth: AuthService(FirebaseAuth.instance)),
  );
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth});
  final AuthGateway auth;
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _session = widget.auth.authStateChanges();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: _session,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: ErrorMessage(
              'Không thể đọc phiên đăng nhập.',
              onRetry: () async {
                await widget.auth.signOut();
              },
            ),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      if (user == null) return LoginScreen(auth: widget.auth);
      if (user.uid != AppConfig.adminUid) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ErrorMessage('Tài khoản này không có quyền Admin.'),
                FilledButton(
                  onPressed: widget.auth.signOut,
                  child: const Text('Quay lại đăng nhập'),
                ),
              ],
            ),
          ),
        );
      }
      return DashboardScreen(
        auth: widget.auth,
        firestore: FirestoreService(FirebaseFirestore.instance),
        cloudinary: CloudinaryService(),
        adminEmail: user.email ?? 'Admin',
      );
    },
  );
}
