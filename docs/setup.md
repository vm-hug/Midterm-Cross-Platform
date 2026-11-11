# Cài đặt UserSpace

## 1. Công cụ

```bash
flutter --version
dart --version
flutter doctor -v
flutter devices
flutter emulators
xcodebuild -version
xcrun simctl list devices available
```

Dự án tạo bằng Flutter 3.44.3 / Dart 3.12.2. Android yêu cầu minSdk 24; iOS deployment target 15.0. Thư viện được khóa trong pubspec.lock. Xcode/CocoaPods phải tương thích với plugin đang dùng. Nếu Flutter SPM không giải quyết được phụ thuộc, cài CocoaPods theo hướng dẫn chính thức và dùng `ios/Runner.xcworkspace`. Không xóa Pods hay lockfile khi chưa xác định nguyên nhân.

Nếu `flutter doctor` báo thiếu giấy phép Android, tự chạy `flutter doctor --android-licenses`, đọc và quyết định chấp nhận từng giấy phép. Nếu cần hoàn tất thiết lập Xcode, mở Xcode và hoàn tất các bước mà công cụ yêu cầu.

## 2. Firebase

1. Dùng tài khoản sở hữu project `giuaki-13b9b`. Bật Authentication → Email/Password.
2. Admin đã được chỉ định bằng UID `kmRuft7UYMb3Qihsqzqaa691hkr1`. Không lưu mật khẩu trong source.
3. Tạo Firestore Database nếu chưa có. Không mở Test Mode công khai.
4. Đăng ký đủ Web/Android/iOS qua FlutterFire CLI. Android application ID: `vn.edu.midterm.midterm_cross_platform`; iOS Bundle ID lấy chính xác từ Runner target.

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
bash scripts/configure_firebase.sh
flutter pub get
```

FlutterFire tự sinh `lib/firebase_options.dart` và các cấu hình native. Không viết API key hoặc App ID giả. Nếu CLI hỏi ghi đè cấu hình hiện tại, chỉ chọn có khi đang cấu hình đúng project. Kiểm tra đủ web, android và ios. Bundle ID phải trùng Firebase iOS App.

Kiểm tra Rules và triển khai:

```bash
npm ci
npm run test:rules
bash scripts/deploy_rules.sh
```

Rules chỉ cho Admin UID đọc/ghi `product`, kiểm tra đúng bốn field: name/image String, price Double, soluong Integer, giới hạn độ dài và HTTPS URL. Collection khác mặc định bị từ chối. Đổi dart-define ADMIN_UID không tự đổi Rules server.

## 3. Cloudinary

Cloud Name `dqv9sna9b`; unsigned upload preset `flutter_unsigned_users` đã được nhìn thấy trong Console. Trong preset đặt giới hạn định dạng JPG/PNG/WebP và kích thước 5 MB. Không nhúng API Secret. Các biến client có thể công khai. Ảnh cũ không tự xóa, dọn bằng Media Library.

## 4. Web

```bash
bash scripts/run.sh chrome
flutter build web --dart-define-from-file=config/app.example.json
```

Đăng nhập bằng tài khoản Admin Firebase thật. Sau khi thêm dữ liệu, F5 và kiểm tra dữ liệu còn; đăng xuất để kiểm tra Auth Gate. Không lưu mật khẩu vào lệnh hay tệp cấu hình. Firebase Auth phải cho phép localhost trong Authorized domains nếu cần.

## 5. Android

```bash
flutter emulators
flutter emulators --launch Pixel_9a
flutter devices
bash scripts/run.sh <ANDROID_DEVICE_ID>
flutter build apk --debug --dart-define-from-file=config/app.example.json
```

Thay placeholder bằng ID thật trong `flutter devices`. Quyền Internet có trong manifest chính, gallery dùng Photo Picker. Mã xử lý retrieveLostData khi Android khôi phục Activity. Đưa ảnh JPG/PNG vào emulator để thử; camera là tùy chọn.

## 6. iOS

```bash
open -a Simulator
xcrun simctl list devices available
flutter devices
bash scripts/run.sh <IOS_SIMULATOR_ID>
flutter build ios --simulator --debug --dart-define-from-file=config/app.example.json
```

Đã thêm NSPhotoLibraryUsageDescription và NSCameraUsageDescription. Chọn JPG/PNG/WebP trong Photos; iOS Simulator có giới hạn HEIC và không có camera thực. Không đánh dấu lỗi camera Simulator là lỗi gallery. iOS deployment target tối thiểu 15.0; khi plugin đòi phiên bản cao hơn, theo thông báo dependency resolver.

Nếu FlutterFire báo `cannot load such file -- xcodeproj`, Ruby đang dùng thiếu gem `xcodeproj`. Cài gem vào môi trường Ruby phù hợp rồi chạy lại FlutterFire.

## 7. Lỗi thường gặp

- Màn hình yêu cầu kết nối Firebase: chạy FlutterFire CLI và khởi động lại app.
- Permission denied: kiểm tra đúng UID, đăng nhập và Rules đã deploy.
- Invalid preset: kiểm tra cloud name, preset tồn tại và chế độ Unsigned.
- No Firebase App: kiểm tra options và Bundle ID ba platform.
- Ảnh lỗi: kiểm tra URL HTTPS thực, mạng, định dạng và giới hạn dung lượng.
- Upload thành công nhưng Firestore lỗi: ảnh có thể còn trong Cloudinary, form giữ URL cho lần thử lại.
- Giá/số lượng không hợp lệ: dùng giá không âm và số lượng nguyên không âm; không nhập dấu phân cách hàng nghìn.

## 8. Export và nộp

Trên Dashboard Web nhấn Xuất JSON. Tệp tải về là `database_products.json`, gồm toàn bộ document hiện tại và đúng bốn field, không có metadata. Chỉ sử dụng dữ liệu giả. Không đổi tên dữ liệu mẫu thành bản xuất cloud khi chưa thực sự export.
