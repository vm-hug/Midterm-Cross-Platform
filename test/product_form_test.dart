import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/core/theme/app_theme.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/screens/product_form_screen.dart';
import 'package:midterm_cross_platform/services/cloudinary_service.dart';
import 'package:midterm_cross_platform/services/firestore_service.dart';

void main() {
  testWidgets(
    'Edit form validates and persists price/quantity as numbers, keeping image',
    (tester) async {
      final db = FakeFirebaseFirestore();
      const p = ProductModel(
        documentId: 'p',
        name: 'Bút bi',
        price: 100,
        soluong: 2,
        image: 'https://res.cloudinary.com/dqv9sna9b/image/upload/a.png',
      );
      await db.collection('product').doc('p').set(p.toMap());
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ProductFormScreen(
                      firestore: FirestoreService(db),
                      cloudinary: CloudinaryService(),
                      product: p,
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
      await tester.enterText(fields.at(1), '-1');
      await tester.enterText(fields.at(2), '1.5');
      await tester.ensureVisible(find.text('Lưu sản phẩm'));
      await tester.tap(find.text('Lưu sản phẩm'));
      await tester.pumpAndSettle();
      expect(
        (await db.collection('product').doc('p').get()).data()!['price'],
        100,
      );
      expect(find.text('Chỉnh sửa sản phẩm'), findsOneWidget);
      await tester.enterText(fields.at(1), '12,5');
      await tester.enterText(fields.at(2), '0');
      await tester.ensureVisible(find.text('Lưu sản phẩm'));
      await tester.tap(find.text('Lưu sản phẩm'));
      await tester.pumpAndSettle();
      final data = (await db.collection('product').doc('p').get()).data()!;
      expect(data, {
        'name': 'Bút bi',
        'price': 12.5,
        'soluong': 0,
        'image': p.image,
      });
      expect(data['soluong'], isA<int>());
      expect(find.text('Mở form'), findsOneWidget);
    },
  );
}
