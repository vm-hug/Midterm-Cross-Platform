from pathlib import Path
from docx import Document
from docx.shared import Cm, Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'docs/report/bao_cao_userspace.docx'
doc = Document()
sec=doc.sections[0]
sec.page_width=Cm(21);sec.page_height=Cm(29.7)
sec.top_margin=Cm(1.8);sec.bottom_margin=Cm(1.7);sec.left_margin=Cm(2);sec.right_margin=Cm(2)
for name in ['Normal','Title','Subtitle','Heading 1','Heading 2','Heading 3']:
 s=doc.styles[name];s.font.name='Arial';s.font.color.rgb=RGBColor(0,0,0)
 s.font.size=Pt(10.5 if name=='Normal' else {'Title':25,'Subtitle':12,'Heading 1':18,'Heading 2':12.5,'Heading 3':11}[name])
 s.paragraph_format.space_after=Pt(7)
doc.styles['Normal'].paragraph_format.line_spacing=1.15
for name in ['Heading 1','Heading 2','Heading 3']:
 doc.styles[name].paragraph_format.space_before=Pt(12)
 doc.styles[name].paragraph_format.keep_with_next=True

def p(text,style=None): return doc.add_paragraph(text,style)
def h(text): doc.add_heading(text,1)
def sub(text): doc.add_heading(text,2)
def code(text):
 for line in text.splitlines():
  x=p(line); x.paragraph_format.space_after=Pt(3)
  for run in x.runs:run.font.name='Courier New';run.font.size=Pt(8.2)
def table(headers,rows,widths):
 t=doc.add_table(rows=1, cols=len(headers));t.alignment=WD_TABLE_ALIGNMENT.CENTER;t.autofit=False
 for i,w in enumerate(widths):t.columns[i].width=Cm(w)
 for c,txt in zip(t.rows[0].cells,headers):c.text=txt
 for data in rows:
  for c,txt in zip(t.add_row().cells,data):c.text=str(txt)
 for ri,row in enumerate(t.rows):
  for i,c in enumerate(row.cells):
   c.width=Cm(widths[i]);c.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER
   pr=c._tc.get_or_add_tcPr()
   borders=OxmlElement('w:tcBorders')
   for edge in ['top','left','bottom','right','insideH','insideV']:
    x=OxmlElement('w:'+edge);x.set(qn('w:val'),'single');x.set(qn('w:sz'),'4');x.set(qn('w:color'),'D9D9D9');borders.append(x)
   pr.append(borders)
   margins=OxmlElement('w:tcMar')
   for edge in ['top','left','bottom','right']:
    x=OxmlElement('w:'+edge);x.set(qn('w:w'),'100');x.set(qn('w:type'),'dxa');margins.append(x)
   pr.append(margins)
   sh=OxmlElement('w:shd');sh.set(qn('w:fill'),'243C4A' if ri==0 else ('F2F6F8' if ri%2==0 else 'FFFFFF'));pr.append(sh)
   for par in c.paragraphs:
    par.paragraph_format.space_after=Pt(3);par.paragraph_format.line_spacing=1.05
    for run in par.runs:
     run.font.size=Pt(9)
     if ri==0:run.font.bold=True;run.font.color.rgb=RGBColor(255,255,255)
 trPr=t.rows[0]._tr.get_or_add_trPr();repeat=OxmlElement('w:tblHeader');trPr.append(repeat)
 p('')
 return t
def page():doc.add_page_break()

doc.add_heading('Báo cáo triển khai ứng dụng UserSpace',0)
p('Quản lý sản phẩm trên Flutter Web Android iOS','Subtitle')
p('Cập nhật schema ngày 11 tháng 11 năm 2026')
sub('Kết quả triển khai')
p('Ứng dụng được cập nhật theo cấu trúc dữ liệu sản phẩm gồm name, price, soluong, image. Giao diện CRUD, model, Firestore service, Rules, tìm kiếm, sắp xếp và JSON export dùng thống nhất schema mới. Giá được lưu dưới dạng số và số lượng là số nguyên không âm. Firebase Authentication vẫn xác thực Admin bằng email và mật khẩu riêng.')
p('Ba mươi lăm kiểm thử Flutter và năm nhóm Rules Emulator đạt. Bản Web mới biên dịch thành công. Rules mới đã triển khai lên project giuaki-13b9b; dữ liệu được sao lưu và chuyển từ users sang product, giữ nguyên ID và giá trị, chuẩn hóa price thành double.')
sub('Schema dữ liệu hiện tại')
p('Tên collection chính thức là product (số ít). Mỗi document chỉ có bốn field; document ID dùng nội bộ và không được ghi vào payload hoặc JSON.')
table(['Field','Kiểu','Ý nghĩa'],[
 ('name','String','Tên sản phẩm sau trim, từ 1 đến 100 ký tự'),
 ('price','Double','Giá không âm, cho phép phần thập phân'),
 ('soluong','Integer','Số lượng nguyên không âm'),
 ('image','String','HTTPS URL ảnh Cloudinary của dự án')],[3,3.5,10.5])
