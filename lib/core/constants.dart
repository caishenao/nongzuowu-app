/// ============================================================================
/// 文件名: app_constants.dart
/// 描述: 应用常量 - 集中管理所有常量值
/// 
/// 设计原则: Single Source of Truth (单一数据源)
/// 
/// 将所有常量集中管理，便于维护和修改
/// ============================================================================

/// 应用常量
class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();

  // ==================== 应用信息 ====================
  
  /// 应用名称
  static const String appName = '农业管理系统';
  
  /// 应用版本
  static const String appVersion = '1.0.0';
  
  /// 应用包名
  static const String packageName = 'com.example.nongzuowu_app';

  // ==================== API 配置 ====================
  
  /// 默认服务器地址
  static const String defaultBaseUrl = 'http://localhost:8080/api';
  
  /// 连接超时时间（毫秒）
  static const int connectTimeout = 15000;
  
  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 15000;

  // ==================== 分页配置 ====================
  
  /// 默认每页大小
  static const int defaultPageSize = 20;
  
  /// 最大每页大小
  static const int maxPageSize = 100;

  // ==================== 缓存配置 ====================
  
  /// 缓存过期时间（小时）
  static const int cacheExpiryHours = 24;
  
  /// 最大缓存大小（MB）
  static const int maxCacheSizeMB = 100;

  // ==================== 地图配置 ====================
  
  /// 默认中心经度（北京）
  static const double defaultLongitude = 116.4074;
  
  /// 默认中心纬度（北京）
  static const double defaultLatitude = 39.9042;
  
  /// 默认缩放级别
  static const double defaultZoom = 15.0;

  // ==================== 颜色常量 ====================
  
  /// 主色调 - 深绿
  static const int primaryColorValue = 0xFF1B3A28;
  
  /// 背景色 - 米白
  static const int backgroundColorValue = 0xFFF5F3EE;

  // ==================== 错误消息 ====================
  
  /// 网络错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  
  /// 服务器错误消息
  static const String serverErrorMessage = '服务器错误，请稍后重试';
  
  /// 未知错误消息
  static const String unknownErrorMessage = '未知错误，请联系管理员';
}

/// API 路径常量
class ApiPaths {
  ApiPaths._();

  /// 地块管理
  static const String fields = '/nong/fields';
  
  /// 作物管理
  static const String crops = '/nong/crops';
  
  /// 田间操作
  static const String operations = '/nong/operations';
  
  /// 气象数据
  static const String weather = '/nong/weather';
  
  /// 农事提醒
  static const String reminders = '/nong/reminders';
  
  /// AI 识别
  static const String ai = '/nong/ai';
  
  /// 经营总览
  static const String dashboard = '/nong/dashboard';
}

/// 存储键常量
class StorageKeys {
  StorageKeys._();

  /// 用户 Token
  static const String token = 'user_token';
  
  /// 用户信息
  static const String userInfo = 'user_info';
  
  /// 服务器地址
  static const String serverUrl = 'server_url';
  
  /// 深色模式
  static const String darkMode = 'dark_mode';
  
  /// 语言设置
  static const String language = 'language';
  
  /// 通知开关
  static const String notificationEnabled = 'notification_enabled';
  
  /// 保存的用户名
  static const String savedUsername = 'saved_username';
  
  /// 记住我
  static const String rememberMe = 'remember_me';
}
