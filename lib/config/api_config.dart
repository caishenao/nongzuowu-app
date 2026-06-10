/// API 配置
class ApiConfig {
  // 后端服务地址
  // 开发环境使用 localhost，生产环境使用实际服务器地址
  static const String baseUrl = 'http://localhost:8080/api';
  
  // 超时时间
  static const int connectTimeout = 15000; // 15秒
  static const int receiveTimeout = 15000; // 15秒
  
  // API 路径
  static const String fields = '/nong/fields';
  static const String crops = '/nong/crops';
  static const String operations = '/nong/operations';
  static const String weather = '/nong/weather';
  static const String reminders = '/nong/reminders';
  static const String ai = '/nong/ai';
  static const String dashboard = '/nong/dashboard';
}
