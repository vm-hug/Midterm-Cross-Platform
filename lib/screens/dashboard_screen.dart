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
import '../widgets/product_grid_card.dart';
import 'product_form_screen.dart';

enum ProductViewMode { list, grid }

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
  ProductViewMode _viewMode = ProductViewMode.list;

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
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Colors.redAccent,
            size: 26,
          ),
        ),
        title: const Text('Xóa sản phẩm?'),
        content: Text(
          'Bạn có chắc muốn xóa ${user.name}?\nẢnh cũ vẫn được giữ trong Cloudinary.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
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
    width: 240,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.purpleDark, AppTheme.purpleDeep],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyanBright.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hub_rounded,
                color: AppTheme.purpleDark,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 44),
        Text(
          'KHÔNG GIAN QUẢN TRỊ',
          style: TextStyle(
            color: AppTheme.purplePastel.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.cyanBright.withValues(alpha: 0.2),
                AppTheme.purplePastel.withValues(alpha: 0.25),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.cyanBright.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                color: AppTheme.cyanBright,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sản phẩm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.cyanBright,
                size: 18,
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.purplePastel.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cyanBright.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.devices_rounded,
                  color: AppTheme.cyanBright,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Một dữ liệu.\nBa nền tảng.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Web · Android · iOS',
                style: TextStyle(
                  color: AppTheme.purplePastel.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );

  Widget _stat(String label, int value, IconData icon, Gradient iconBg, Color iconColor) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppTheme.cardBorder, width: 1.2),
    ),
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: iconBg,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
      backgroundColor: AppTheme.scaffoldBg,
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
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.purplePastel.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.space_dashboard_rounded,
                            color: AppTheme.purplePrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Trang quản trị',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                        if (wide)
                          Container(
                            margin: const EdgeInsets.only(right: 14),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.scaffoldBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.purplePastel.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_circle_rounded,
                                  size: 16,
                                  color: AppTheme.purplePrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.adminEmail,
                                  style: const TextStyle(
                                    color: AppTheme.navy,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.scaffoldBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.cardBorder),
                          ),
                          child: IconButton(
                            tooltip: 'Đăng xuất',
                            onPressed: _loggingOut ? null : _logout,
                            icon: const Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppTheme.cardBorder, height: 1),
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
                            child: CircularProgressIndicator(
                              color: AppTheme.purplePrimary,
                            ),
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
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Thông tin rõ ràng. Cập nhật theo thời gian thực.',
                                      style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 10,
                                  children: [
                                    if (kIsWeb)
                                      OutlinedButton.icon(
                                        onPressed: _exporting ? null : _export,
                                        icon: const Icon(
                                          Icons.file_download_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          _exporting
                                              ? 'Đang xuất…'
                                              : 'Xuất JSON',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: AppTheme.purplePastel
                                                .withValues(alpha: 0.7),
                                            width: 1.4,
                                          ),
                                          foregroundColor: AppTheme.purplePrimary,
                                        ),
                                      ),
                                    FilledButton.icon(
                                      onPressed: () => _form(),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 20,
                                      ),
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
                                            Icons.inventory_2_rounded,
                                            const LinearGradient(
                                              colors: [
                                                Color(0x4466ffff),
                                                Color(0x3399ffff),
                                              ],
                                            ),
                                            const Color(0xff0284c7),
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
                                            Icons.layers_rounded,
                                            const LinearGradient(
                                              colors: [
                                                Color(0x44cc99ff),
                                                Color(0x22cc99ff),
                                              ],
                                            ),
                                            AppTheme.purplePrimary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        _stat(
                                          'Tổng sản phẩm',
                                          all.length,
                                          Icons.inventory_2_rounded,
                                          const LinearGradient(
                                            colors: [
                                              Color(0x4466ffff),
                                              Color(0x3399ffff),
                                            ],
                                          ),
                                          const Color(0xff0284c7),
                                        ),
                                        const SizedBox(height: 14),
                                        _stat(
                                          'Tổng số lượng',
                                          all.fold<int>(
                                            0,
                                            (sum, p) => sum + p.soluong,
                                          ),
                                          Icons.layers_rounded,
                                          const LinearGradient(
                                            colors: [
                                              Color(0x44cc99ff),
                                              Color(0x22cc99ff),
                                            ],
                                          ),
                                          AppTheme.purplePrimary,
                                        ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 28),
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                                side: const BorderSide(
                                  color: AppTheme.cardBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) => Wrap(
                                        spacing: 14,
                                        runSpacing: 14,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: constraints.maxWidth > 600
                                                ? 340
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
                                                  size: 20,
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
                                                          Icons.close_rounded,
                                                          size: 18,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 190,
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
                                                        prefixIcon: Icon(
                                                          Icons.sort_rounded,
                                                          size: 18,
                                                        ),
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
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.cyanLight
                                                .withValues(alpha: 0.25),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppTheme.cyanBright
                                                  .withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Text(
                                            '${filtered.length} kết quả',
                                            style: const TextStyle(
                                              color: AppTheme.navy,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xfff1f3f9),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppTheme.cardBorder,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () => setState(
                                                  () => _viewMode =
                                                      ProductViewMode.list,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _viewMode ==
                                                            ProductViewMode.list
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      7,
                                                    ),
                                                    boxShadow: _viewMode ==
                                                            ProductViewMode.list
                                                        ? [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                alpha: 0.08,
                                                              ),
                                                              blurRadius: 4,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.view_list_rounded,
                                                        size: 15,
                                                        color: _viewMode ==
                                                                ProductViewMode
                                                                    .list
                                                            ? AppTheme
                                                                .purplePrimary
                                                            : AppTheme
                                                                .textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'List',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              _viewMode ==
                                                                      ProductViewMode
                                                                          .list
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color: _viewMode ==
                                                                  ProductViewMode
                                                                      .list
                                                              ? AppTheme
                                                                  .purpleDark
                                                              : AppTheme
                                                                  .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              InkWell(
                                                onTap: () => setState(
                                                  () => _viewMode =
                                                      ProductViewMode.grid,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _viewMode ==
                                                            ProductViewMode.grid
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      7,
                                                    ),
                                                    boxShadow: _viewMode ==
                                                            ProductViewMode.grid
                                                        ? [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withValues(
                                                                alpha: 0.08,
                                                              ),
                                                              blurRadius: 4,
                                                            ),
                                                          ]
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.grid_view_rounded,
                                                        size: 15,
                                                        color: _viewMode ==
                                                                ProductViewMode
                                                                    .grid
                                                            ? AppTheme
                                                                .purplePrimary
                                                            : AppTheme
                                                                .textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Hiển thị mục',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              _viewMode ==
                                                                      ProductViewMode
                                                                          .grid
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                          color: _viewMode ==
                                                                  ProductViewMode
                                                                      .grid
                                                              ? AppTheme
                                                                  .purpleDark
                                                              : AppTheme
                                                                  .textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (filtered.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 54,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 76,
                                              height: 76,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0x3366ffff),
                                                    Color(0x33cc99ff),
                                                  ],
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppTheme.purplePastel
                                                      .withValues(alpha: 0.4),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.inventory_2_outlined,
                                                size: 38,
                                                color: AppTheme.purplePrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            Text(
                                              all.isEmpty
                                                  ? 'Chưa có sản phẩm'
                                                  : 'Không tìm thấy kết quả',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.navy,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              all.isEmpty
                                                  ? 'Bắt đầu bằng cách thêm sản phẩm đầu tiên.'
                                                  : 'Thử tìm bằng tên sản phẩm khác.',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (_viewMode == ProductViewMode.grid)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final w = constraints.maxWidth;
                                            final int crossAxisCount;
                                            final double childAspectRatio;

                                            if (w >= 1150) {
                                              crossAxisCount = 4;
                                              childAspectRatio = 0.73;
                                            } else if (w >= 820) {
                                              crossAxisCount = 3;
                                              childAspectRatio = 0.73;
                                            } else if (w >= 520) {
                                              crossAxisCount = 2;
                                              childAspectRatio = 0.73;
                                            } else {
                                              // Mobile app (màn hình nhỏ)
                                              crossAxisCount = 2;
                                              childAspectRatio = 0.61;
                                            }

                                            return GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: filtered.length,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: crossAxisCount,
                                                crossAxisSpacing: 12,
                                                mainAxisSpacing: 12,
                                                childAspectRatio:
                                                    childAspectRatio,
                                              ),
                                              itemBuilder: (context, index) {
                                                final item = filtered[index];
                                                return ProductGridCard(
                                                  product: item,
                                                  onEdit: () => _form(item),
                                                  onDelete: () => _delete(item),
                                                  busy: _busyIds.contains(
                                                    item.documentId,
                                                  ),
                                                );
                                              },
                                            );
                                          },
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
                            const SizedBox(height: 24),
                            const Text(
                              'Product Manager • Flutter + Firebase + Cloudinary',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
