/// ============================================================================
/// 文件名: base_repository.dart
/// 描述: 仓储模式基础接口 - 数据访问层的抽象
/// 
/// 设计模式: Repository Pattern (仓储模式)
/// 
/// 仓储模式是领域驱动设计(DDD)中的核心模式，它：
/// 1. 分离数据访问逻辑与业务逻辑
/// 2. 提供统一的数据访问接口
/// 3. 便于单元测试（可以轻松Mock）
/// 4. 支持多种数据源切换（本地/远程）
/// 
/// 使用示例:
/// ```dart
/// class FieldRepository extends BaseRepository<FieldInfo> {
///   @override
///   Future<List<FieldInfo>> getAll() async {
///     // 实现具体的数据获取逻辑
///   }
/// }
/// ```
/// ============================================================================

import '../models/result.dart';

/// 仓储模式基础接口
/// 
/// 泛型 T 表示实体类型
/// 定义了通用的 CRUD 操作接口
abstract class BaseRepository<T> {
  /// 获取所有实体
  /// 
  /// 返回包含实体列表的结果对象
  /// 可选参数 [params] 用于传递查询条件
  Future<Result<List<T>>> getAll({Map<String, dynamic>? params});
  
  /// 根据 ID 获取单个实体
  /// 
  /// [id] 实体的唯一标识符
  /// 返回包含单个实体的结果对象
  Future<Result<T>> getById(int id);
  
  /// 创建新实体
  /// 
  /// [entity] 要创建的实体对象
  /// 返回包含创建后实体的结果对象（可能包含服务器生成的ID等）
  Future<Result<T>> create(T entity);
  
  /// 更新现有实体
  /// 
  /// [id] 要更新的实体ID
  /// [entity] 更新后的实体对象
  /// 返回包含更新后实体的结果对象
  Future<Result<T>> update(int id, T entity);
  
  /// 删除实体
  /// 
  /// [id] 要删除的实体ID
  /// 返回操作是否成功
  Future<Result<bool>> delete(int id);
}

/// 分页查询参数
/// 
/// 用于封装分页请求的通用参数
class PaginationParams {
  /// 当前页码（从1开始）
  final int page;
  
  /// 每页大小
  final int pageSize;
  
  /// 排序字段
  final String? sortBy;
  
  /// 排序方向: asc 或 desc
  final String sortOrder;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy,
    this.sortOrder = 'desc',
  });

  /// 转换为 Map，便于传递给 API
  Map<String, dynamic> toMap() {
    return {
      'pageNo': page,
      'pageSize': pageSize,
      if (sortBy != null) 'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }
}

/// 分页结果
/// 
/// 封装分页查询的结果，包含数据列表和分页信息
class PaginatedResult<T> {
  /// 数据列表
  final List<T> items;
  
  /// 总记录数
  final int total;
  
  /// 当前页码
  final int page;
  
  /// 每页大小
  final int pageSize;
  
  /// 总页数
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  }) : totalPages = (total / pageSize).ceil();

  /// 是否有下一页
  bool get hasNext => page < totalPages;
  
  /// 是否有上一页
  bool get hasPrevious => page > 1;
  
  /// 是否为空
  bool get isEmpty => items.isEmpty;
}
