import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  /// 初始化
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== 基础操作 ====================

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return prefs.getString(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  // ==================== JSON 操作 ====================

  /// 保存 JSON 对象
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await setString(key, jsonEncode(value));
  }

  /// 获取 JSON 对象
  Map<String, dynamic>? getJson(String key) {
    final str = getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 保存 JSON 列表
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    return await setString(key, jsonEncode(value));
  }

  /// 获取 JSON 列表
  List<Map<String, dynamic>>? getJsonList(String key) {
    final str = getString(key);
    if (str == null) return null;
    try {
      final list = jsonDecode(str) as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return null;
    }
  }

  // ==================== 缓存管理 ====================

  /// 检查键是否存在
  bool hasKey(String key) {
    return prefs.containsKey(key);
  }

  /// 删除指定键
  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    return await prefs.clear();
  }

  /// 获取所有键
  Set<String> getKeys() {
    return prefs.getKeys();
  }

  // ==================== 过期缓存 ====================

  /// 保存带过期时间的缓存
  Future<bool> setCacheWithExpiry(String key, dynamic value, Duration expiry) async {
    final cacheData = {
      'value': value,
      'expiry': DateTime.now().add(expiry).millisecondsSinceEpoch,
    };
    return await setJson(key, cacheData);
  }

  /// 获取带过期时间的缓存（如果过期返回 null）
  dynamic getCacheWithExpiry(String key) {
    final cacheData = getJson(key);
    if (cacheData == null) return null;

    final expiry = cacheData['expiry'] as int?;
    if (expiry == null) return null;

    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      // 已过期，删除缓存
      remove(key);
      return null;
    }

    return cacheData['value'];
  }

  // ==================== 用户相关 ====================

  /// 保存用户 Token
  Future<bool> setToken(String token) async {
    return await setString('user_token', token);
  }

  /// 获取用户 Token
  String? getToken() {
    return getString('user_token');
  }

  /// 保存用户信息
  Future<bool> setUserInfo(Map<String, dynamic> userInfo) async {
    return await setJson('user_info', userInfo);
  }

  /// 获取用户信息
  Map<String, dynamic>? getUserInfo() {
    return getJson('user_info');
  }

  /// 清除用户数据
  Future<void> clearUserData() async {
    await remove('user_token');
    await remove('user_info');
  }

  /// 检查是否已登录
  bool isLoggedIn() {
    return getToken() != null;
  }

  // ==================== 设置相关 ====================

  /// 保存服务器地址
  Future<bool> setServerUrl(String url) async {
    return await setString('server_url', url);
  }

  /// 获取服务器地址
  String? getServerUrl() {
    return getString('server_url');
  }

  /// 保存主题模式
  Future<bool> setDarkMode(bool isDark) async {
    return await setBool('dark_mode', isDark);
  }

  /// 获取主题模式
  bool isDarkMode() {
    return getBool('dark_mode') ?? false;
  }

  /// 保存语言设置
  Future<bool> setLanguage(String lang) async {
    return await setString('language', lang);
  }

  /// 获取语言设置
  String getLanguage() {
    return getString('language') ?? 'zh_CN';
  }

  /// 保存通知设置
  Future<bool> setNotificationEnabled(bool enabled) async {
    return await setBool('notification_enabled', enabled);
  }

  /// 获取通知设置
  bool isNotificationEnabled() {
    return getBool('notification_enabled') ?? true;
  }
}
