import 'dart:convert';
import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midterm_cross_platform/core/theme/app_theme.dart';
import 'package:midterm_cross_platform/core/utils/app_error.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/screens/product_form_screen.dart';
import 'package:midterm_cross_platform/services/cloudinary_service.dart';
import 'package:midterm_cross_platform/services/firestore_service.dart';
import 'package:midterm_cross_platform/widgets/image_picker_widget.dart';

const uploadedUrl =
    'https://res.cloudinary.com/dqv9sna9b/image/upload/new-photo.png';
const oldProduct = ProductModel(
  documentId: 'existing',
  name: 'iPhone',
  price: 200.0,
  soluong: 3,
  image: 'https://res.cloudinary.com/dqv9sna9b/image/upload/old-photo.png',
);

XFile pickedImage() => XFile.fromData(
  Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  ),
  name: 'photo.png',
  path: 'photo.png',
);

class FailFirstWrite extends FirestoreService {
  FailFirstWrite(super.firestore);
  int attempts = 0;
  @override
  Future<void> addProduct(ProductModel product) async {
    if (++attempts == 1) throw const AppException('Lưu thất bại thử nghiệm.');
    await super.addProduct(product);
  }
}

Future<void> openForm(
  WidgetTester tester,
  FirestoreService service,
  CloudinaryService cloudinary, {
  ProductModel? product,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(
                  firestore: service,
                  cloudinary: cloudinary,
                  product: product,
                ),
              ),
            ),
            child: const Text('Mở form'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Mở form'));
  await tester.pumpAndSettle();
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'iPhone 17 Pro');
  await tester.enterText(fields.at(1), '27000000,5');
  await tester.enterText(fields.at(2), '5');
  // The picker emits an XFile after selecting a gallery/camera image.
  tester
      .widget<ImagePickerWidget>(find.byType(ImagePickerWidget))
      .onChanged(pickedImage());
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Lưu sản phẩm'));
  await tester.tap(find.text('Lưu sản phẩm'));
  await tester.pumpAndSettle();
}

void main() {
  for (final editing in [false, true]) {
    testWidgets(
      '${editing ? 'Replacing image' : 'Creating product'} saves the uploaded HTTPS URL',
      (tester) async {
        final db = FakeFirebaseFirestore();
        if (editing) {
          await db
              .collection('product')
              .doc('existing')
              .set(oldProduct.toMap());
        }
        var uploads = 0;
        final cloudinary = CloudinaryService(
          client: MockClient((request) async {
            uploads++;
            return http.Response(jsonEncode({'secure_url': uploadedUrl}), 200);
          }),
        );
        await openForm(
          tester,
          FirestoreService(db),
          cloudinary,
          product: editing ? oldProduct : null,
        );
        await save(tester);
        final docs = (await db.collection('product').get()).docs;
        expect(docs, hasLength(1));
        expect(docs.single.data(), {
          'name': 'iPhone 17 Pro',
          'price': 27000000.5,
          'soluong': 5,
          'image': uploadedUrl,
        });
        if (editing) expect(docs.single.id, 'existing');
        expect(uploads, 1);
        expect(find.text('Mở form'), findsOneWidget);
      },
    );
  }
  testWidgets(
    'Firestore retry reuses the uploaded URL without uploading twice',
    (tester) async {
      final db = FakeFirebaseFirestore();
      final service = FailFirstWrite(db);
      var uploads = 0;
      final cloudinary = CloudinaryService(
        client: MockClient((_) async {
          uploads++;
          return http.Response(jsonEncode({'secure_url': uploadedUrl}), 200);
        }),
      );
      await openForm(tester, service, cloudinary);
      await save(tester);
      expect((await db.collection('product').get()).docs, isEmpty);
      expect(find.text('Lưu thất bại thử nghiệm.'), findsOneWidget);
      await save(tester);
      expect(
        (await db.collection('product').get()).docs.single.data()['image'],
        uploadedUrl,
      );
      expect(uploads, 1);
      expect(service.attempts, 2);
    },
  );
  testWidgets('Failed upload does not write a product or show success', (
    tester,
  ) async {
    final db = FakeFirebaseFirestore();
    final cloudinary = CloudinaryService(
      client: MockClient(
        (_) async =>
            http.Response('{"error":{"message":"Invalid preset"}}', 400),
      ),
    );
    await openForm(tester, FirestoreService(db), cloudinary);
    await save(tester);
    expect((await db.collection('product').get()).docs, isEmpty);
    expect(find.textContaining('Không tải được ảnh (400)'), findsOneWidget);
    expect(find.text('Thêm sản phẩm'), findsOneWidget);
  });
}
