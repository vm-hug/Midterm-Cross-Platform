import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/utils/product_query.dart';
import 'common.dart';

class ProductTable extends StatelessWidget {
  const ProductTable({
    super.key,
    required this.products,
    required this.onEdit,
    required this.onDelete,
    this.busyIds = const {},
  });
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onEdit;
  final ValueChanged<ProductModel> onDelete;
  final Set<String> busyIds;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: constraints.maxWidth),
        child: DataTable(
          headingRowHeight: 58,
          dataRowMinHeight: 76,
          dataRowMaxHeight: 90,
          columnSpacing: 30,
          columns: const [
            DataColumn(label: Text('SẢN PHẨM')),
            DataColumn(label: Text('GIÁ'), numeric: true),
            DataColumn(label: Text('SỐ LƯỢNG'), numeric: true),
            DataColumn(label: Text('THAO TÁC')),
          ],
          rows: products
              .map(
                (p) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserAvatar(name: p.name, url: p.image),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(priceText(p.price))),
                    DataCell(Text('${p.soluong}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Sửa ${p.name}',
                            onPressed: busyIds.contains(p.documentId)
                                ? null
                                : () => onEdit(p),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                          ),
                          IconButton(
                            tooltip: 'Xóa ${p.name}',
                            onPressed: busyIds.contains(p.documentId)
                                ? null
                                : () => onDelete(p),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}
