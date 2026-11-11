import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key, required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.scaffoldBg,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppTheme.cardBorder, width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanBright.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: AppTheme.purpleDark,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'UserSpace',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kết nối Firebase để bắt đầu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.purplePrimary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ứng dụng quản lý sản phẩm • Web / Android / iOS',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.purpleDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.purplePastel.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const SelectableText(
                        '1. firebase login\n2. dart pub global activate flutterfire_cli\n3. flutterfire configure --project=giuaki-13b9b --platforms=web,android,ios\n4. Khởi động lại ứng dụng',
                        style: TextStyle(
                          color: AppTheme.cyanLight,
                          fontFamily: 'monospace',
                          height: 1.8,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Xem docs/setup.md để cấu hình Auth, Firestore Rules và Cloudinary.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
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
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error is UnsupportedError
                                  ? 'Chưa có cấu hình Firebase được tạo bởi FlutterFire CLI.'
                                  : 'Firebase khởi tạo chưa thành công. Kiểm tra cấu hình và kết nối.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
  );
}
