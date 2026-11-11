import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../core/utils/app_error.dart';
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Ảnh sản phẩm', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 12),
      Row(
        children: [
          if (_preview != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                _preview!,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            )
          else
            UserAvatar(name: '?', url: widget.existingUrl, radius: 44),
          const SizedBox(width: 18),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: widget.enabled && !_busy
                      ? () => _pick(ImageSource.gallery)
                      : null,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(_busy ? 'Đang chọn…' : 'Chọn ảnh'),
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
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Chụp ảnh'),
                  ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      const Text(
        'JPG, PNG hoặc WebP • Tối đa 5 MB',
        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ],
  );
}
