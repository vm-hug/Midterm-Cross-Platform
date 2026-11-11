import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/core/utils/app_error.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/services/firestore_service.dart';

ProductModel makeProduct({
  String? id,
  String name = 'Bút bi',
  double price = 12500.5,
  int quantity = 3,
  String? image,
}) => ProductModel(
  documentId: id,
  name: name,
  price: price,
  soluong: quantity,
  image: image ?? 'https://res.cloudinary.com/dqv9sna9b/image/upload/a.png',
);
void main() {
  late FakeFirebaseFirestore db;
  late FirestoreService service;
  setUp(() {
    db = FakeFirebaseFirestore();
    service = FirestoreService(db);
  });
  test(
    'CRUD keeps product collection, four fields, numeric types and auto ID',
    () async {
      await service.addProduct(makeProduct(name: '  Bút bi  '));
      final doc = (await db.collection('product').get()).docs.single;
      expect(doc.id, isNot('Bút bi'));
      expect(doc.data(), makeProduct().toMap());
      expect(doc.data()['price'], isA<double>());
      expect(doc.data()['soluong'], isA<int>());
      await service.updateProduct(
        makeProduct(id: doc.id, name: 'Sổ tay', price: 0, quantity: 0),
      );
      final product = (await service.getAllProducts()).single;
      expect(product.name, 'Sổ tay');
      expect(product.price, 0);
      expect(product.soluong, 0);
      await service.deleteProduct(doc.id);
      expect(await service.getAllProducts(), isEmpty);
    },
  );
  test(
    'Names are not email identifiers; repeated product names are allowed',
    () async {
      await service.addProduct(makeProduct());
      await service.addProduct(makeProduct(price: 25000));
      expect(await service.getAllProducts(), hasLength(2));
    },
  );
  test(
    'Invalid product values never write; missing updates do not create documents',
    () async {
      for (final p in [
        makeProduct(name: '  '),
        makeProduct(price: -1),
        makeProduct(price: double.nan),
        makeProduct(price: double.infinity),
        makeProduct(quantity: -1),
        makeProduct(image: 'http://bad.test/a.png'),
      ]) {
        await expectLater(service.addProduct(p), throwsA(isA<AppException>()));
      }
      await expectLater(
        service.updateProduct(makeProduct()),
        throwsA(isA<AppException>()),
      );
      await expectLater(
        service.updateProduct(makeProduct(id: 'missing')),
        throwsA(anything),
      );
      expect(await service.getAllProducts(), isEmpty);
    },
  );
  test('Realtime stream emits typed products', () async {
    final pending = service.getProductsStream().firstWhere(
      (products) => products.length == 1,
    );
    await service.addProduct(makeProduct());
    expect((await pending).single.name, 'Bút bi');
  });
}
