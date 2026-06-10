/// ============================================================================
/// 文件名: use_case.dart
/// 描述: 用例模式基础类 - 封装业务逻辑
/// 
/// 设计模式: UseCase Pattern (用例模式)
/// 
/// 用例模式是 Clean Architecture 的核心概念，它：
/// 1. 封装单个业务逻辑
/// 2. 每个用例只做一件事（单一职责原则）
/// 3. 可以被多个 Provider 复用
/// 4. 便于单元测试
/// 5. 解耦 UI 层和数据层
/// 
/// 层次结构:
/// UI (Screen) -> Provider (State) -> UseCase (Business Logic) -> Repository (Data)
/// 
/// 使用示例:
/// ```dart
/// class GetFieldsUseCase extends UseCase<List<FieldInfo>, GetFieldsParams> {
///   final FieldRepository repository;
///   
///   GetFieldsUseCase(this.repository);
///   
///   @override
///   Future<Result<List<FieldInfo>>> call(GetFieldsParams params) {
///     return repository.getAll(params: params.toMap());
///   }
/// }
/// ```
/// ============================================================================

import 'result.dart';

/// 用例基础抽象类
/// 
/// 泛型参数:
/// - [T]: 返回数据类型
/// - [P]: 参数类型（使用 Params 类封装）
/// 
/// 所有用例都必须继承此类并实现 [call] 方法
abstract class UseCase<T, P> {
  /// 执行用例
  /// 
  /// [params] 用例参数
  /// 返回包含结果的 [Result] 对象
  Future<Result<T>> call(P params);
}

/// 无参数用例
/// 
/// 当用例不需要参数时使用
abstract class NoParamsUseCase<T> {
  /// 执行用例（无参数）
  Future<Result<T>> call();
}

/// 用例参数基类
/// 
/// 所有用例参数都应继承此类
/// 使用不可变对象，确保线程安全
abstract class UseCaseParams {
  /// 转换为 Map（便于日志记录或序列化）
  Map<String, dynamic> toMap() => {};
}

/// 空参数
/// 
/// 当用例不需要参数时使用
class NoParams extends UseCaseParams {
  const NoParams();
}

/// ID 参数
/// 
/// 常见的按 ID 查询场景
class IdParams extends UseCaseParams {
  final int id;
  
  const IdParams(this.id);
  
  @override
  Map<String, dynamic> toMap() => {'id': id};
}

/// 分页参数
/// 
/// 用于分页查询场景
class PaginationUseCaseParams extends UseCaseParams {
  final int page;
  final int pageSize;
  final Map<String, dynamic>? filters;

  const PaginationUseCaseParams({
    this.page = 1,
    this.pageSize = 20,
    this.filters,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'pageNo': page,
      'pageSize': pageSize,
      if (filters != null) ...filters!,
    };
  }
}
