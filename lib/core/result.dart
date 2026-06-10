/// ============================================================================
/// 文件名: result.dart
/// 描述: 统一结果封装 - 处理成功/失败状态
/// 
/// 设计模式: Result Pattern (结果模式)
/// 
/// 结果模式用于统一处理操作的成功和失败状态，避免直接抛出异常。
/// 优点：
/// 1. 明确的返回类型，调用者必须处理成功和失败两种情况
/// 2. 避免未捕获的异常导致程序崩溃
/// 3. 便于链式调用和函数式编程
/// 4. 统一的错误处理机制
/// 
/// 使用示例:
/// ```dart
/// // 创建成功结果
/// final result = Result.success(data);
/// 
/// // 创建失败结果
/// final result = Result.error('操作失败');
/// 
/// // 模式匹配处理
/// result.when(
///   success: (data) => print('成功: $data'),
///   error: (message) => print('失败: $message'),
/// );
/// ```
/// ============================================================================

/// 统一结果封装类
/// 
/// 泛型 T 表示成功时的数据类型
class Result<T> {
  /// 状态码（0 表示成功，其他表示失败）
  final int code;
  
  /// 消息（成功或失败的描述）
  final String message;
  
  /// 数据（成功时的数据，失败时为 null）
  final T? data;
  
  /// 时间戳
  final int timestamp;

  /// 私有构造函数
  Result._({
    required this.code,
    required this.message,
    this.data,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch;

  /// 创建成功结果
  /// 
  /// [data] 成功时的数据
  /// [message] 成功消息，默认为 'success'
  factory Result.success(T data, {String message = 'success'}) {
    return Result._(
      code: 0,
      message: message,
      data: data,
    );
  }

  /// 创建失败结果
  /// 
  /// [message] 错误消息
  /// [code] 错误码，默认为 -1
  factory Result.error(String message, {int code = -1}) {
    return Result._(
      code: code,
      message: message,
    );
  }

  /// 是否成功
  bool get isSuccess => code == 0;
  
  /// 是否失败
  bool get isError => !isSuccess;

  /// 模式匹配方法
  /// 
  /// 类似 Rust 的 Result 类型，提供函数式的错误处理
  /// 
  /// [success] 成功时的回调
  /// [error] 失败时的回调
  /// 返回回调的返回值
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int code) error,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    } else {
      return error(message, code);
    }
  }

  /// 转换数据
  /// 
  /// 将成功时的数据转换为另一种类型
  /// [transform] 转换函数
  /// 返回新的 Result 对象
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      try {
        return Result.success(transform(data as T));
      } catch (e) {
        return Result.error('数据转换失败: $e');
      }
    }
    return Result.error(message, code: code);
  }

  /// 异步转换数据
  /// 
  /// [transform] 异步转换函数
  /// 返回包含转换结果的 Future
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    if (isSuccess && data != null) {
      try {
        final result = await transform(data as T);
        return Result.success(result);
      } catch (e) {
        return Result.error('数据转换失败: $e');
      }
    }
    return Result.error(message, code: code);
  }

  /// 获取数据或默认值
  /// 
  /// [defaultValue] 默认值
  /// 返回数据（如果成功）或默认值（如果失败）
  T getOrElse(T defaultValue) {
    return isSuccess && data != null ? data as T : defaultValue;
  }

  /// 获取数据或抛出异常
  /// 
  /// 返回数据（如果成功）
  /// 抛出异常（如果失败）
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data as T;
    }
    throw Exception(message);
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'Result.success($data)';
    } else {
      return 'Result.error($code: $message)';
    }
  }
}
