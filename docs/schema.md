# Collection product và giá double

Collection chính thức: `product` (số ít). Mỗi document chỉ có bốn field:

| Field | Kiểu | Yêu cầu |
|---|---|---|
| name | String | Tên đã trim, 1–100 ký tự |
| price | Double | Không âm; Rules yêu cầu float |
| soluong | Integer | Số nguyên không âm |
| image | String | HTTPS URL Cloudinary của dự án |

ID chỉ dùng làm khóa nội bộ, không ghi vào Map hoặc JSON. Email/password của Firebase Authentication vẫn dành riêng cho Admin.

## Hiển thị và lưu giá

- `200.0` hiển thị `200,00 ₫`; `12.5` hiển thị `12,50 ₫`.
- Chỉ hiển thị làm tròn tới hai chữ số, dữ liệu gốc không bị làm tròn khi lưu.
- Form sửa dùng đầy đủ giá trị thập phân, chấp nhận dấu chấm hoặc phẩy.
- Web dùng ProductRestWriter gửi price bằng Firestore REST doubleValue, soluong bằng integerValue. Firebase ID token của phiên Admin và Rules vẫn kiểm tra quyền.
- Native Android/iOS dùng kiểu double trong SDK.
- Console có thể rút gọn số tròn khi hiển thị. Kiểu lưu được xác minh qua REST là doubleValue, không suy ra chỉ từ chữ 200 trên Console.
- JSON có kiểu Number chung; không phân biệt int/double bằng hậu tố .0. Dữ liệu nhập lại cần dùng đúng model/writer của app.

## Chuyển users sang product

Script `scripts/move_product_collection.cjs` mặc định chỉ xem trước. Với `--apply`, công cụ:

1. Đọc toàn bộ nguồn users và đích product, kiểm tra đúng schema và ID xung đột.
2. Từ chối khi có dữ liệu đích khác nội dung hoặc có subcollection cần chuyển riêng.
3. Sao lưu nguồn và đích trong .local/backups, quyền file 0600 và bỏ qua trong Git.
4. Copy mỗi bản ghi sang product cùng ID/giá trị, chuẩn hóa price thành doubleValue, rồi bỏ bản nguồn trong cùng commit atomic.
5. Kiểm tra updateTime/exists để không ghi đè chỉnh sửa đồng thời.
6. Đọc lại xác nhận users rỗng và mọi giá trong product đều là doubleValue.

Không đặt lại giá/số lượng về 0 khi chuyển collection. Việc khởi tạo 0 chỉ thuộc lần chuyển schema cũ trước đây. Không thay tài khoản hoặc mật khẩu Firebase Authentication.

Rules hiện tại chỉ mở quyền cho Admin trên product. Đường dẫn users cũ không được app đọc/ghi. Sau cập nhật, dừng server cũ, chạy lại Flutter và refresh Firebase Console để xem product.
