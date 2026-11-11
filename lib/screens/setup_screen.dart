import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key, required this.error});
  final Object error;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hub_rounded,
                      color: AppTheme.teal,
                      size: 48,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'UserSpace',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kết nối Firebase để bắt đầu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ứng dụng quản lý sản phẩm • Web / Android / iOS',
                    ),
                    const SizedBox(height: 24),
                    const SelectableText(
                      '1. firebase login\n2. dart pub global activate flutterfire_cli\n3. flutterfire configure --project=giuaki-13b9b --platforms=web,android,ios\n4. Khởi động lại ứng dụng',
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Xem docs/setup.md để cấu hình Auth, Firestore Rules và Cloudinary.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error is UnsupportedError
                          ? 'Chưa có cấu hình Firebase được tạo bởi FlutterFire CLI.'
                          : 'Firebase khởi tạo chưa thành công. Kiểm tra cấu hình và kết nối.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
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
