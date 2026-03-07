# Chiến lược Phát triển Xpiano Mobile (AI Agent Workflow & Coding Guide)

**Dự án:** Xpiano Mobile
**Kiến trúc:** Supabase (BaaS) + Express.js (Custom Backend)
**Client:** Flutter (BLoC, Dio, Supabase SDK)

---

## 1. Tổng quan & Đối tượng sử dụng

Xpiano Mobile áp dụng mô hình "Hybrid" kết hợp giữa BaaS (Supabase) và Custom Backend (ExpressJS) để tạo ra một chiến lược phân chia tải trọng thông minh.

Ứng dụng này được thiết kế giới hạn cho 2 role (quyền) duy nhất:
* **User (Học viên/Khách hàng):** Người dùng tiêu chuẩn thực hiện các chức năng lướt mạng xã hội, tương tác, mua sắm và xem khóa học.
* **Teacher (Giáo viên):** Kế thừa toàn bộ tính năng của User, có thêm quyền truy cập CMS di động để quản lý khóa học, thống kê thu nhập và nộp hồ sơ chứng chỉ.
*(Lưu ý: Các tác vụ của Admin và việc học online tương tác cao sẽ thực hiện hoàn toàn trên Web, không đưa vào App Mobile này).*

## 2. Triết lý Kiến trúc Hybrid (Đạo luật Phân luồng)

Kiến trúc cốt lõi dựa trên việc phân tách rõ ràng giữa "Read-Heavy" (Hành vi đọc nhiều) và "Write/Logic-Heavy" (Hành vi ghi và logic phức tạp).
* **Supabase (Trực tiếp):** Đảm nhận mảng "Read-Heavy" lấy nội dung không yêu cầu đăng nhập.
* **Express Backend (Qua REST API):** Đảm nhận mảng "Write/Logic-Heavy" xử lý luồng nghiệp vụ.
* **Độ trễ siêu thấp:** Thay vì đi qua Node.js bị vướng Event Loop, client "đâm thẳng" vào Database thông qua PostgREST của Supabase giúp trải nghiệm vuốt video cực kỳ mượt mà.
* **Tiết kiệm tài nguyên:** Việc offload các tác vụ đọc sang Supabase giúp server Node.js vận hành ổn định cho hàng vạn user đồng thời. Server Express chỉ tập trung tính toán logic, socket chat, gửi email và xử lý thanh toán.

---

## 3. Quy chuẩn Luồng dữ liệu (Data Flow Standard)

Mọi AI Agent khi code tầng DataSource bắt buộc tuân thủ quy tắc phân luồng sau:

### Nhóm 1: Fetch trực tiếp từ Supabase (Sử dụng `supabase_flutter` SDK)
Bao gồm các thao tác GET dữ liệu Public tĩnh hoặc ít thay đổi.
* **News Feed:** Tải danh sách video chơi đàn của cộng đồng.
* **Danh mục Dữ liệu:** Lấy danh sách Piano Store, Khóa học.
* **Hồ sơ Public:** Xem trang cá nhân công khai của người dùng khác hoặc thông tin Giáo viên.
* **Bảo mật:** Supabase SDK sẽ hoạt động dưới danh nghĩa Guest (Anon Key).

### Nhóm 2: Fetch thông qua Express API (Sử dụng `dio` & REST API)
Bao gồm tất cả sự thay đổi trạng thái và dữ liệu cần bảo mật.
* **Xác thực:** Đăng nhập, Gửi OTP, Cấp Token, Giữ phiên.
* **Tương tác Xã hội:** Like, Share, Comment, Follow.
* **Thanh toán & Giao dịch:** Nạp tiền Ví, Mua khóa học, Thuê/Mua Đàn.
* **Trạng thái cá nhân:** Lấy danh sách khóa học đã mua, đơn hàng của tôi, cấu hình thông báo.

---

## 4. Giải pháp Tối ưu Upload Media (PreSigned URL)

Để tránh làm nghẽn băng thông của server Express khi đăng tải các file video/ảnh dung lượng lớn, luồng upload bắt buộc thực hiện qua 3 bước "Không chạm Backend":
* **Bước 1: Xin giấy phép:** Mobile App sử dụng `DioClient` gọi API `POST /api/upload/sign` để yêu cầu một đường link PreSigned URL từ server.
* **Bước 2: Bắn thẳng lên mây:** Mobile App dùng HTTP PUT để upload file vật lý trực tiếp lên Cloud Storage thông qua link URL vừa nhận, bỏ qua backend Express và hiển thị tiến trình (progress bar).
* **Bước 3: Lưu bài viết:** Dùng `DioClient` gọi API `POST /api/posts` tạo bài viết mới, gửi kèm text nội dung và URL của media vừa upload để backend lưu vào Database.

---

## 5. Cấu trúc Triển khai (Clean Architecture) & State Management

* **Quản lý trạng thái bằng BLoC:** Bắt buộc sử dụng `flutter_bloc` kết hợp `equatable` theo kiến trúc dòng chảy dữ liệu một chiều.
* **Tuyệt đối không làm phình to `main.dart` & `main_screen.dart`:** * Chỉ sử dụng `MultiBlocProvider` ở gốc cây widget (`main.dart`) cho các Global BLoC mang tính chất toàn cục (ví dụ: Thông tin User đăng nhập, Config App).
    * Khai báo bộ máy tiêm `GetIt` tiêm các dependency vào toàn bộ vòng đời ứng dụng.
    * **Với các Feature BLoC (như `PianoBloc`, `PostBloc`, `CourseBloc`):** Phải được khởi tạo và cung cấp (provide) ở cấp độ Route hoặc ở ngay Screen tương ứng để giải phóng RAM khi rời khỏi màn hình.
* **Tầng Network:** Hệ thống duy trì 2 trạm phát/nhận song song là `dio_client.dart` và `supabase_client.dart`.
* **Bảo mật RLS trên Supabase:** Backend đã khóa chặn 100% quyền `INSERT`, `UPDATE`, `DELETE` từ Client tới thẳng Supabase. Chỉ cho phép hành động `SELECT` vô danh (Anonymous) vào các bảng public.
* **Xử lý Dữ liệu Model:** Supabase PostgREST thường trả về `snake_case`, trong khi Express API trả về `camelCase`. Các `Model` trong Flutter phải xử lý JSON map (`fromJson`) thống nhất để tránh lỗi mismatch dữ liệu.