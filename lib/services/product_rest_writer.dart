import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import '../core/config/app_config.dart';
import '../core/utils/app_error.dart';
import '../models/product_model.dart';

/// Web's JS SDK classifies whole-valued numbers as integers. An explicit
/// doubleValue in Firestore REST keeps prices such as 200.0 stored as double.
/// The Firebase ID token is checked by the same Firestore Security Rules.
class ProductRestWriter {
  ProductRestWriter({
    required this.projectId,
    required this.tokenProvider,
    this._client,
    this.timeout = const Duration(seconds: 30),
  });
  final String projectId;
  final Future<String?> Function() tokenProvider;
  final http.Client? _client;
  final Duration timeout;

  Future<void> write(
    String id,
    ProductModel product, {
    required bool exists,
  }) async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) {
      throw const AppException(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      );
    }
    final client = _client ?? http.Client();
    try {
      final base = 'projects/$projectId/databases/(default)/documents';
      final response = await client
          .post(
            Uri.https('firestore.googleapis.com', '/v1/$base:commit'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'writes': [
                {
                  'update': {
                    'name': '$base/${AppConfig.productCollection}/$id',
                    'fields': {
                      'name': {'stringValue': product.name},
                      'price': {'doubleValue': product.price},
                      'soluong': {'integerValue': product.soluong.toString()},
                      'image': {'stringValue': product.image},
                    },
                  },
                  'currentDocument': {'exists': exists},
                },
              ],
            }),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: switch (response.statusCode) {
            401 => 'unauthenticated',
            403 => 'permission-denied',
            404 => 'not-found',
            409 => 'already-exists',
            503 => 'unavailable',
            _ => 'write-failed',
          },
        );
      }
      final data = jsonDecode(response.body);
      if (data is! Map ||
          data['writeResults'] is! List ||
          (data['writeResults'] as List).length != 1) {
        throw const AppException(
          'Firestore chưa xác nhận lưu sản phẩm. Vui lòng thử lại.',
        );
      }
    } on http.ClientException {
      throw const AppException(
        'Không thể kết nối Firestore. Kiểm tra mạng và thử lại.',
      );
    } finally {
      if (_client == null) client.close();
    }
  }
}
