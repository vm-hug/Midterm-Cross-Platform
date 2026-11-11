import 'dart:js_interop';
import 'package:web/web.dart' as web;

void downloadJson(String json) {
  final blob = web.Blob(
    [json.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = 'database_products.json';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  Future<void>.delayed(
    const Duration(seconds: 2),
    () => web.URL.revokeObjectURL(url),
  );
}
