import 'dart:convert';
import '../models/product_model.dart';
import 'firestore_service.dart';
import 'export/download_stub.dart'
    if (dart.library.js_interop) 'export/download_web.dart'
    as platform;

abstract final class ExportService {
  static String encodeProducts(List<ProductModel> products) =>
      const JsonEncoder.withIndent(
        '  ',
      ).convert(products.map((p) => p.toMap()).toList());
  static Future<void> downloadProducts(FirestoreService service) async {
    platform.downloadJson(encodeProducts(await service.getAllProducts()));
  }
}
