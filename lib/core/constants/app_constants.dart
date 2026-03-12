class AppConstants {
  // Khi dùng ADB reverse port forwarding, dùng localhost (không cần IP)
  // Chạy lệnh: adb reverse tcp:5000 tcp:5000
  static const String apiBaseUrl = 'http://localhost:5000/api';
  
  // Shared Preferences keys
  static const String tokenKey = 'CACHED_ACCESS_TOKEN';
  static const String userKey = 'CACHED_USER_INFO'; 
}
