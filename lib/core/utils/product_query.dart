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

/// Định dạng giá tiền chuẩn với dấu phẩy phân tách hàng nghìn (VD: 27000000 -> 27,000,000 ₫)
String priceText(double price) {
  if (price == price.truncateToDouble()) {
    final intStr = price.toInt().toString();
    final formatted = intStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$formatted ₫';
  } else {
    final fixed = price.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final decPart = parts[1].replaceAll(RegExp(r'0+$'), '');
    return decPart.isEmpty ? '$intPart ₫' : '$intPart,$decPart ₫';
  }
}
