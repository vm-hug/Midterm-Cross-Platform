# Kiểm thử schema sản phẩm

Cập nhật ngày 11/11/2026: schema `name`, `price`, `soluong`, `image` trong collection `product`. Firebase Auth Admin vẫn tách riêng email/password.

| Kiểm tra | Trạng thái | Phạm vi |
|---|---|---|
| flutter analyze | PASS | Không có cảnh báo/lỗi |
| flutter test | PASS, 35 test; 1 live test bỏ qua | Model, validators, services, form, Dashboard, Auth, upload mock |
| Firestore Rules Emulator | PASS, 5 nhóm | Admin CRUD; từ chối UID khác/schema cũ/sai kiểu/field thứ năm |
| Web build | PASS | Bản schema sản phẩm |
| Rules cloud | PASS | Rules sản phẩm đã biên dịch/deploy lên giuaki-13b9b |
| Migration cloud | PASS | Đã chuyển 2 bản ghi sang product, users rỗng, giữ ID/giá trị; xác minh doubleValue |

## Ca kiểm tra quan trọng

- Model và JSON có đúng bốn key, price là số và soluong là int; Unicode/ID roundtrip.
- Từ chối schema cũ và price/soluong dạng chuỗi, âm, NaN/Infinity, số lượng lẻ.
- Form sửa giá bằng `12,5` lưu số `12.5`, số lượng `0` lưu số nguyên, giữ ảnh khi không chọn ảnh mới.
- CRUD trên fake Firestore giữ collection product, auto ID, không phục hồi document đã bị xóa đồng thời.
- Sản phẩm có thể trùng tên; không còn kiểm tra email trùng trong CRUD.
- Tìm theo tên và sắp xếp giá/số lượng theo số (2 trước 10).
- Dashboard 375px và 1440px hiển thị tên/giá/số lượng, tìm kiếm, hủy/xác nhận xóa.
- Admin Email/Password và kiểm tra UID giữ nguyên.
- Cloudinary validation, lỗi HTTP/JSON/URL/timeout và ảnh sai bytes giữ nguyên. Test live upload chỉ chạy khi bật RUN_CLOUDINARY_TEST.

## Giới hạn nghiệm thu

Các test dịch vụ/widget dùng fake hoặc mock, Rules dùng Emulator. Không coi chúng là kiểm thử đăng nhập/CRUD đầy đủ trong app trên cloud. Web/iOS bản schema cũ đã build/chạy trước đây; schema sản phẩm mới chỉ ghi nhận platform nào thực sự build ở bảng trên. Android và iOS chưa chạy lại với schema sản phẩm.

## Tái lập

```bash
dart format lib test
flutter analyze
flutter test
JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home" npm run test:rules
flutter build web --dart-define-from-file=config/app.example.json
```

Ảnh `web-startup.jpg`, `ios-startup.png`, `web-login.jpg` và log cũ trong docs/evidence thuộc giai đoạn trước đổi schema; không dùng làm bằng chứng Dashboard sản phẩm mới.

## Bổ sung double và collection product

- Kiểm thử formatter: 200,00 ₫; 12,50 ₫; 0,00 ₫.
- REST writer: doubleValue cho giá tròn, integerValue cho số lượng; create/update có kiểm tra document tồn tại.
- Emulator xác nhận price 0.0/200.0 vẫn là doubleValue; integer price và collection users cũ bị từ chối.
