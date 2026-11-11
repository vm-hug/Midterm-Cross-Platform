import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';
import 'product_rest_writer.dart';
import '../models/product_model.dart';
import '../core/utils/validators.dart';
import '../core/utils/app_error.dart';

class FirestoreService {
  FirestoreService(FirebaseFirestore firestore, {ProductRestWriter? restWriter})
    : _products = firestore.collection(AppConfig.productCollection),
      _restWriter =
          restWriter ??
          (kIsWeb
              ? ProductRestWriter(
                  projectId: firestore.app.options.projectId,
                  tokenProvider: () async => FirebaseAuth.instanceFor(
                    app: firestore.app,
                  ).currentUser?.getIdToken(),
                )
              : null);
  final ProductRestWriter? _restWriter;
  final CollectionReference<Map<String, dynamic>> _products;
  Stream<List<ProductModel>> getProductsStream() => _products.snapshots().map(
    (s) => s.docs
        .map((d) => ProductModel.fromMap(d.data(), documentId: d.id))
        .toList(),
  );
  Future<List<ProductModel>> getAllProducts() async => (await _products.get(
    const GetOptions(source: Source.server),
  )).docs.map((d) => ProductModel.fromMap(d.data(), documentId: d.id)).toList();

  ProductModel _validated(ProductModel product) {
    final normalized = ProductModel(
      documentId: product.documentId,
      name: product.name.trim(),
      price: product.price,
      soluong: product.soluong,
      image: product.image,
    );
    final nameError = Validators.productName(normalized.name);
    if (nameError != null) throw AppException(nameError);
    if (!normalized.price.isFinite ||
        normalized.price < 0 ||
        normalized.price > ProductModel.maxSafeNumber) {
      throw const AppException(
        'Giá phải là số không âm trong giới hạn cho phép.',
      );
    }
    if (normalized.soluong < 0 ||
        normalized.soluong > ProductModel.maxSafeNumber) {
      throw const AppException(
        'Số lượng phải là số nguyên không âm trong giới hạn cho phép.',
      );
    }
    if (!Validators.cloudinaryUrl(normalized.image)) {
      throw const AppException('Ảnh phải là URL HTTPS Cloudinary của dự án.');
    }
    return normalized;
  }

  Future<void> addProduct(ProductModel product) async {
    final valid = _validated(product);
    final writer = _restWriter;
    if (writer != null) {
      await writer.write(_products.doc().id, valid, exists: false);
    } else {
      await _products.add(valid.toMap());
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    final valid = _validated(product);
    final id = valid.documentId;
    if (id == null || id.isEmpty) {
      throw const AppException('Không tìm thấy mã sản phẩm.');
    }
    // Update fails for a concurrently deleted document; Rules validate all fields.
    final writer = _restWriter;
    if (writer != null) {
      await writer.write(id, valid, exists: true);
    } else {
      await _products.doc(id).update(valid.toMap());
    }
  }

  Future<void> deleteProduct(String id) async {
    if (id.isEmpty) throw const AppException('Không tìm thấy mã sản phẩm.');
    await _products.doc(id).delete();
  }
}
