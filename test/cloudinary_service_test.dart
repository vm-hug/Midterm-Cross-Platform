import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midterm_cross_platform/services/cloudinary_service.dart';
import 'package:midterm_cross_platform/core/utils/app_error.dart';

void main() {
  final bytes = Uint8List.fromList(
    base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
    ),
  );
  XFile file() => XFile.fromData(bytes, name: 'avatar.png', path: 'avatar.png');
  test('Multipart contains preset and image; returns secure_url', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'https://api.cloudinary.com/v1_1/dqv9sna9b/image/upload',
      );
      expect(request.headers['content-type'], contains('multipart/form-data'));
      final body = utf8.decode(request.bodyBytes, allowMalformed: true);
      expect(body, contains('flutter_unsigned_users'));
      expect(body, contains('avatar.png'));
      expect(body, isNot(contains('api_secret')));
      return http.Response(
        jsonEncode({
          'secure_url':
              'https://res.cloudinary.com/dqv9sna9b/image/upload/test.png',
        }),
        200,
      );
    });
    expect(
      await CloudinaryService(client: client).upload(file()),
      endsWith('test.png'),
    );
  });
  test('Reject forged image bytes before network call', () async {
    final service = CloudinaryService(
      client: MockClient((_) async => throw StateError('Must not send')),
    );
    await expectLater(
      service.upload(
        XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'fake.png',
          path: 'fake.png',
        ),
      ),
      throwsA(isA<AppException>()),
    );
  });
  for (final scenario in [
    ('bad json', 200),
    ('{"error":{"message":"Invalid preset"}}', 400),
    ('{"secure_url":"http://bad.test/a.jpg"}', 200),
    ('{}', 200),
  ]) {
    test('Reject Cloudinary error response $scenario', () async {
      final service = CloudinaryService(
        client: MockClient(
          (_) async => http.Response(scenario.$1, scenario.$2),
        ),
      );
      await expectLater(service.upload(file()), throwsA(isA<AppException>()));
    });
  }
  test('Timeout covers upload and response body', () async {
    final service = CloudinaryService(
      timeout: const Duration(milliseconds: 10),
      client: MockClient((_) => Completer<http.Response>().future),
    );
    await expectLater(service.upload(file()), throwsA(isA<TimeoutException>()));
  });
}
