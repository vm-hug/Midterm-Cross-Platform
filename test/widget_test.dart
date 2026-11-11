import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:midterm_cross_platform/services/auth_service.dart';
import 'package:midterm_cross_platform/screens/login_screen.dart';
import 'package:midterm_cross_platform/core/theme/app_theme.dart';
import 'package:midterm_cross_platform/core/utils/app_error.dart';

class TestAuth implements AuthGateway {
  int attempts = 0;
  bool fail = false;
  @override
  Future<void> signIn(String email, String password) async {
    attempts++;
    if (fail) throw const AppException('Email hoặc mật khẩu không đúng.');
  }

  @override
  Future<void> signOut() async {}
  @override
  Stream<User?> authStateChanges() => Stream.value(null);
}

void main() {
  testWidgets(
    'Login validates, toggles password, submits and displays errors',
    (tester) async {
      final auth = TestAuth()..fail = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: LoginScreen(auth: auth),
        ),
      );
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();
      expect(auth.attempts, 0);
      expect(find.text('Vui lòng nhập email.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'admin@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'test-only');
      await tester.tap(find.byTooltip('Hiện mật khẩu'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Ẩn mật khẩu'), findsOneWidget);
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();
      expect(auth.attempts, 1);
      expect(find.text('Email hoặc mật khẩu không đúng.'), findsOneWidget);
      auth.fail = false;
      await tester.tap(find.text('Đăng nhập'));
      await tester.pumpAndSettle();
      expect(auth.attempts, 2);
      expect(find.text('Email hoặc mật khẩu không đúng.'), findsNothing);
    },
  );
  for (final width in [375.0, 1440.0]) {
    testWidgets('Login fits viewport $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: LoginScreen(auth: TestAuth()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Chào mừng trở lại'), findsOneWidget);
    });
  }
}
