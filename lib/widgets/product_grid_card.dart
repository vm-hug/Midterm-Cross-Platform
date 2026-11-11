import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/utils/product_query.dart';
import '../core/theme/app_theme.dart';

/// Card sản phẩm dạng hiển thị mục / Catalog với tỷ lệ ảnh vừa vặn và nút bấm cân đối
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
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
  Widget build(BuildContext context) {
    final hasImage = product.image.isNotEmpty;

    final imagePlaceholder = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xffe8fdfe),
            Color(0xfff3e8ff),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.purplePastel.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purplePastel.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.checkroom_rounded,
                size: 28,
                color: AppTheme.purplePrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hình ảnh',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purpleDark.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PHẦN ẢNH SẢN PHẨM: Tỷ lệ 1.22 vừa vặn, không bị chiếm quá nhiều diện tích
            AspectRatio(
              aspectRatio: 1.22,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: hasImage
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => imagePlaceholder,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0xfff5f4fb),
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.purplePrimary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : imagePlaceholder,
                  ),

                  // Lớp phủ gradient nhẹ trên đỉnh
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 42,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Pill Tag: Số lượng tồn kho
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.purplePastel.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.layers_rounded,
                            size: 12,
                            color: AppTheme.purplePrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SL: ${product.soluong}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.purpleDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PHẦN THÔNG TIN VÀ NÚT BẤM DƯỚI ĐÁY: Rộng rãi, cân đối
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tên và giá sản phẩm
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.navy,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceText(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.purplePrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    // HÀNG NÚT SỬA & XÓA ĐẦY ĐẶN, CÂN ĐỐI (Cao 38px, dễ bấm)
                    Row(
                      children: [
                        // Nút Sửa
                        Expanded(
                          child: InkWell(
                            onTap: busy ? null : onEdit,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppTheme.cyanBright.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.cyanBright.withValues(alpha: 0.6),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 15,
                                    color: Color(0xff0284c7),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Sửa',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff0284c7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Nút Xóa
                        Expanded(
                          child: InkWell(
                            onTap: busy ? null : onDelete,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 15,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Xóa',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
