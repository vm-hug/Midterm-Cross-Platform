import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/utils/product_query.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import '../services/export_service.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_error.dart';
import '../widgets/common.dart';
import '../widgets/product_table.dart';
import '../widgets/product_card.dart';
import 'product_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.auth,
    required this.firestore,
    required this.cloudinary,
    required this.adminEmail,
  });
  final AuthGateway auth;
  final FirestoreService firestore;
  final CloudinaryService cloudinary;
  final String adminEmail;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<List<ProductModel>> _stream = widget.firestore
      .getProductsStream();
  final _search = TextEditingController();
  String _query = '';
  ProductSort _sort = ProductSort.name;
  bool _exporting = false;
  bool _loggingOut = false;
  final _busyIds = <String>{};
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _form([ProductModel? user]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(
          firestore: widget.firestore,
          cloudinary: widget.cloudinary,
          product: user,
        ),
      ),
    );
    if (saved == true && mounted) {
      showMessage(
        context,
        user == null ? 'Đã thêm sản phẩm.' : 'Đã cập nhật sản phẩm.',
      );
    }
  }

  Future<void> _delete(ProductModel user) async {
    if (_busyIds.contains(user.documentId)) return;
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: Text(
          'Bạn có chắc muốn xóa ${user.name}?\nẢnh cũ vẫn được giữ trong Cloudinary.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa sản phẩm'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    final id = user.documentId!;
    setState(() => _busyIds.add(id));
    try {
      await widget.firestore.deleteProduct(id);
      if (mounted) showMessage(context, 'Đã xóa sản phẩm.');
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _busyIds.remove(id));
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      await ExportService.downloadProducts(widget.firestore);
      if (mounted) {
        showMessage(context, 'Đã tải database_products.json từ Firestore.');
      }
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await widget.auth.signOut();
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Widget _sidebar() => Container(
    width: 228,
    color: AppTheme.navy,
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.hub_rounded, color: Color(0xff72dad0), size: 30),
            SizedBox(width: 10),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'UserSpace',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 56),
        const Text(
          'KHÔNG GIAN QUẢN TRỊ',
          style: TextStyle(
            color: Color(0xff9ab6bf),
            fontSize: 10,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xff284b56),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Color(0xff8be1d8)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sản phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const Icon(Icons.devices_rounded, color: Color(0xff9ab6bf)),
        const SizedBox(height: 12),
        const Text(
          'Một dữ liệu.\nBa nền tảng.',
          style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
        ),
        const SizedBox(height: 10),
        const Text(
          'Web · Android · iOS',
          style: TextStyle(color: Color(0xff9ab6bf), fontSize: 12),
        ),
        const SizedBox(height: 24),
      ],
    ),
  );
  Widget _stat(String label, int value, IconData icon, Color color) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
                ),
                Text(label, style: const TextStyle(color: Colors.blueGrey)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide) _sidebar(),
            Expanded(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 36 : 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.space_dashboard_outlined,
                          color: AppTheme.teal,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Trang quản trị',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (wide)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Text(
                              widget.adminEmail,
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                        IconButton(
                          tooltip: 'Đăng xuất',
                          onPressed: _loggingOut ? null : _logout,
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<ProductModel>>(
                      stream: _stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: ErrorMessage(
                              errorMessage(snapshot.error!),
                              onRetry: () => setState(
                                () => _stream = widget.firestore
                                    .getProductsStream(),
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final all = snapshot.data!;
                        final filtered = queryProducts(all, _query, _sort);
                        return ListView(
                          padding: EdgeInsets.all(wide ? 36 : 18),
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              runSpacing: 18,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quản lý sản phẩm',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.navy,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Thông tin rõ ràng. Cập nhật theo thời gian thực.',
                                      style: TextStyle(color: Colors.blueGrey),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    if (kIsWeb)
                                      OutlinedButton.icon(
                                        onPressed: _exporting ? null : _export,
                                        icon: const Icon(
                                          Icons.file_download_outlined,
                                        ),
                                        label: Text(
                                          _exporting
                                              ? 'Đang xuất…'
                                              : 'Xuất JSON',
                                        ),
                                      ),
                                    FilledButton.icon(
                                      onPressed: () => _form(),
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('Thêm sản phẩm'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            LayoutBuilder(
                              builder: (context, constraints) =>
                                  constraints.maxWidth >= 600
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: _stat(
                                            'Tổng sản phẩm',
                                            all.length,
                                            Icons.inventory_2_outlined,
                                            AppTheme.teal,
                                          ),
                                        ),
                                        const SizedBox(width: 18),
                                        Expanded(
                                          child: _stat(
                                            'Tổng số lượng',
                                            all.fold<int>(
                                              0,
                                              (sum, p) => sum + p.soluong,
                                            ),
                                            Icons.numbers_rounded,
                                            const Color(0xff6572bb),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _stat(
                                          'Tổng sản phẩm',
                                          all.length,
                                          Icons.inventory_2_outlined,
                                          AppTheme.teal,
                                        ),
                                        const SizedBox(height: 12),
                                        _stat(
                                          'Tổng số lượng',
                                          all.fold<int>(
                                            0,
                                            (sum, p) => sum + p.soluong,
                                          ),
                                          Icons.numbers_rounded,
                                          const Color(0xff6572bb),
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 28),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) => Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: constraints.maxWidth > 600
                                                ? 320
                                                : constraints.maxWidth,
                                            child: TextField(
                                              controller: _search,
                                              onChanged: (value) => setState(
                                                () => _query = value
                                                    .trim()
                                                    .toLowerCase(),
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Tìm theo tên sản phẩm…',
                                                prefixIcon: const Icon(
                                                  Icons.search_rounded,
                                                ),
                                                suffixIcon: _query.isNotEmpty
                                                    ? IconButton(
                                                        tooltip: 'Xóa tìm kiếm',
                                                        onPressed: () {
                                                          _search.clear();
                                                          setState(
                                                            () => _query = '',
                                                          );
                                                        },
                                                        icon: const Icon(
                                                          Icons.close,
                                                          size: 18,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 180,
                                            child:
                                                DropdownButtonFormField<
                                                  ProductSort
                                                >(
                                                  isExpanded: true,
                                                  initialValue: _sort,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText:
                                                            'Sắp xếp theo',
                                                      ),
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: ProductSort.name,
                                                      child: Text(
                                                        'Tên sản phẩm',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: ProductSort.price,
                                                      child: Text('Giá'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value:
                                                          ProductSort.soluong,
                                                      child: Text('Số lượng'),
                                                    ),
                                                  ],
                                                  onChanged: (value) =>
                                                      setState(
                                                        () => _sort =
                                                            value ??
                                                            ProductSort.name,
                                                      ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${filtered.length} kết quả',
                                        style: const TextStyle(
                                          color: Colors.blueGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (filtered.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 48,
                                        ),
                                        child: Column(
                                          children: [
                                            const Icon(
                                              Icons.inventory_2_outlined,
                                              size: 56,
                                              color: Colors.blueGrey,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              all.isEmpty
                                                  ? 'Chưa có sản phẩm'
                                                  : 'Không tìm thấy kết quả',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              all.isEmpty
                                                  ? 'Bắt đầu bằng cách thêm sản phẩm đầu tiên.'
                                                  : 'Thử tìm bằng tên sản phẩm khác.',
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (MediaQuery.sizeOf(context).width >=
                                        850)
                                      ProductTable(
                                        products: filtered,
                                        onEdit: _form,
                                        onDelete: _delete,
                                        busyIds: _busyIds,
                                      )
                                    else
                                      ...filtered.map(
                                        (user) => Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: ProductCard(
                                            product: user,
                                            onEdit: () => _form(user),
                                            onDelete: () => _delete(user),
                                            busy: _busyIds.contains(
                                              user.documentId,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'UserSpace • Flutter + Firebase + Cloudinary',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
