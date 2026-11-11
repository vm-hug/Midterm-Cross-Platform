import 'dart:async';
import 'dart:convert';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:midterm_cross_platform/core/utils/app_error.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/services/firestore_service.dart';
import 'package:midterm_cross_platform/services/product_rest_writer.dart';

const product = ProductModel(
  name: 'Bút bi',
  price: 200.0,
  soluong: 3,
  image: 'https://res.cloudinary.com/dqv9sna9b/image/upload/a.png',
);
void main() {
  test(
    'Web create/update send explicit doubleValue and integerValue to product with existence preconditions',
    () async {
      final writes = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        expect(
          request.url.path,
          '/v1/projects/test-project/databases/(default)/documents:commit',
        );
        expect(request.headers['Authorization'], 'Bearer test-token');
        writes.add(
          (jsonDecode(request.body)['writes'] as List).single
              as Map<String, dynamic>,
        );
        return http.Response('{"writeResults":[{"updateTime":"now"}]}', 200);
      });
      final writer = ProductRestWriter(
        projectId: 'test-project',
        tokenProvider: () async => 'test-token',
        client: client,
      );
      final db = FakeFirebaseFirestore();
      final service = FirestoreService(db, restWriter: writer);
      await service.addProduct(product);
      await service.updateProduct(
        ProductModel(
          documentId: 'same-id',
          name: 'Bút bi',
          price: 200,
          soluong: 3,
          image: product.image,
        ),
      );
      for (final w in writes) {
        expect(w['update']['name'], contains('/documents/product/'));
        final f = w['update']['fields'] as Map;
        expect(f.keys.toSet(), {'name', 'price', 'soluong', 'image'});
        expect(f['price'], {'doubleValue': 200.0});
        expect(f['soluong'], {'integerValue': '3'});
      }
      expect(writes.first['currentDocument'], {'exists': false});
      expect(writes.last['currentDocument'], {'exists': true});
      expect(writes.last['update']['name'], endsWith('/product/same-id'));
      expect((await db.collection('users').get()).docs, isEmpty);
    },
  );
  test('Expired session does not send a request', () async {
    final writer = ProductRestWriter(
      projectId: 'p',
      tokenProvider: () async => null,
      client: MockClient((_) async => throw StateError('Must not send')),
    );
    await expectLater(
      writer.write('id', product, exists: false),
      throwsA(isA<AppException>()),
    );
  });
  test('Permission denied propagates and is not reported as success', () async {
    final writer = ProductRestWriter(
      projectId: 'p',
      tokenProvider: () async => 'test',
      client: MockClient((_) async => http.Response('{}', 403)),
    );
    await expectLater(
      writer.write('id', product, exists: false),
      throwsA(
        isA<FirebaseException>().having(
          (e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );
  });
  test('Missing confirmation and network timeout fail', () async {
    final writer = ProductRestWriter(
      projectId: 'p',
      tokenProvider: () async => 'test',
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    await expectLater(
      writer.write('id', product, exists: false),
      throwsA(isA<AppException>()),
    );
    final slow = ProductRestWriter(
      projectId: 'p',
      tokenProvider: () async => 'test',
      timeout: const Duration(milliseconds: 10),
      client: MockClient((_) => Completer<http.Response>().future),
    );
    await expectLater(
      slow.write('id', product, exists: false),
      throwsA(isA<TimeoutException>()),
    );
  });
}
