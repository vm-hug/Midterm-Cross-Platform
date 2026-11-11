import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midterm_cross_platform/services/cloudinary_service.dart';
import 'package:midterm_cross_platform/core/utils/validators.dart';

// Explicit opt-in: uploads a generated, non-personal avatar to the demo preset.
void main() {
  test(
    'Live Cloudinary upload returns a reachable project HTTPS URL',
    () async {
      final url = await CloudinaryService().upload(
        XFile('assets/demo/avatar.png'),
      );
      expect(Validators.cloudinaryUrl(url), isTrue);
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        expect(response.statusCode, 200);
        expect(response.headers.contentType?.mimeType, startsWith('image/'));
        await response.drain<void>();
      } finally {
        client.close();
      }
      File('docs/evidence/cloudinary-live-url.txt').writeAsStringSync('$url\n');
    },
    skip: !const bool.fromEnvironment('RUN_CLOUDINARY_TEST'),
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
