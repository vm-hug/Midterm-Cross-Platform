import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/utils/product_query.dart';
import '../core/theme/app_theme.dart';
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DataTable(
            headingRowHeight: 54,
            dataRowMinHeight: 74,
            dataRowMaxHeight: 88,
            columnSpacing: 28,
            headingRowColor: WidgetStateProperty.all(
              const Color(0xfff5f4fb),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'SẢN PHẨM',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'GIÁ',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'SỐ LƯỢNG',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'THAO TÁC',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
            rows: products
                .map(
                  (p) => DataRow(
                    cells: [
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            UserAvatar(name: p.name, url: p.image, radius: 22),
                            const SizedBox(width: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppTheme.navy,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          priceText(p.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.purplePrimary,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.purplePastel.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.purplePastel.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            '${p.soluong}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.purpleDark,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.cyanBright.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.cyanBright.withValues(alpha: 0.35),
                                ),
                              ),
                              child: IconButton(
                                tooltip: 'Sửa ${p.name}',
                                onPressed: busyIds.contains(p.documentId)
                                    ? null
                                    : () => onEdit(p),
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: Color(0xff0284c7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(alpha: 0.25),
                                ),
                              ),
                              child: IconButton(
                                tooltip: 'Xóa ${p.name}',
                                onPressed: busyIds.contains(p.documentId)
                                    ? null
                                    : () => onDelete(p),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
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
    ),
  );
}
