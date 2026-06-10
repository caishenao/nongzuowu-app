/// ============================================================================
/// 文件名: get_crops_use_case.dart
/// 描述: 获取作物列表用例
/// ============================================================================

import '../../core/result.dart';
import '../../core/use_case.dart';
import '../../models/api_models.dart';
import '../repositories/crop_repository.dart';

/// 获取作物列表用例
class GetCropsUseCase extends UseCase<List<CropInfo>, GetCropsParams> {
  final CropRepository _repository;

  GetCropsUseCase(this._repository);

  @override
  Future<Result<List<CropInfo>>> call(GetCropsParams params) async {
    // 参数验证
    if (params.page < 1) {
      return Result.error('页码必须大于0');
    }

    return _repository.getAll(params: params.toMap());
  }
}

/// 获取作物列表参数
class GetCropsParams extends UseCaseParams {
  final String? cropName;
  final int? fieldId;
  final int? status;
  final int page;
  final int pageSize;

  const GetCropsParams({
    this.cropName,
    this.fieldId,
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'pageNo': page,
      'pageSize': pageSize,
      if (cropName != null) 'cropName': cropName,
      if (fieldId != null) 'fieldId': fieldId,
      if (status != null) 'status': status,
    };
  }
}
