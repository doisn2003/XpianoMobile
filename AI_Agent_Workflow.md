# Workflow Triển Khai Xpiano Mobile (AI Agent Coding Guide)
**Phiên bản:** 1.0.0
**Mục tiêu:** Hướng dẫn đội ngũ AI Agent code ứng dụng Flutter Xpiano Mobile theo đúng kiến trúc Hybrid (Supabase + ExpressJS) và Clean Architecture.

---

## 1. Nguyên Tắc Cốt Lõi (AI Agent Bắt Buộc Ghi Nhớ)

* **Kiến trúc Clean Architecture:** Mọi tính năng phải chia thành 4 lớp: `Presentation (UI/BLoC)` -> `Domain (Entities/Repositories)` -> `Data (Models/RepositoriesImpl)` -> `Data Sources (Remote/Local)`.
* **Quản lý Trạng thái:** Bắt buộc sử dụng `flutter_bloc` (BLoC hoặc Cubit) kết hợp `equatable`. Bắt mọi lỗi HTTP/Network ném về giao diện thành `Failure`.
* **Đạo luật Hybrid Network (Quyết định tại Tầng DataSource):**
    * **Tác vụ Read-Heavy (Public):** Lướt Feed, Xem danh sách Piano, Danh mục Khóa học -> Gọi trực tiếp database thông qua `SupabaseClient` (SDK). Tuyệt đối KHÔNG dùng API Express.
    * **Tác vụ Write/Logic-Heavy (Private/Action):** Auth, Thêm/Sửa/Xóa, Mua bán, Thanh toán, Tương tác (Like/Comment) -> Bắt buộc dùng `DioClient` gọi Express API.

---

## 2. Kế Hoạch Triển Khai Từng Giai Đoạn (Phases & Tasks)

### Phase 0: Hoàn Thiện Tầng Mạng (Network Layer Setup)
* **Task 0.1:** Bổ sung package `supabase_flutter` vào `pubspec.yaml`.
* **Task 0.2:** Tạo file `lib/core/network/supabase_client.dart` khởi tạo Supabase bằng URL và Anon Key.
* **Task 0.3:** Cấu hình Dependency Injection (`get_it`) để tiêm cả `DioClient` và `SupabaseClient` vào các RemoteDataSource.

### Phase 1: Authentication & User Profile (Xác Thực)
*Khuyến cáo: Sử dụng hoàn toàn `DioClient` cho Phase này.*
* **Task 1.1 - UI/BLoC:** Tạo `LoginScreen`, `OTPVerificationScreen` và `AuthBloc`.
* **Task 1.2 - DataSource:** Viết các hàm gọi `POST /api/auth/login`, `POST /api/auth/send-otp`, `POST /api/auth/login-otp`.
* **Task 1.3 - Local Storage:** Lưu Access Token vào `shared_preferences` sau khi đăng nhập thành công để `AuthInterceptor` tự động gắn vào Header cho các request sau.

### Phase 2: Mạng Xã Hội (Social Feed & Upload Media)
* **Task 2.1 - Social Feed (Read):** Dùng `SupabaseClient` truy vấn bảng `posts` (hoặc view tương ứng) để tải danh sách bài viết, video.
* **Task 2.2 - Tương Tác (Write):** Dùng `DioClient` gọi API `POST /api/posts/:id/like` và `POST /api/posts/:id/comments` khi người dùng thả tim, bình luận.
* **Task 2.3 - Đăng Bài & Upload Video (3 Bước Cực Yếu):**
    * *Bước 1:* Dùng `DioClient` gọi `POST /api/upload/sign` lấy PreSigned URL.
    * *Bước 2:* Dùng HTTP PUT upload file video/ảnh vật lý thẳng lên Cloud Storage qua link vừa nhận (Không qua Express). Hiển thị Progress Bar.
    * *Bước 3:* Dùng `DioClient` gọi `POST /api/posts` gửi JSON chứa Text và URL file vừa upload để hoàn tất đăng bài.

### Phase 3: E-Commerce (Pianos & Courses)
* **Task 3.1 - Danh mục Public (Read):** Dùng `SupabaseClient` lấy dữ liệu hiển thị màn hình `PianoStoreScreen` và `CourseListScreen` để đảm bảo độ trễ thấp.
* **Task 3.2 - Xử lý Mua bán (Write):** Viết `OrderRemoteDataSource` dùng `DioClient` gọi `POST /api/orders` để tạo đơn mua khóa học, mượn/thuê đàn.
* **Task 3.3 - Khu Vực Cá Nhân (Private):** Dùng `DioClient` gọi `GET /api/courses/me/enrolled` để lấy danh sách khóa học người dùng đã mua.

### Phase 4: Phân Hệ Teacher (Giáo Viên)
* **Task 4.1 - Cập nhật Hồ sơ:** Dùng `DioClient` gọi `POST /api/teacher/profile` để upload chứng chỉ (kết hợp luồng PreSigned URL ở Task 2.3 nếu có file đính kèm).
* **Task 4.2 - CMS Mobile:** Xây dựng màn hình cho giáo viên tạo khóa học (`POST /api/teacher/courses`) và quản lý thống kê (`GET /api/teacher/stats`) bằng `DioClient`.

---

## 3. Mẫu Lệnh (Prompt Template) Chuẩn Giao Việc Cho AI
Khi bắt đầu một tính năng mới, hãy copy/paste đoạn prompt sau cho AI:

> "Đóng vai Flutter Senior Developer. Hãy thực hiện **Task [Mã Task]** trong file workflow. Áp dụng Clean Architecture và flutter_bloc.
> Yêu cầu:
> 1. Bắt đầu từ tầng Data (Model, RemoteDataSource).
> 2. Phân tích kỹ xem hàm này cần dùng `SupabaseClient` (đọc public tĩnh) hay `DioClient` (ghi/cập nhật/private) dựa theo Đạo luật Hybrid.
> 3. Cài đặt Repository bắt lỗi `Exception` và trả về `Either<Failure, Type>`.
> 4. Hoàn thành toàn bộ logic Data và Domain trước khi viết BLoC và UI. Chỉ in ra code, không giải thích dài dòng."