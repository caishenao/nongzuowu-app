/// ============================================================================
/// 文件名: get_fields_use_case.dart
/// 描述: 获取地块列表用例 - 封装获取地块的业务逻辑
/// 
/// 设计模式: UseCase Pattern (用例模式)
/// 
/// 职责：
/// 1. 封装获取地块列表的业务逻辑
/// 2. 处理参数验证和转换
/// 3. 调用仓储层获取数据
/// 4. 返回统一的 Result 对象
/// ============================================================================

import '../../core/result.dart';
import '../../core/use_case.dart';
import '../../models/api_models.dart';
import '../repositories/field_repository.dart';

/// 获取地块列表用例
/// 
/// 遵循单一职责原则(SRP) - 只负责获取地块列表
/// 遵循开闭原则(OCP) - 对扩展开放，对修改关闭
class GetFieldsUseCase extends UseCase<List<FieldInfo>, GetFieldsParams> {
  final FieldRepository _repository;

  /// 构造函数注入仓储依赖
  /// 
  /// [_repository] 地块仓储实例
  GetFieldsUseCase(this._repository);

  @override
  Future<Result<List<FieldInfo>>> call(GetFieldsParams params) async {
    // 1. 参数验证
    if (params.page < 1) {
      return Result.error('页码必须大于0');
    }
    
    if (params.pageSize < 1 || params.pageSize > 100) {
      return Result.error('每页大小必须在1-100之间');
    }

    // 2. 调用仓储层
    return _repository.getAll(params: params.toMap());
  }
}

/// 获取地块列表参数
class GetFieldsParams extends UseCaseParams {
  /// 搜索关键词
  final String? keyword;
  
  /// 地块类型
  final String? fieldType;
  
  /// 状态筛选
  final int? status;
  
  /// 页码
  final int page;
  
  /// 每页大小
  final int pageSize;

  const GetFieldsParams({
    this.keyword,
    this.fieldType,
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'pageNo': page,
      'pageSize': pageSize,
      if (keyword != null) 'fieldName': keyword,
      if (fieldType != null) 'fieldType': fieldType,
      if (status != null) 'status': status,
    };
  }
}
