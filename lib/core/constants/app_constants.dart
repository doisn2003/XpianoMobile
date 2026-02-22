class AppConstants {
  // Thay đổi IP này thành IPv4 của máy bạn khi chạy trên thiết bị thật/máy ảo
  // VD máy tính của bạn là 192.168.1.10 thì đổi localhost thành ip đó
  static const String apiBaseUrl = 'http://192.168.1.10:3000/api';
  
  // Shared Preferences keys
  static const String tokenKey = 'CACHED_ACCESS_TOKEN';
  static const String userKey = 'CACHED_USER_INFO';
}
