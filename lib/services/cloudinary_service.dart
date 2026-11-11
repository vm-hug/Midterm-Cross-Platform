import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../core/config/app_config.dart';
import '../core/utils/validators.dart';
import '../core/utils/app_error.dart';

class CloudinaryService {
  CloudinaryService({this._client, this.timeout = const Duration(seconds: 45)});
  final http.Client? _client;
  final Duration timeout;

  static bool validSignature(Uint8List b) =>
      (b.length >= 3 && b[0] == 0xff && b[1] == 0xd8 && b[2] == 0xff) ||
      (b.length >= 8 && b.take(8).join(',') == '137,80,78,71,13,10,26,10') ||
      (b.length >= 12 &&
          ascii.decode(b.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
          ascii.decode(b.sublist(8, 12), allowInvalid: true) == 'WEBP');

  Future<Uint8List> validatedBytes(XFile file) async {
    final error = Validators.image(file.name, await file.length());
    if (error != null) throw AppException(error);
    final bytes = await file.readAsBytes();
    final actualError = Validators.image(file.name, bytes.length);
    if (actualError != null) throw AppException(actualError);
    if (!validSignature(bytes)) {
      throw const AppException(
        'Nội dung tệp không phải ảnh JPG, PNG hoặc WebP.',
      );
    }
    return bytes;
  }

  Future<String> upload(XFile file) async {
    final bytes = await validatedBytes(file);
    final client = _client ?? http.Client();
    try {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.https(
                'api.cloudinary.com',
                '/v1_1/${AppConfig.cloudName}/image/upload',
              ),
            )
            ..fields['upload_preset'] = AppConfig.uploadPreset
            ..files.add(
              http.MultipartFile.fromBytes('file', bytes, filename: file.name),
            );
      final response = await (() async {
        final stream = await client.send(request);
        return http.Response.fromStream(stream);
      })().timeout(timeout);
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw const AppException('Cloudinary trả về dữ liệu không hợp lệ.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final detail = data['error'] is Map
            ? (data['error'] as Map)['message']
            : null;
        throw AppException(
          'Không tải được ảnh (${response.statusCode})${detail is String ? ': $detail' : '.'}',
        );
      }
      final url = data['secure_url'];
      if (url is! String || !Validators.cloudinaryUrl(url)) {
        throw const AppException('Cloudinary không trả về secure_url hợp lệ.');
      }
      return url;
    } on http.ClientException {
      throw const AppException('Không tải được ảnh. Vui lòng kiểm tra mạng.');
    } finally {
      if (_client == null) client.close();
    }
  }
}
