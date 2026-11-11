import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/services/export_service.dart';

void main() {
  const product = ProductModel(
    documentId: 'internal-id',
    name: 'Bút bi',
    price: 12.5,
    soluong: 4,
    image: 'https://res.cloudinary.com/dqv9sna9b/image/upload/a.png',
  );
  test(
    'Map and JSON contain exactly four fields with numeric price and integer quantity',
    () {
      expect(product.toMap().keys.toSet(), {
        'name',
        'price',
        'soluong',
        'image',
      });
      final exported =
          (jsonDecode(ExportService.encodeProducts([product])) as List).single;
      expect(exported, product.toMap());
      expect(exported['price'], isA<num>());
      expect(exported['soluong'], isA<int>());
      expect(ExportService.encodeProducts([]), '[]');
    },
  );
  test(
    'Roundtrip supports Unicode, integer prices and zero stock; ID remains internal',
    () {
      final copy = ProductModel.fromMap({
        ...product.toMap(),
        'price': 0,
        'soluong': 0,
      }, documentId: 'id');
      expect(copy.price, 0.0);
      expect(copy.soluong, 0);
      expect(copy.name, 'Bút bi');
      expect(copy.documentId, 'id');
      expect(copy.toMap().containsKey('documentId'), isFalse);
    },
  );
  test('Reject legacy keys, missing/extra fields and invalid numeric data', () {
    for (final data in [
      {...product.toMap(), 'role': 'admin'},
      {'name': 'a'},
      {'email': 'a', 'matkhau': 'a', 'hoten': 'a', 'hinhanh': 'a'},
      {...product.toMap(), 'price': '100'},
      {...product.toMap(), 'price': -1},
      {...product.toMap(), 'price': double.nan},
      {...product.toMap(), 'price': double.infinity},
      {...product.toMap(), 'soluong': 1.5},
      {...product.toMap(), 'soluong': -1},
      {...product.toMap(), 'soluong': '2'},
      {...product.toMap(), 'soluong': ProductModel.maxSafeNumber + 1},
    ]) {
      expect(() => ProductModel.fromMap(data), throwsFormatException);
    }
  });
}
