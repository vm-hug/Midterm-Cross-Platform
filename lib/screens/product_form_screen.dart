import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/app_error.dart';
import '../core/theme/app_theme.dart';
import '../widgets/image_picker_widget.dart';
import '../widgets/common.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    super.key,
    required this.firestore,
    required this.cloudinary,
    this.product,
  });
  final FirestoreService firestore;
  final CloudinaryService cloudinary;
  final ProductModel? product;
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name);
  late final _price = TextEditingController(
    text: widget.product?.price.toString().replaceAll('.', ','),
  );
  late final _quantity = TextEditingController(
    text: widget.product?.soluong.toString(),
  );
  XFile? _image;
  String? _uploadedUrl;
  bool _busy = false;
  String? _error;
  String _progress = '';

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    if (_image == null && (widget.product?.image.isEmpty ?? true)) {
      setState(() => _error = 'Vui lòng chọn ảnh sản phẩm.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _progress = 'Đang lưu sản phẩm…';
    });
    try {
      var url = widget.product?.image ?? '';
      if (_image != null) {
        if (mounted) setState(() => _progress = 'Đang tải ảnh lên Cloudinary…');
        _uploadedUrl ??= await widget.cloudinary.upload(_image!);
        url = _uploadedUrl!;
      }
      if (!mounted) return;
      setState(() => _progress = 'Đang lưu vào Firestore…');
      final product = ProductModel(
        documentId: widget.product?.documentId,
        name: _name.text,
        price: Validators.parsePrice(_price.text)!,
        soluong: int.parse(_quantity.text.trim()),
        image: url,
      );
      if (widget.product == null) {
        await widget.firestore.addProduct(product);
      } else {
        await widget.firestore.updateProduct(product);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Thêm sản phẩm' : 'Chỉnh sửa sản phẩm',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: !_busy,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppTheme.cardBorder,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppTheme.cardBorder, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppIconBadge(
                              icon: widget.product == null
                                  ? Icons.add_box_rounded
                                  : Icons.edit_note_rounded,
                              size: 48,
                              iconSize: 26,
                              borderRadius: 14,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông tin sản phẩm',
                                    style: Theme.of(context).textTheme.titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.navy,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Nhập tên, giá, số lượng và chọn ảnh cho sản phẩm.',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        ImagePickerWidget(
                          service: widget.cloudinary,
                          existingUrl: widget.product?.image ?? '',
                          enabled: !_busy,
                          onChanged: (file) {
                            _image = file;
                            _uploadedUrl = null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _name,
                          enabled: !_busy,
                          validator: Validators.productName,
                          maxLength: 100,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Tên sản phẩm',
                            prefixIcon: Icon(
                              Icons.inventory_2_rounded,
                              color: AppTheme.purplePrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _price,
                          enabled: !_busy,
                          validator: Validators.price,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Giá (VNĐ)',
                            helperText:
                                'Giá không âm; có thể nhập phần thập phân bằng dấu chấm hoặc phẩy.',
                            prefixIcon: Icon(
                              Icons.payments_rounded,
                              color: AppTheme.purplePrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _quantity,
                          enabled: !_busy,
                          validator: Validators.quantity,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng',
                            helperText: 'Số nguyên không âm.',
                            prefixIcon: Icon(
                              Icons.layers_rounded,
                              color: AppTheme.purplePrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Semantics(
                              liveRegion: true,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 20,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _save,
                            icon: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_rounded, size: 20),
                            label: Text(
                              _busy ? _progress : 'Lưu sản phẩm',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: _busy
                                ? null
                                : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Hủy bỏ'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
