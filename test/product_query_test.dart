import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_cross_platform/models/product_model.dart';
import 'package:midterm_cross_platform/core/utils/product_query.dart';

void main() {
  test('Prices always show two decimals with a decimal comma', () {
    expect(priceText(200.0), '200,00 ₫');
    expect(priceText(12.5), '12,50 ₫');
    expect(priceText(12.345), '12,35 ₫');
    expect(priceText(0.0), '0,00 ₫');
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
