import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

String errorMessage(Object error) {
  if (error is FormatException) return error.message;
  if (error is AppException) return error.message;
  if (error is TimeoutException) {
    return 'Kết nối quá hạn. Vui lòng kiểm tra mạng và thử lại.';
  }
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email hoặc mật khẩu không đúng.',
      'invalid-email' => 'Email không hợp lệ.',
      'user-disabled' => 'Tài khoản đã bị vô hiệu hóa.',
      'too-many-requests' => 'Quá nhiều lần thử. Vui lòng thử lại sau.',
      'network-request-failed' => 'Không thể kết nối Firebase. Kiểm tra mạng.',
      'operation-not-allowed' =>
        'Chưa bật Email/Password trong Firebase Authentication.',
      _ => 'Không thể đăng nhập (${error.code}).',
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' =>
        'Không có quyền truy cập. Kiểm tra UID Admin và Firestore Rules.',
      'unavailable' => 'Firestore tạm thời không khả dụng. Vui lòng thử lại.',
      _ => 'Lỗi Firebase (${error.code}). Vui lòng thử lại.',
    };
  }
  return 'Thao tác chưa thành công. Kiểm tra kết nối và thử lại.';
}
