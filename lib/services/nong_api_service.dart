import '../models/api_models.dart';
import 'api_service.dart';

/// 农业管理 API 服务
class NongApiService {
  final ApiService _api = ApiService();

  // ==================== 地块管理 ====================

  /// 获取地块列表
  Future<PageResult<FieldInfo>> getFields({
    String? fieldName,
    String? fieldType,
    int? status,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
    if (fieldName != null) queryParams['fieldName'] = fieldName;
    if (fieldType != null) queryParams['fieldType'] = fieldType;
    if (status != null) queryParams['status'] = status;

    final response = await _api.get('/nong/fields', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return PageResult.fromJson(data['data'], FieldInfo.fromJson);
    }
    throw Exception(data['message'] ?? '获取地块列表失败');
  }

  /// 获取地块详情
  Future<FieldInfo> getField(int id) async {
    final response = await _api.get('/nong/fields/$id');
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return FieldInfo.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '获取地块详情失败');
  }

  /// 创建地块
  Future<FieldInfo> createField(Map<String, dynamic> request) async {
    final response = await _api.post('/nong/fields', data: request);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return FieldInfo.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '创建地块失败');
  }

  /// 更新地块
  Future<FieldInfo> updateField(int id, Map<String, dynamic> request) async {
    final response = await _api.put('/nong/fields/$id', data: request);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return FieldInfo.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '更新地块失败');
  }

  /// 删除地块
  Future<bool> deleteField(int id) async {
    final response = await _api.delete('/nong/fields/$id');
    final data = response.data as Map<String, dynamic>;
    return data['code'] == 0;
  }

  // ==================== 作物管理 ====================

  /// 获取作物列表
  Future<PageResult<CropInfo>> getCrops({
    String? cropName,
    int? fieldId,
    int? status,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
    if (cropName != null) queryParams['cropName'] = cropName;
    if (fieldId != null) queryParams['fieldId'] = fieldId;
    if (status != null) queryParams['status'] = status;

    final response = await _api.get('/nong/crops', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return PageResult.fromJson(data['data'], CropInfo.fromJson);
    }
    throw Exception(data['message'] ?? '获取作物列表失败');
  }

  /// 获取作物详情
  Future<CropInfo> getCrop(int id) async {
    final response = await _api.get('/nong/crops/$id');
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return CropInfo.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '获取作物详情失败');
  }

  /// 创建作物
  Future<CropInfo> createCrop(Map<String, dynamic> request) async {
    final response = await _api.post('/nong/crops', data: request);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return CropInfo.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '创建作物失败');
  }

  // ==================== 田间操作记录 ====================

  /// 获取操作记录列表
  Future<PageResult<FieldOperation>> getOperations({
    int? fieldId,
    int? cropId,
    String? operationType,
    String? startDate,
    String? endDate,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
    if (fieldId != null) queryParams['fieldId'] = fieldId;
    if (cropId != null) queryParams['cropId'] = cropId;
    if (operationType != null) queryParams['operationType'] = operationType;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _api.get('/nong/operations', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return PageResult.fromJson(data['data'], FieldOperation.fromJson);
    }
    throw Exception(data['message'] ?? '获取操作记录失败');
  }

  /// 创建操作记录
  Future<FieldOperation> createOperation(Map<String, dynamic> request) async {
    final response = await _api.post('/nong/operations', data: request);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return FieldOperation.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '创建操作记录失败');
  }

  // ==================== 气象数据 ====================

  /// 获取气象数据列表
  Future<List<WeatherData>> getWeatherData({
    int? fieldId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fieldId != null) queryParams['fieldId'] = fieldId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _api.get('/nong/weather', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      final list = data['data'] as List<dynamic>;
      return list.map((e) => WeatherData.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(data['message'] ?? '获取气象数据失败');
  }

  /// 获取最新气象数据
  Future<WeatherData?> getLatestWeather({int? fieldId}) async {
    final queryParams = <String, dynamic>{};
    if (fieldId != null) queryParams['fieldId'] = fieldId;

    final response = await _api.get('/nong/weather/latest', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0 && data['data'] != null) {
      return WeatherData.fromJson(data['data']);
    }
    return null;
  }

  // ==================== 农事提醒 ====================

  /// 获取提醒列表
  Future<PageResult<FarmingReminder>> getReminders({
    int? fieldId,
    String? reminderType,
    String? priority,
    bool? isCompleted,
    int pageNo = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'pageNo': pageNo,
      'pageSize': pageSize,
    };
    if (fieldId != null) queryParams['fieldId'] = fieldId;
    if (reminderType != null) queryParams['reminderType'] = reminderType;
    if (priority != null) queryParams['priority'] = priority;
    if (isCompleted != null) queryParams['isCompleted'] = isCompleted;

    final response = await _api.get('/nong/reminders', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return PageResult.fromJson(data['data'], FarmingReminder.fromJson);
    }
    throw Exception(data['message'] ?? '获取提醒列表失败');
  }

  /// 获取今日提醒
  Future<List<FarmingReminder>> getTodayReminders() async {
    final response = await _api.get('/nong/reminders/today');
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      final list = data['data'] as List<dynamic>;
      return list.map((e) => FarmingReminder.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(data['message'] ?? '获取今日提醒失败');
  }

  /// 创建提醒
  Future<FarmingReminder> createReminder(Map<String, dynamic> request) async {
    final response = await _api.post('/nong/reminders', data: request);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return FarmingReminder.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '创建提醒失败');
  }

  /// 完成提醒
  Future<FarmingReminder> completeReminder(int id) async {
    final response = await _api.post('/nong/reminders/$id/complete');
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return FarmingReminder.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '完成提醒失败');
  }

  // ==================== AI 识别 ====================

  /// 获取识别记录列表
  Future<List<AiRecognition>> getRecognitions({
    int? fieldId,
    int? cropId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (fieldId != null) queryParams['fieldId'] = fieldId;
    if (cropId != null) queryParams['cropId'] = cropId;

    final response = await _api.get('/nong/ai/recognitions', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      final list = data['data'] as List<dynamic>;
      return list.map((e) => AiRecognition.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(data['message'] ?? '获取识别记录失败');
  }

  /// 获取最新识别记录
  Future<AiRecognition?> getLatestRecognition({int? fieldId}) async {
    final queryParams = <String, dynamic>{};
    if (fieldId != null) queryParams['fieldId'] = fieldId;

    final response = await _api.get('/nong/ai/recognitions/latest', queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0 && data['data'] != null) {
      return AiRecognition.fromJson(data['data']);
    }
    return null;
  }

  /// 创建识别记录
  Future<AiRecognition> createRecognition(Map<String, dynamic> request) async {
    final response = await _api.post('/nong/ai/recognitions', data: request);
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return AiRecognition.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '创建识别记录失败');
  }

  // ==================== 经营总览 ====================

  /// 获取经营总览数据
  Future<BusinessDashboard> getDashboard() async {
    final response = await _api.get('/nong/dashboard');
    final data = response.data as Map<String, dynamic>;
    if (data['code'] == 0) {
      return BusinessDashboard.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? '获取经营总览失败');
  }
}