sub('Dữ liệu minh họa')
code('{\n  "name": "Sản phẩm mẫu",\n  "price": 12500.5,\n  "soluong": 3,\n  "image": "https://res.cloudinary.com/dqv9sna9b/image/upload/a.png"\n}')
p('Ví dụ minh họa schema, không phải minh chứng URL ảnh này tồn tại. Dữ liệu đọc từ Firestore thật được bàn giao riêng trong database_products.json.')
sub('Nguyên tắc xác thực')
p('Admin thuộc Firebase Authentication, UID kmRuft7UYMb3Qihsqzqaa691hkr1. Dữ liệu sản phẩm không chứa email hoặc mật khẩu. Thay đổi schema không thay tài khoản Admin và không ghi thêm field role, timestamp hoặc metadata.')

page();h('Kiến trúc và các chức năng')
sub('Phân lớp mã nguồn')
table(['Thành phần','Trách nhiệm'],[
 ('ProductModel','Parse schema và xuất Map đúng bốn field'),
 ('FirestoreService','Realtime và CRUD theo document ID trong collection product'),
 ('ProductFormScreen','Tên, giá, số lượng, chọn ảnh và lưu dữ liệu'),
 ('ProductTable và ProductCard','Bảng Web và danh sách mobile'),
 ('ProductQuery','Tìm tên và sắp xếp tên, giá, số lượng'),
 ('CloudinaryService','Đọc XFile bằng bytes, multipart, timeout và secure_url'),
 ('ExportService','Xuất mảng JSON, giữ kiểu số và loại document ID')],[5,12])
sub('Thêm và chỉnh sửa')
p('Form nhập tên, giá VNĐ, số lượng và ảnh. Giá chấp nhận dấu chấm hoặc dấu phẩy thập phân; ví dụ 12,5 được lưu thành số 12.5. Giá âm, NaN/Infinity, số lượng âm hoặc có phần thập phân bị từ chối. Giá và số lượng tối đa 9007199254740991 để tránh vượt miền số nguyên biểu diễn chính xác trên Web.')
p('Ảnh mới phải upload Cloudinary thành công trước khi ghi Firestore. Khi sửa không chọn ảnh mới, ứng dụng giữ URL cũ. Nếu Firestore thất bại sau upload, form giữ secure_url để thử lại. Update không tạo lại document đã bị xóa đồng thời.')
sub('Giá double và định dạng hiển thị')
p('Giao diện luôn hiển thị hai chữ số thập phân: 200.0 thành 200,00 ₫ và 12.5 thành 12,50 ₫. Dữ liệu khi lưu không bị làm tròn theo cách hiển thị. Trên Web, ProductRestWriter gửi doubleValue rõ ràng qua REST với Firebase ID token của Admin; Security Rules vẫn kiểm tra quyền. Android/iOS ghi double qua SDK native. Console có thể hiển thị gọn số tròn; kiểu thật được kiểm tra qua REST.')
sub('Danh sách và tiện ích')
p('Web dùng bảng tên, giá, số lượng và thao tác sửa/xóa. Mobile dùng card. Tìm kiếm chỉ theo tên sản phẩm. Giá và số lượng được so sánh theo số, bảo đảm 2 đứng trước 10. Dashboard hiển thị tổng số sản phẩm và tổng số lượng. Xóa có hộp thoại xác nhận; ảnh cũ vẫn còn trên Cloudinary để dọn thủ công.')
sub('Firestore Rules')
p('Rules chỉ cho UID Admin đọc/ghi product. Mọi create/update kiểm tra chính xác bốn key, đúng kiểu, miền giá trị và HTTPS URL Cloudinary. Schema cũ, giá/số lượng dạng chuỗi, số lượng lẻ và field thứ năm bị từ chối. Các collection khác mặc định không có quyền truy cập.')

