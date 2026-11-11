/// Firestore document ID stays in memory; only these four fields are persisted.
class ProductModel {
  const ProductModel({
    this.documentId,
    required this.name,
    required this.price,
    required this.soluong,
    required this.image,
  });
  final String? documentId;
  final String name;
  final double price;
  final int soluong;
  final String image;

  factory ProductModel.fromMap(
    Map<String, dynamic> data, {
    String? documentId,
  }) {
    const keys = {'name', 'price', 'soluong', 'image'};
    final price = data['price'];
    final quantity = data['soluong'];
    if (data.length != 4 ||
        !data.keys.toSet().containsAll(keys) ||
        data['name'] is! String ||
        data['image'] is! String ||
        price is! num ||
        !price.isFinite ||
        price < 0 ||
        price > maxSafeNumber ||
        quantity is! int ||
        quantity < 0 ||
        quantity > maxSafeNumber) {
      throw const FormatException(
        'Dữ liệu sản phẩm phải có đúng name (String), price (số không âm), soluong (số nguyên không âm), image (String).',
      );
    }
    return ProductModel(
      documentId: documentId,
      name: data['name'] as String,
      price: price.toDouble(),
      soluong: quantity,
      image: data['image'] as String,
    );
  }

  // Integers above this cannot be represented exactly on Flutter Web.
  static const maxSafeNumber = 9007199254740991;
  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'soluong': soluong,
    'image': image,
  };
}
