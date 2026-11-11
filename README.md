<<<<<<< HEAD

# Midterm-Cross-Platform

=======

# UserSpace quản lý sản phẩm

Ứng dụng Admin Flutter dùng chung trên Web, Android và iOS. Firebase Authentication xác thực Admin; Cloud Firestore lưu sản phẩm; Cloudinary lưu ảnh.

## Schema hiện tại

Collection chính thức là `product` (số ít). Mỗi document chỉ có bốn field:

| Field   | Kiểu Firestore | Ý nghĩa                                |
| ------- | -------------- | -------------------------------------- |
| name    | String         | Tên sản phẩm, trim, 1–100 ký tự        |
| price   | Double         | Giá không âm, có thể có phần thập phân |
| soluong | Integer        | Số lượng nguyên không âm               |
| image   | String         | HTTPS URL ảnh Cloudinary của dự án     |

`price` và `soluong` được lưu dưới dạng số, không phải chuỗi. Giới hạn trên là 9007199254740991 để tránh mất độ chính xác số nguyên trên Web. Document ID chỉ dùng nội bộ, không có trong Map/JSON.

Đăng nhập Admin vẫn sử dụng email/password của Firebase Authentication, tách khỏi dữ liệu sản phẩm.

## Chức năng

- Admin login/logout và kiểm tra UID tại Auth Gate + Rules server.
- Thêm/sửa/xóa sản phẩm theo document ID; realtime, loading/error/empty state.
- Form tên, giá VNĐ, số lượng, ảnh; chặn số âm, NaN/Infinity và số lượng lẻ.
- Chấp nhận dấu chấm hoặc phẩy làm dấu thập phân của giá; ví dụ `12,5` lưu thành `12.5`.
- Chọn ảnh JPG/PNG/WebP ≤ 5 MB, preview/upload Cloudinary, giữ ảnh khi sửa.
- Bảng Web và card mobile; tìm kiếm tên, sắp xếp tên/giá/số lượng theo đúng kiểu dữ liệu.
- Thống kê số sản phẩm và tổng số lượng; xác nhận trước khi xóa.
- Xuất `database_products.json` trên Web, gồm đúng bốn field và giữ kiểu số.

## Chạy

```bash
flutter pub get
flutter run -d web-server
# Hoặc
bash scripts/run.sh chrome
```

Firebase options thật đã được FlutterFire sinh cho ba app thuộc project `giuaki-13b9b`. Nếu thay project hoặc Bundle ID, xem [cài đặt](docs/setup.md). Tham số công khai ở `config/app.example.json`; không đưa mật khẩu Admin, API Secret hay service account vào source.

## Kiểm tra

```bash
dart format lib test
flutter analyze
flutter test
npm ci
npm run test:rules
flutter build web --dart-define-from-file=config/app.example.json
```

`npm` chỉ dùng để kiểm thử/triển khai Rules và công cụ quản trị migration, không phải backend của ứng dụng. Rules Emulator luôn dùng project `demo-userspace`, không ghi vào cloud thật.

## Chuyển collection và kiểu giá

Collection đang dùng là `product`. Script chuyển từ `users` giữ nguyên ID, tên, giá trị giá, số lượng và ảnh; chỉ chuẩn hóa kiểu của `price` thành double. Bản sao cũ nằm trong `.local/backups/`, không đưa lên Git.

```bash
node scripts/move_product_collection.cjs          # xem trước
node scripts/move_product_collection.cjs --apply  # thực hiện sau khi duyệt
node scripts/export_products.cjs                 # đọc product và xuất JSON
```

Script sao lưu cả nguồn/đích, kiểm tra trùng ID và subcollection, rồi copy sang `product` và bỏ bản nguồn trong một commit atomic có điều kiện updateTime. Không ghi đè bản đích khác nội dung. Script `migrate_product_schema.cjs` chỉ lưu lại bước lịch sử chuyển schema trước đây, không phải lệnh chuyển collection hiện tại.

## Giá double và cách hiển thị

Giá trong model là `double`; Rules yêu cầu `float` trên Firestore. Bảng và card luôn hiển thị hai chữ số thập phân: `200.0 → 200,00 ₫`, `12.5 → 12,50 ₫`. Đây là định dạng hiển thị; không làm tròn dữ liệu khi lưu hay khi mở form sửa.

Trên Web, JS SDK có thể phân loại số tròn thành integer. `ProductRestWriter` gửi kiểu [`doubleValue` rõ ràng](https://firebase.google.com/docs/firestore/reference/rest/v1/Value), dùng [Firebase ID token và Security Rules](https://firebase.google.com/docs/firestore/use-rest-api) của chính Admin. Không có backend/service-account hoặc token hardcode. Android/iOS ghi double qua SDK native. Tên collection dùng chung qua `AppConfig.productCollection`.

## Cấu trúc

```text
lib/models/product_model.dart       schema bốn field
lib/services/firestore_service.dart CRUD sản phẩm trong product
lib/services/export_service.dart   JSON giữ kiểu số
lib/screens/product_form_screen.dart
lib/screens/dashboard_screen.dart
lib/widgets/product_table.dart
lib/widgets/product_card.dart
lib/core/utils/product_query.dart  tìm kiếm/sắp xếp số
```

- [Kiểm thử](docs/testing.md)
- [Cài đặt ba nền tảng](docs/setup.md)
- [Schema và chuyển đổi dữ liệu](docs/schema.md)
- [Báo cáo kỹ thuật](docs/report/bao_cao_userspace.docx)
- [Kịch bản demo](docs/demo-script.md)
- [Dữ liệu mẫu](database_products.sample.json)

Ảnh cũ khi sửa/xóa sản phẩm còn trong Cloudinary, dọn thủ công bằng Media Library. Không dùng Cloudinary API Secret trong Flutter.

> > > > > > > 8ac276d (done midterm-cross-platform)
