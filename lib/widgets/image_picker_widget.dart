import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../core/utils/app_error.dart';
import '../core/theme/app_theme.dart';
import 'common.dart';

class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    required this.service,
    required this.onChanged,
    this.existingUrl = '',
    this.enabled = true,
  });

  final CloudinaryService service;
  final ValueChanged<XFile> onChanged;
  final String existingUrl;
  final bool enabled;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final _picker = ImagePicker();
  Uint8List? _preview;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) _recover();
  }

  Future<void> _recover() async {
    try {
      final result = await _picker.retrieveLostData();
      if (result.exception != null) throw result.exception!;
      if (result.files?.isNotEmpty == true) await _select(result.files!.first);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    }
  }

  Future<void> _select(XFile file) async {
    final bytes = await widget.service.validatedBytes(file);
    if (!mounted) return;
    setState(() {
      _preview = bytes;
      _error = null;
    });
    widget.onChanged(file);
  }

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await _picker.pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (file != null) await _select(file);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is AppException
              ? e.message
              : 'Không thể mở ảnh. Kiểm tra quyền truy cập thư viện hoặc camera.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xfffafbfe),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: AppTheme.purplePastel.withValues(alpha: 0.4),
        width: 1.2,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.purplePastel.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 18,
                color: AppTheme.purplePrimary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Ảnh sản phẩm',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.navy,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: AppTheme.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.purplePastel.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _preview != null
                    ? Image.memory(
                        _preview!,
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                      )
                    : UserAvatar(name: '?', url: widget.existingUrl, radius: 44),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.enabled && !_busy
                        ? () => _pick(ImageSource.gallery)
                        : null,
                    icon: Icon(
                      Icons.photo_library_rounded,
                      size: 18,
                      color: widget.enabled && !_busy
                          ? AppTheme.purplePrimary
                          : Colors.grey,
                    ),
                    label: Text(_busy ? 'Đang chọn…' : 'Chọn ảnh'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppTheme.purplePastel.withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (!kIsWeb &&
                      [
                        TargetPlatform.android,
                        TargetPlatform.iOS,
                      ].contains(defaultTargetPlatform))
                    OutlinedButton.icon(
                      onPressed: widget.enabled && !_busy
                          ? () => _pick(ImageSource.camera)
                          : null,
                      icon: const Icon(Icons.camera_alt_rounded, size: 18),
                      label: const Text('Chụp ảnh'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: AppTheme.cyanBright.withValues(alpha: 0.6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppTheme.purplePastel.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            const Text(
              'JPG, PNG hoặc WebP • Tối đa 5 MB',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
