/// ============================================================================
/// 文件名: crop_repository.dart
/// 描述: 作物仓储接口 - 定义作物数据访问规范
/// 
/// 设计模式: Repository Pattern (仓储模式)
/// ============================================================================

import '../../core/result.dart';
import '../../core/repository/base_repository.dart';
import '../../models/api_models.dart';

/// 作物仓储接口
/// 
/// 定义作物数据访问的所有方法
/// 遵循依赖倒置原则(DIP) - 高层模块不应依赖低层模块
abstract class CropRepository extends BaseRepository<CropInfo> {
  /// 按地块筛选作物
  Future<Result<List<CropInfo>>> getByFieldId(int fieldId);
  
  /// 按状态筛选作物
  Future<Result<List<CropInfo>>> filterByStatus(int status);
  
  /// 获取作物详情（包含生长信息）
  Future<Result<CropDetail>> getDetailById(int id);
  
  /// 更新作物状态
  Future<Result<bool>> updateStatus(int id, int status);
}

/// 作物详情
/// 
/// 扩展作物信息，包含更多详细数据
class CropDetail extends CropInfo {
  final List<OperationSummary> recentOperations;
  final GrowthTrend growthTrend;
  
  const CropDetail({
    required super.id,
    required super.cropName,
    super.variety,
    super.fieldId,
    super.fieldName,
    super.sowDate,
    super.harvestDate,
    super.growthStage,
    super.growthDays,
    super.plantingArea,
    super.ndviValue,
    super.status,
    this.recentOperations = const [],
    this.growthTrend = const GrowthTrend(),
  });
}

/// 操作摘要
class OperationSummary {
  final String type;
  final String title;
  final String date;
  
  const OperationSummary({
    required this.type,
    required this.title,
    required this.date,
  });
}

/// 生长趋势
class GrowthTrend {
  final List<double> ndviHistory;
  final String trend; // up, down, stable
  
  const GrowthTrend({
    this.ndviHistory = const [],
    this.trend = 'stable',
  });
}
