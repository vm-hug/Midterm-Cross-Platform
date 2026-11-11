import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/core/utils/product_query.dart';

void main() {
  test('Prices format with thousands separators', () {
    expect(priceText(27000000.0), '27,000,000 ₫');
    expect(priceText(12500.0), '12,500 ₫');
    expect(priceText(200.0), '200 ₫');
    expect(priceText(12.5), '12,5 ₫');
    expect(priceText(0.0), '0 ₫');
  });
  const products = [
    ProductModel(
      documentId: 'a',
      name: 'Sổ tay',
      price: 10,
      soluong: 2,
      image: '',
    ),
    ProductModel(
      documentId: 'b',
      name: 'Bút bi',
      price: 2,
      soluong: 10,
      image: '',
    ),
  ];
  test(
    'Search trims and ignores case',
    () => expect(
      queryProducts(products, ' BÚT ', ProductSort.name).single.name,
      'Bút bi',
    ),
  );
  test('Price and quantity sort numerically, not lexically', () {
    expect(queryProducts(products, '', ProductSort.price).first.price, 2);
    expect(queryProducts(products, '', ProductSort.soluong).first.soluong, 2);
  });
}
