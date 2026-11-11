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

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              Expanded(
                child: Container(
                  color: AppTheme.navy,
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.hub_rounded,
                            color: Color(0xff72dad0),
                            size: 34,
                          ),
                          SizedBox(width: 14),
                          Text(
                            'UserSpace',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Quản lý thông tin và hình ảnh sản phẩm\ntrên Web, Android và iOS.',
                        style: TextStyle(
                          color: Color(0xffb9d1d7),
                          fontSize: 18,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Wrap(
                        spacing: 12,
                        children: [
                          Chip(label: Text('Flutter')),
                          Chip(label: Text('Firebase')),
                          Chip(label: Text('Cloudinary')),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'ĐỒ ÁN LẬP TRÌNH ĐA NỀN TẢNG',
                        style: TextStyle(
                          color: Color(0xffb9d1d7),
                          letterSpacing: 1.4,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(wide ? 56 : 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _form,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_outlined,
                              color: AppTheme.teal,
                              size: 44,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Chào mừng trở lại',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.navy,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Đăng nhập tài khoản Admin để tiếp tục.',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _email,
                              enabled: !_busy,
                              decoration: const InputDecoration(
                                labelText: 'Email Admin',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              validator: Validators.email,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _password,
                              enabled: !_busy,
                              obscureText: _hidden,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu Admin',
                                prefixIcon: const Icon(Icons.lock_outline),
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
                                padding: const EdgeInsets.only(top: 16),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _busy ? null : _login,
                                icon: _busy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  _busy ? 'Đang đăng nhập…' : 'Đăng nhập',
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Chỉ tài khoản Admin được cấp quyền mới có thể truy cập hệ thống.',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                height: 1.6,
                                fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}
