import '../../models/product_model.dart';

enum ProductSort { name, price, soluong }

List<ProductModel> queryProducts(
  List<ProductModel> products,
  String query,
  ProductSort sort,
) {
  final text = query.trim().toLowerCase();
  final result = products
      .where((p) => p.name.toLowerCase().contains(text))
      .toList();
  result.sort((a, b) {
    final compared = switch (sort) {
      ProductSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      ProductSort.price => a.price.compareTo(b.price),
      ProductSort.soluong => a.soluong.compareTo(b.soluong),
    };
    return compared != 0
        ? compared
        : (a.documentId ?? '').compareTo(b.documentId ?? '');
  });
  return result;
}

String priceText(double price) =>
    '${price.toStringAsFixed(2).replaceAll('.', ',')} ₫';
