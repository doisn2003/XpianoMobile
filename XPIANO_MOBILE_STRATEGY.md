# Chiến lược Phát triển Xpiano Mobile (BaaS + Custom Backend Hybrid)

**Dự án:** Xpiano Mobile
**Kiến trúc:** Supabase (BaaS) + Express.js (Custom Backend)
**Client:** Flutter (BLoC, Dio, Supabase SDK)

---

## 1. Tổng quan & Triết lý Kiến trúc

Mô hình "Hybrid" kết hợp giữa BaaS (Supabase) và Custom Backend (ExpressJS) là một chiến lược phân chia tải trọng (Load Distribution Strategy) thông minh:
- **Ngắn gọn:** Phân tách rõ ràng giữa **"Read-Heavy"** (Hành vi đọc nhiều) và **"Write/Logic-Heavy"** (Hành vi ghi và logic phức tạp).
- **Supabase (Trực tiếp)**: Đảm nhận mảng "Read-Heavy" lấy nội dung không yêu cầu đăng nhập.
- **Express Backend (Qua REST API)**: Đảm nhận mảng "Write/Logic-Heavy" xử lý luồng nghiệp vụ.

## 2. Đánh giá Mức độ Tối ưu (Vì sao đây là lựa chọn xuất sắc?)

Đây là **LỰA CHỌN TỐI ƯU NHẤT** cho một ứng dụng mạng xã hội video và EdTech như Xpiano.

### Ưu điểm vượt trội:
1. **Low Latency (Độ trễ siêu thấp) cho Feed & Video:** Lướt feed video (giống TikTok/Reels) yêu cầu API phản hồi trong mili-giây. Thay vì đi qua Node.js (Express) bị vướng Event Loop và Overhead của Middleware, client "đâm thẳng" vào Database thông qua PostgREST của Supabase tích hợp sẵn (tốc độ xử lý bằng C/Rust). Trải nghiệm vuốt video sẽ cực kỳ mượt mà.
2. **Tiết kiệm tài nguyên Server Express (Cost & Scaling):** Nghiệp vụ đọc (Read) thường chiếm 80-90% băng thông của app mạng xã hội. Bằng cách offload 80% này cho Supabase, server Node.js của bạn có thể vận hành ổn định cho hàng vạn user đồng thời mà không cần tốn tiền scale VPS lên cấu hình quá khủng. Server Express chỉ tập trung làm việc nhẹ: tính toán logic, socket chat, gửi email, xử lý thanh toán.
3. **Giữ lại sức mạnh Custom của Express:** Nếu dùng Supabase 100%, bạn sẽ gặp khó khăn khi làm các tính năng đặc thù như: Streaming phòng học đa camera, Webhook SePay (thanh toán VN), quản lý ví tiền. Việc giữ lại Custom Backend bù đắp hoàn toàn điểm yếu của BaaS.

## 3. Quy chuẩn luồng dữ liệu (Data Flow Standard)

Mọi bộ phận trong đội ngũ (kể cả AI Agents) bắt buộc tuân thủ quy tắc phân luồng mạng lưới sau đây:

### Nhóm 1: Fetch trực tiếp từ Supabase (Sử dụng `supabase_flutter` SDK)
Bao gồm các thao tác GET dữ liệu Public tĩnh hoặc ít thay đổi theo ngữ cảnh cá nhân user.
- **News Feed:** Tải danh sách video chơi đàn của cộng đồng.
- **Danh mục Dữ liệu:** Lấy danh sách Piano Store, Khóa học (Courses List).
- **Hồ sơ Public:** Xem trang cá nhân công khai của người dùng khác hoặc thông tin Giáo viên.

### Nhóm 2: Fetch thông qua Express API (Sử dụng `dio` & REST API)
Bao gồm tất cả sự thay đổi trạng thái (Ghi, Thêm, Sửa, Xóa), dữ liệu cần bảo mật và các tương tác thời gian thực.
- **Xác thực (Authentication):** Đăng nhập, Gửi OTP, Cấp Token, Giữ phiên.
- **Tương tác Xã hội:** Like, Share, Comment, Follow (Vì cần validate điều kiện, trigger notification trên server).
- **Thanh toán & Giao dịch:** Nạp tiền Ví, Mua khóa học, Thuê/Mua Đàn (Gắn liền với SePay Webhook và logic cấp quyền).
- **Trạng thái cá nhân (Private Me):** Lấy danh sách khóa học *đã mua*, đơn hàng *của tôi*, cấu hình *thông báo*.

## 4. Cấu trúc Triển khai trong Flutter (Clean Architecture)

Hệ thống Network Layer của Flutter sẽ duy trì 2 trạm phát/nhận song song thay vì 1.

```dart
// Trong thư mục lib/core/network/
- dio_client.dart          // (Đã có) Xử lý REST API gọi tới Express, gắn AuthInterceptor.
- supabase_client.dart     // (Tạo mới) Khởi tạo Supabase SDK để query trực tiếp Postgres.
```

Ở tầng **Datasource (`remote_data_source.dart`)** của mỗi tính năng, người viết code phải ra quyết định gọi Client nào:
```dart
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final DioClient dioClient;
  final SupabaseClient supabaseClient;

  // Lấy danh sách khóa (Public) -> Dùng Supabase
  Future<List<CourseModel>> getCourses() async {
    final response = await supabaseClient.from('courses').select().eq('status', 'published');
    return response.map((json) => CourseModel.fromJson(json)).toList();
  }

  // Mua khóa học (Private/Action) -> Dùng Dio gọi Express
  Future<void> enrollCourse(String courseId) async {
    await dioClient.post('/api/orders', data: {'courseId': courseId});
  }
}
```

## 5. Rủi ro Cần Quản lý (Lưu ý cho đội ngũ DevOps/Backend)

1. **Bảo mật RLS trên Supabase:** 
   Vì ứng dụng đâm thẳng vào Supabase cho các API Public, Backend Engineer PHẢI cấu hình Row Level Security (RLS) trên Admin Supabase Dashboard chuẩn xác. Chỉ cho phép hành động `SELECT` vô danh (Anonymous) vào các bảng như `pianos`, `courses`, `posts` và **Khóa chặn 100%** quyền `INSERT`, `UPDATE`, `DELETE` từ Client tới thẳng Supabase. Mọi tác vụ tạo/sửa/xóa phải đi qua Express API. (Đã cấu hình)
2. **Khác biệt Model:**
   Cách Supabase PostgREST parse tên cột (thường là `snake_case` ở db) có thể khác với cách Express API trả về (thường map qua `camelCase`), App cần xử lý JSON map thống nhất ở phần Model (`fromJson`).
3. **Phân quyền khi truy xuất Supabase:**
   Vì Supabase SDK lúc này không giữ phiên Auth (Auth nằm bên Express quản lý cục bộ Access Token), nên Supabase SDK của Flutter sẽ hoạt động dưới danh nghĩa Guest (Anon Key). Việc này là hoàn hảo cho Public Read.  

---
**Kết luận:** Hạ tầng kiến trúc này xứng đáng đạt điểm 9.5/10 cho tính linh hoạt và khả năng scale. Hướng triển khai này chính thức được thông qua để viết code trong các phase tiếp theo.