page();h('Chuyển đổi dữ liệu và kiểm thử')
sub('Chuyển đổi đã thực hiện')
p('Dữ liệu được chuyển từ collection users sang product (số ít), giữ document ID, tên, giá, số lượng và ảnh. Giá được chuẩn hóa thành kiểu doubleValue, bao gồm giá tròn như 200.0. Không đặt lại giá hoặc số lượng về 0 khi chuyển collection.')
p('Công cụ sao lưu nguồn và đích trong .local/backups trước khi copy và bỏ bản nguồn trong một commit atomic. Điều kiện updateTime và exists tránh ghi đè thay đổi đồng thời; dữ liệu đích xung đột hoặc subcollection làm công cụ dừng. Sau chuyển, công cụ xác minh users rỗng và giá trong product là doubleValue.')
code('node scripts/move_product_collection.cjs\nnode scripts/move_product_collection.cjs --apply')
p('Mặc định chỉ xem trước. Tùy chọn apply thực hiện kế hoạch đã duyệt; công cụ không thay đổi Firebase Authentication.')
sub('Kết quả kiểm chứng')
table(['Kiểm tra','Kết quả','Phạm vi'],[
 ('flutter analyze','Đạt','Không có cảnh báo hoặc lỗi'),
 ('flutter test','35 test đạt','Một live test Cloudinary mặc định bỏ qua'),
 ('Rules Emulator','5 nhóm đạt','Phân quyền, CRUD, schema, số âm/sai kiểu'),
 ('Form sản phẩm','Đạt trong widget test','Đổi giá 12,5 và số lượng 0, giữ ảnh'),
 ('Dashboard','Đạt trong widget test','375px/1440px; tìm kiếm và xác nhận xóa'),
 ('Web build','Đạt','Bản schema sản phẩm'),
 ('Rules cloud','Đã triển khai','Project giuaki-13b9b'),
 ('Migration cloud','Đã xác minh','2 bản ghi trong product; users rỗng, giá double')],[4,3.5,9.5])
p('Các test widget/service dùng fake hoặc mock; Rules dùng Emulator. Chúng không thay thế kiểm thử đăng nhập và CRUD đầy đủ trong ứng dụng trên cloud. Android và iOS chưa build/chạy lại với schema sản phẩm; kết quả native trước đó thuộc phiên bản schema cũ.')

page();h('Cài đặt và bàn giao')
sub('Chạy ứng dụng')
code('flutter pub get\nflutter run -d web-server\n# Hoặc chạy Chrome\nbash scripts/run.sh chrome')
p('Nếu đang mở phiên bản cũ, dừng Flutter bằng Ctrl+C rồi chạy lại; mở URL mới từ Terminal và tải lại trang. Đăng nhập bằng tài khoản Admin Firebase Authentication hiện có.')
sub('Kiểm tra và triển khai')
code('dart format lib test\nflutter analyze\nflutter test\nnpm run test:rules\nflutter build web --dart-define-from-file=config/app.example.json\nbash scripts/deploy_rules.sh')
p('Firebase options thật cho Web/Android/iOS đã được FlutterFire sinh từ project giuaki-13b9b. Cloudinary dùng cloud dqv9sna9b và unsigned preset flutter_unsigned_users. Preset giữ nguyên tên; không có API Secret trong Flutter. Cấu hình và hướng dẫn native trong docs/setup.md.')
sub('Xuất dữ liệu')
p('Nút Xuất JSON trên Dashboard Web đọc toàn bộ collection từ server và tải database_products.json. Mỗi object có đúng name, price, soluong, image, giữ price/soluong là số. database_products.sample.json là ví dụ riêng, không được nhầm với bản xuất cloud.')
code('node scripts/export_products.cjs')
p('Công cụ CLI trên chỉ đọc và xuất cùng schema bằng phiên đăng nhập Firebase CLI của chủ dự án. npm được dùng cho công cụ quản trị và kiểm thử, không phải backend của ứng dụng.')
sub('Kịch bản demo')
p('Đăng nhập Admin; tạo sản phẩm với ảnh; kiểm tra giá và số lượng; tìm theo tên; sắp xếp số; sửa dữ liệu; xác nhận xóa bản ghi thử nghiệm; xem Firestore bốn field; xuất JSON. Khi nghiệm thu mobile, chọn ảnh thư viện JPG/PNG và xác nhận cùng dữ liệu trên Web.')
sub('Tài liệu liên quan')
p('README.md mô tả chạy và schema; docs/schema.md ghi chi tiết migration; docs/testing.md ghi kết quả và giới hạn nghiệm thu; docs/setup.md hướng dẫn Web/Android/iOS. Các ảnh khởi động và log trước đổi schema được giữ làm lịch sử, không dùng làm minh chứng Dashboard sản phẩm mới.')

# Remove paragraph rules inherited from the bundled Word template.
for parent in [doc._element, doc.styles.element]:
 for border in list(parent.xpath('.//w:pBdr')):
  border.getparent().remove(border)
doc.styles['Caption'].font.color.rgb=RGBColor(0,0,0)
OUT.parent.mkdir(parents=True,exist_ok=True)
doc.save(OUT)
print(OUT)
