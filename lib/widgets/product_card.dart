import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/utils/product_query.dart';
import 'common.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.busy = false,
  });
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool busy;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: product.name, url: product.image, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceText(product.price),
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Số lượng: ${product.soluong}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Sửa'),
              ),
              TextButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Xóa'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
