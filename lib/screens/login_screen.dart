import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/utils/validators.dart';
import '../core/utils/app_error.dart';
import '../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthGateway auth;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.signIn(_email.text, _password.text);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _techChip(String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: AppTheme.purplePastel.withValues(alpha: 0.4),
        width: 1.2,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.cyanBright),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: SafeArea(
        child: Row(
          children: [
            // CỘT BÊN TRÁI: HERO SECTION (Hiển thị khi màn hình rộng >= 900)
            if (wide)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.purpleDark, AppTheme.purpleDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Hiệu ứng quầng sáng Cyber-Pastel background
                      Positioned(
                        top: -60,
                        left: -60,
                        child: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.cyanBright.withValues(alpha: 0.22),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        right: -40,
                        child: Container(
                          width: 340,
                          height: 340,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.purplePastel.withValues(alpha: 0.22),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.brandGradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.cyanBright.withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.hub_rounded,
                                    color: AppTheme.purpleDark,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  'Product Manager',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyanBright.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppTheme.cyanBright.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: AppTheme.cyanBright,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Sản phẩm.\nMột không gian.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Quản lý thông tin và hình ảnh sản phẩm\ntrên Web, Android và iOS.',
                              style: TextStyle(
                                color: AppTheme.purplePastel.withValues(alpha: 0.85),
                                fontSize: 18,
                                height: 1.7,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                _techChip('Flutter', Icons.flutter_dash_rounded),
                                _techChip('Firebase', Icons.local_fire_department_rounded),
                                _techChip('Cloudinary', Icons.cloud_done_rounded),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.cyanBright,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'ĐỒ ÁN LẬP TRÌNH ĐA NỀN TẢNG',
                                  style: TextStyle(
                                    color: AppTheme.purplePastel.withValues(alpha: 0.75),
                                    letterSpacing: 2.0,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // CỘT BÊN PHẢI: FORM ĐĂNG NHẬP
            Expanded(
              child: Container(
                color: AppTheme.scaffoldBg,
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 48 : 20,
                      vertical: 36,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.cardBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.purpleDark.withValues(alpha: 0.06),
                              blurRadius: 36,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(wide ? 42 : 28),
                          child: Form(
                            key: _form,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ICON QUẢN TRỊ VIÊN: Dùng icon chiếc khiên bảo mật rõ nét, không lỗi font
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.brandGradient,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.purplePastel.withValues(alpha: 0.4),
                                          blurRadius: 14,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.shield_rounded,
                                        color: AppTheme.purpleDark,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Chào mừng trở lại',
                                    style: Theme.of(context).textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.navy,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Đăng nhập tài khoản Admin để tiếp tục.',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  TextFormField(
                                    controller: _email,
                                    enabled: !_busy,
                                    decoration: const InputDecoration(
                                      labelText: 'Email Admin',
                                      prefixIcon: Icon(
                                        Icons.alternate_email_rounded,
                                        size: 20,
                                        color: AppTheme.purpleAccent,
                                      ),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [AutofillHints.username],
                                    validator: Validators.email,
                                    textInputAction: TextInputAction.next,
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _password,
                                    enabled: !_busy,
                                    obscureText: _hidden,
                                    autofillHints: const [AutofillHints.password],
                                    decoration: InputDecoration(
                                      labelText: 'Mật khẩu Admin',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        size: 20,
                                        color: AppTheme.purpleAccent,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: _hidden
                                            ? 'Hiện mật khẩu'
                                            : 'Ẩn mật khẩu',
                                        onPressed: () =>
                                            setState(() => _hidden = !_hidden),
                                        icon: Icon(
                                          _hidden
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Vui lòng nhập mật khẩu.'
                                        : null,
                                    onFieldSubmitted: (_) => _login(),
                                  ),
                                  if (_error != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 18),
                                      child: Semantics(
                                        liveRegion: true,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.redAccent.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.error_outline_rounded,
                                                size: 18,
                                                color: Colors.redAccent,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  _error!,
                                                  style: const TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 28),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: FilledButton.icon(
                                      onPressed: _busy ? null : _login,
                                      icon: _busy
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.arrow_forward_rounded, size: 20),
                                      label: Text(
                                        _busy ? 'Đang đăng nhập…' : 'Đăng nhập',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.verified_user_rounded,
                                        size: 16,
                                        color: AppTheme.purpleAccent,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Chỉ tài khoản Admin được cấp quyền mới có thể truy cập hệ thống.',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            height: 1.5,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
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
            ),
          ],
        ),
      ),
    );
  }
}
