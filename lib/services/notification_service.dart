import 'dart:async';

/// 通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<NotificationMessage> _messageController = 
      StreamController<NotificationMessage>.broadcast();

  /// 消息流
  Stream<NotificationMessage> get messageStream => _messageController.stream;

  /// 初始化通知服务
  Future<void> init() async {
    // TODO: 初始化 Firebase Messaging 或其他推送服务
    print('NotificationService initialized');
  }

  /// 发送本地通知
  void showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    // TODO: 显示本地通知
    print('Local notification: $title - $body');
    
    _messageController.add(NotificationMessage(
      title: title,
      body: body,
      payload: payload,
      timestamp: DateTime.now(),
    ));
  }

  /// 处理收到的消息
  void handleMessage(Map<String, dynamic> message) {
    final notification = message['notification'] as Map<String, dynamic>?;
    final data = message['data'] as Map<String, dynamic>?;
    
    if (notification != null) {
      showLocalNotification(
        title: notification['title'] ?? '',
        body: notification['body'] ?? '',
        payload: data != null ? data.toString() : null,
      );
    }
  }

  /// 订阅主题
  Future<void> subscribeToTopic(String topic) async {
    // TODO: 订阅 FCM 主题
    print('Subscribed to topic: $topic');
  }

  /// 取消订阅主题
  Future<void> unsubscribeFromTopic(String topic) async {
    // TODO: 取消订阅 FCM 主题
    print('Unsubscribed from topic: $topic');
  }

  /// 获取 FCM Token
  Future<String?> getToken() async {
    // TODO: 获取 FCM Token
    return null;
  }

  /// 清除所有通知
  void clearAll() {
    // TODO: 清除所有通知
    print('All notifications cleared');
  }

  /// 释放资源
  void dispose() {
    _messageController.close();
  }
}

/// 通知消息
class NotificationMessage {
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;
  final bool isRead;

  NotificationMessage({
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
    this.isRead = false,
  });

  NotificationMessage copyWith({
    String? title,
    String? body,
    String? payload,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationMessage(
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 通知管理器
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final List<NotificationMessage> _notifications = [];
  final StreamController<List<NotificationMessage>> _notificationsController = 
      StreamController<List<NotificationMessage>>.broadcast();

  /// 通知列表流
  Stream<List<NotificationMessage>> get notificationsStream => _notificationsController.stream;

  /// 获取所有通知
  List<NotificationMessage> get notifications => List.unmodifiable(_notifications);

  /// 获取未读通知数量
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// 添加通知
  void addNotification(NotificationMessage notification) {
    _notifications.insert(0, notification);
    _notificationsController.add(_notifications);
  }

  /// 标记为已读
  void markAsRead(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationsController.add(_notifications);
    }
  }

  /// 标记所有为已读
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notificationsController.add(_notifications);
  }

  /// 删除通知
  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      _notificationsController.add(_notifications);
    }
  }

  /// 清除所有通知
  void clearAll() {
    _notifications.clear();
    _notificationsController.add(_notifications);
  }

  /// 释放资源
  void dispose() {
    _notificationsController.close();
  }
}
