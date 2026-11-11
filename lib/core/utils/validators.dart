import '../config/app_config.dart';

abstract final class Validators {
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập email.';
    if (text.length > 254 ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Email không hợp lệ.';
    }
    return null;
  }

  static String? productName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập tên sản phẩm.';
    if (text.length > 100) return 'Tên sản phẩm tối đa 100 ký tự.';
    return null;
  }

  static double? parsePrice(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));
  static String? price(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập giá sản phẩm.';
    final number = parsePrice(text);
    if (!RegExp(r'^(?:[0-9]+(?:[.,][0-9]+)?|[.,][0-9]+)$').hasMatch(text) ||
        number == null ||
        !number.isFinite ||
        number < 0 ||
        number > 9007199254740991) {
      return 'Giá phải là số không âm, tối đa 9007199254740991.';
    }
    return null;
  }

  static String? quantity(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Vui lòng nhập số lượng.';
    final number = int.tryParse(text);
    if (!RegExp(r'^[0-9]+$').hasMatch(text) ||
        number == null ||
        number > 9007199254740991) {
      return 'Số lượng phải là số nguyên không âm, tối đa 9007199254740991.';
    }
    return null;
  }

  static String? image(String name, int size) {
    final ext = name.toLowerCase().split('.').last;
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      return 'Chỉ chấp nhận JPG, PNG hoặc WebP.';
    }
    if (size <= 0) return 'Ảnh đang trống.';
    if (size > AppConfig.maxImageBytes) {
      return 'Ảnh phải nhỏ hơn hoặc bằng 5 MB.';
    }
    return null;
  }

  static bool cloudinaryUrl(String value) {
    final uri = Uri.tryParse(value);
    return value.length <= 2048 &&
        uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'res.cloudinary.com' &&
        uri.userInfo.isEmpty &&
        !uri.hasPort &&
        uri.path.startsWith('/${AppConfig.cloudName}/image/upload/') &&
        uri.pathSegments.length >= 4 &&
        uri.pathSegments.last.isNotEmpty;
  }
}
