# Báo Cáo Thiết Lập Nền Tảng (Core Setup) - Xpiano Mobile

**Dự án:** Xpiano Mobile
**Kiến trúc Backend:** ExpressJS RESTful API + PostgreSQL (Supabase)
**Kiến trúc App:** BLoC (State Management) + Clean Architecture + Dio (Networking)
**Người thực hiện:** Antigravity AI (Codename: "Chú Lính Chì")

---

## 1. Các hạng mục đã thi công (Đổ bê tông móng)

### 📦 Cài đặt thư viện cốt lõi (`pubspec.yaml`)
- `flutter_bloc` & `equatable`: Quản lý trạng thái (State Management) theo kiến trúc dòng chảy dữ liệu một chiều, dễ dàng mở rộng và bảo trì.
- `dio`: HTTP Client mạnh mẽ nhất của Dart/Flutter để giao tiếp với hệ thống backend ExpressJS.
- `get_it`: Hệ thống Tiêm Phụ Thuộc (Dependency Injection / Service Locator) giúp quản lý các service dùng chung (như Network Client, SharedPreferences) tồn tại duy nhất (Singleton) trong toàn bộ vòng đời ứng dụng, tối ưu RAM và hiệu suất.
- `shared_preferences`: Lưu trữ Token cục bộ (Local Storage) để giữ phiên đăng nhập của khách hàng.
- `logger`: Thư viện in console chuẩn mực màu sắc, hỗ trợ debug lỗi nhanh chóng.

### 🌐 Hệ thống Giao Tiếp Mạng (Network Layer)
- **`DioClient` (`lib/core/network/dio_client.dart`)**: Trạm phát/nhận API trung tâm. Định cấu hình `BaseURL`, các phương thức `GET, POST, PUT, DELETE` và quan trọng nhất là cài đặt giới hạn thời gian phản hồi (15s Timeout) để app không bao giờ bị treo cứng nếu mạng chậm.
- **`AuthInterceptor` (`lib/core/network/interceptors/auth_interceptor.dart`)**: Vệ binh tự động. Tự động moi Access Token (nếu có) từ khóa `CACHED_ACCESS_TOKEN` và gắn vào `Header Authorization: Bearer` trước mỗi request. Giúp lập trình viên không cần viết đi viết lại dòng "gắn token" ở hàng trăm API khác.
- **`ErrorInterceptor` (`lib/core/network/interceptors/error_interceptor.dart`)**: Hệ thống phân loại lỗi tinh vi. Bắt toàn bộ lỗi HTTP (401, 403, 404, 500...) hoặc lỗi rớt mạng 3G/Wifi để ném về giao diện thành một câu lệnh tiếng Việt thân thiện thay vì làm Crash (sập) App. Đặc biệt, nó có khả năng "đánh hơi" lỗi Auth 401 để tự động sút văng khách hàng về trang Đăng nhập để bảo mật thông tin.

### 🩺 Hạ tầng Quản lý Trạng thái và Bắt lỗi Toàn cục
- **`AppBlocObserver` (`lib/core/bloc/app_bloc_observer.dart`)**: Camera an ninh giám sát 24/7 mọi sự sinh ra, thay đổi, cấu trúc hoặc bốc hơi của các kiện hàng (BLoC) trong RAM. Log lỗi đỏ chót nếu 1 BLoC ném Exception.
- **`Failures & Exceptions` (`lib/core/error/`)**: Định nghĩa các đối tượng lỗi kinh điển (`ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`) nhằm giúp mô hình Clean Architecture trả về trạng thái giao diện Rõ Ràng (Tách biệt UI và Logic).

### ⚙️ Điểm neo Trung tâm (`main.dart` & `injection_container.dart`)
- Lắp ráp `MultiBlocProvider` ở tận cùng trên gốc cây widget, giúp mọi nhánh lá (màn hình) đều xài chung được các Global BLoC (như: Thông tin User, Config App).
- Khai báo bộ máy tiêm `GetIt` tiêm DioClient, Logger vào não bộ của App ngay lúc nhấn logo khởi động.

---

## 2. Kết luận: Đã sẵn sàng cho Thực chiến (UI/UX và API chưa?)

**TRẢ LỜI: HỆ THỐNG ĐÃ HOÀN TOÀN SẴN SÀNG! 🚀**

Giờ đây, nếu chúng ta muốn làm giao diện màn hình Danh sách Piano, quy trình rớt từ trên xuống rành mạch:
1. **Thiết kế UI:** Code Widget cây gõ vào 1 BLoC tên là `PianoCubit` hoặc `PianoBloc` gọi hàm `FetchPianos()`.
2. **Logic Tầng BLoC:** Hiện Vòng tròn xoay (Loading). Yêu cầu Repo thực hiện lệnh.
3. **Repository:** Ra lệnh cho Tầng Datasource gọi hàm API.
4. **DioClient (Core):** Làm nhiệm vụ gọi HTTPS `GET /api/pianos`. Tự động gắn header `application/json`. 
5. Cứ thế trả Data về UI thông qua vòng đời BLoC.

Toàn bộ các luồng lắt léo về 401 (hết hạn Auth) hay Timeout rớt mạng đã được đẩy lùi xuống tầng hầm (Dio Core). **Lập trình viên khi làm màn hình mới chỉ việc vẽ UI (Flutter) và nhận Data JSON như bình thường!** 

---

## 3. Chiến lược hành động tiếp theo

1. **Giai đoạn 1 (Tuần tới):** 
   - Xây dựng Theme hoàn chỉnh (Màu mảng thương hiệu, Font chữ `Google_fonts`).
   - Chọn ra 1 Tính năng (Ví dụ: **Cửa Hàng Xpiano**) và thực hành áp dụng trọn vẹn luồng Clean Architecture: *Tạo Model -> Gọi Repo -> Gọi API -> Nhét Data vào List UI*.
   
2. **Giai đoạn 2:** 
   - Tích hợp cụm Tính năng Authentication (Xác thực OTP, Login/Register). Hoàn thiện luồng kiểm soát Token trọn vẹn.
   
3. **Giai đoạn 3:** Liên kết các Modules Mua bán, Thuê đàn, Mạng xã hội Livestream theo thứ tự API DOC của Backend Express.

---
*Báo cáo kết thúc ngày 23/02/2026. Xin chỉ thị mới vào ngày mai.*
