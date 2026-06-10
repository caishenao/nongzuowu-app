/// ============================================================================
/// 文件名: extensions.dart
/// 描述: Dart 扩展方法 - 增强现有类的功能
/// 
/// 设计模式: Extension Methods (扩展方法)
/// 
/// 扩展方法允许我们为现有类添加新功能，而无需继承或修改原始类。
/// 这是 Dart 2.7 引入的特性，非常实用。
/// 
/// 使用场景：
/// 1. 增强第三方库的类
/// 2. 添加常用的便捷方法
/// 3. 提高代码可读性
/// ============================================================================

/// String 扩展
extension StringExtensions on String {
  /// 是否为空或只包含空白字符
  bool get isBlank => trim().isEmpty;
  
  /// 是否不为空且不只包含空白字符
  bool get isNotBlank => !isBlank;
  
  /// 安全截断字符串
  /// [maxLength] 最大长度
  /// [suffix] 后缀（默认为 '...'）
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
  
  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  /// 是否为有效邮箱
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }
  
  /// 是否为有效手机号（中国大陆）
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    return phoneRegex.hasMatch(this);
  }
  
  /// 转换为 int（安全）
  int? toIntOrNull() => int.tryParse(this);
  
  /// 转换为 double（安全）
  double? toDoubleOrNull() => double.tryParse(this);
}

/// Nullable String 扩展
extension NullableStringExtensions on String? {
  /// 是否为 null 或空
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// 是否不为 null 且不为空
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  /// 获取值或默认值
  String orDefault(String defaultValue) => this ?? defaultValue;
}

/// num 扩展
extension NumExtensions on num {
  /// 保留指定小数位数
  double toPrecision(int precision) {
    return double.parse(toStringAsFixed(precision));
  }
  
  /// 格式化为带千分位的字符串
  String get formatted {
    final parts = toString().split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }
    
    return '$buffer$decPart';
  }
}

/// List 扩展
extension ListExtensions<T> on List<T> {
  /// 安全获取元素（越界返回 null）
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// 分块
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
  
  /// 去重（基于某个属性）
  List<T> distinctBy<R>(R Function(T) selector) {
    final seen = <R>{};
    return where((item) => seen.add(selector(item))).toList();
  }
}

/// DateTime 扩展
extension DateTimeExtensions on DateTime {
  /// 是否为今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// 是否为昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// 格式化为相对时间
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
  
  /// 格式化日期
  String formatDate([String pattern = 'yyyy-MM-dd']) {
    return pattern
        .replaceAll('yyyy', year.toString())
        .replaceAll('MM', month.toString().padLeft(2, '0'))
        .replaceAll('dd', day.toString().padLeft(2, '0'))
        .replaceAll('HH', hour.toString().padLeft(2, '0'))
        .replaceAll('mm', minute.toString().padLeft(2, '0'))
        .replaceAll('ss', second.toString().padLeft(2, '0'));
  }
}

/// Map 扩展
extension MapExtensions<K, V> on Map<K, V> {
  /// 安全获取值（带默认值）
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key]! : defaultValue;
  }
  
  /// 深合并
  Map<K, V> deepMerge(Map<K, V> other) {
    final result = Map<K, V>.from(this);
    for (final entry in other.entries) {
      result[entry.key] = entry.value;
    }
    return result;
  }
}
