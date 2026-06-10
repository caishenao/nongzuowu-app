/// 通用响应模型
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse(
      code: json['code'] ?? -1,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJson != null ? fromJson(json['data']) : json['data'],
    );
  }
}

/// 分页响应模型
class PageResult<T> {
  final int total;
  final List<T> records;

  PageResult({
    required this.total,
    required this.records,
  });

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PageResult(
      total: json['total'] ?? 0,
      records: (json['records'] as List<dynamic>?)
              ?.map((e) => fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// 地块模型
class FieldInfo {
  final int id;
  final String? userId;
  final String? fieldCode;
  final String fieldName;
  final String? fieldType;
  final double? area;
  final double? areaMu;
  final double? perimeter;
  final double? centerLongitude;
  final double? centerLatitude;
  final String? boundaryPoints;
  final String? soilType;
  final String? irrigationType;
  final String? address;
  final String? remark;
  final int? status;
  final String? currentCropName;

  FieldInfo({
    required this.id,
    this.userId,
    this.fieldCode,
    required this.fieldName,
    this.fieldType,
    this.area,
    this.areaMu,
    this.perimeter,
    this.centerLongitude,
    this.centerLatitude,
    this.boundaryPoints,
    this.soilType,
    this.irrigationType,
    this.address,
    this.remark,
    this.status,
    this.currentCropName,
  });

  factory FieldInfo.fromJson(Map<String, dynamic> json) {
    return FieldInfo(
      id: json['id'] ?? 0,
      userId: json['userId'],
      fieldCode: json['fieldCode'],
      fieldName: json['fieldName'] ?? '',
      fieldType: json['fieldType'],
      area: _toDouble(json['area']),
      areaMu: _toDouble(json['areaMu']),
      perimeter: _toDouble(json['perimeter']),
      centerLongitude: _toDouble(json['centerLongitude']),
      centerLatitude: _toDouble(json['centerLatitude']),
      boundaryPoints: json['boundaryPoints'],
      soilType: json['soilType'],
      irrigationType: json['irrigationType'],
      address: json['address'],
      remark: json['remark'],
      status: json['status'],
      currentCropName: json['currentCropName'],
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

/// 作物模型
class CropInfo {
  final int id;
  final String? userId;
  final String? cropCode;
  final String cropName;
  final String? variety;
  final int? fieldId;
  final String? fieldName;
  final String? batchNo;
  final String? sowDate;
  final String? harvestDate;
  final String? growthStage;
  final int? growthDays;
  final double? plantingArea;
  final double? ndviValue;
  final int? status;
  final String? remark;

  CropInfo({
    required this.id,
    this.userId,
    this.cropCode,
    required this.cropName,
    this.variety,
    this.fieldId,
    this.fieldName,
    this.batchNo,
    this.sowDate,
    this.harvestDate,
    this.growthStage,
    this.growthDays,
    this.plantingArea,
    this.ndviValue,
    this.status,
    this.remark,
  });

  factory CropInfo.fromJson(Map<String, dynamic> json) {
    return CropInfo(
      id: json['id'] ?? 0,
      userId: json['userId'],
      cropCode: json['cropCode'],
      cropName: json['cropName'] ?? '',
      variety: json['variety'],
      fieldId: json['fieldId'],
      fieldName: json['fieldName'],
      batchNo: json['batchNo'],
      sowDate: json['sowDate'],
      harvestDate: json['harvestDate'],
      growthStage: json['growthStage'],
      growthDays: json['growthDays'],
      plantingArea: FieldInfo._toDouble(json['plantingArea']),
      ndviValue: FieldInfo._toDouble(json['ndviValue']),
      status: json['status'],
      remark: json['remark'],
    );
  }
}

/// 田间操作记录模型
class FieldOperation {
  final int id;
  final String? userId;
  final int? fieldId;
  final String? fieldName;
  final int? cropId;
  final String? operationType;
  final String? operationDate;
  final String title;
  final String? detail;
  final double? quantity;
  final String? unit;
  final String? operatorName;
  final String? status;
  final String? weather;
  final String? remark;

  FieldOperation({
    required this.id,
    this.userId,
    this.fieldId,
    this.fieldName,
    this.cropId,
    this.operationType,
    this.operationDate,
    required this.title,
    this.detail,
    this.quantity,
    this.unit,
    this.operatorName,
    this.status,
    this.weather,
    this.remark,
  });

  factory FieldOperation.fromJson(Map<String, dynamic> json) {
    return FieldOperation(
      id: json['id'] ?? 0,
      userId: json['userId'],
      fieldId: json['fieldId'],
      fieldName: json['fieldName'],
      cropId: json['cropId'],
      operationType: json['operationType'],
      operationDate: json['operationDate'],
      title: json['title'] ?? '',
      detail: json['detail'],
      quantity: FieldInfo._toDouble(json['quantity']),
      unit: json['unit'],
      operatorName: json['operatorName'],
      status: json['status'],
      weather: json['weather'],
      remark: json['remark'],
    );
  }
}

/// 气象数据模型
class WeatherData {
  final int id;
  final int? fieldId;
  final String? recordDate;
  final int? recordHour;
  final double? temperature;
  final double? humidity;
  final double? rainfall;
  final double? windSpeed;
  final String? windDirection;
  final double? soilMoisture;
  final double? soilTemperature;
  final String? weatherDesc;
  final String? weatherIcon;

  WeatherData({
    required this.id,
    this.fieldId,
    this.recordDate,
    this.recordHour,
    this.temperature,
    this.humidity,
    this.rainfall,
    this.windSpeed,
    this.windDirection,
    this.soilMoisture,
    this.soilTemperature,
    this.weatherDesc,
    this.weatherIcon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      id: json['id'] ?? 0,
      fieldId: json['fieldId'],
      recordDate: json['recordDate'],
      recordHour: json['recordHour'],
      temperature: FieldInfo._toDouble(json['temperature']),
      humidity: FieldInfo._toDouble(json['humidity']),
      rainfall: FieldInfo._toDouble(json['rainfall']),
      windSpeed: FieldInfo._toDouble(json['windSpeed']),
      windDirection: json['windDirection'],
      soilMoisture: FieldInfo._toDouble(json['soilMoisture']),
      soilTemperature: FieldInfo._toDouble(json['soilTemperature']),
      weatherDesc: json['weatherDesc'],
      weatherIcon: json['weatherIcon'],
    );
  }
}

/// 农事提醒模型
class FarmingReminder {
  final int id;
  final String? userId;
  final int? fieldId;
  final String? fieldName;
  final int? cropId;
  final String? reminderType;
  final String title;
  final String? content;
  final String? priority;
  final String? remindDate;
  final bool? isCompleted;
  final String? completedTime;
  final bool? aiGenerated;
  final String? aiReason;
  final int? status;

  FarmingReminder({
    required this.id,
    this.userId,
    this.fieldId,
    this.fieldName,
    this.cropId,
    this.reminderType,
    required this.title,
    this.content,
    this.priority,
    this.remindDate,
    this.isCompleted,
    this.completedTime,
    this.aiGenerated,
    this.aiReason,
    this.status,
  });

  factory FarmingReminder.fromJson(Map<String, dynamic> json) {
    return FarmingReminder(
      id: json['id'] ?? 0,
      userId: json['userId'],
      fieldId: json['fieldId'],
      fieldName: json['fieldName'],
      cropId: json['cropId'],
      reminderType: json['reminderType'],
      title: json['title'] ?? '',
      content: json['content'],
      priority: json['priority'],
      remindDate: json['remindDate'],
      isCompleted: json['isCompleted'],
      completedTime: json['completedTime'],
      aiGenerated: json['aiGenerated'],
      aiReason: json['aiReason'],
      status: json['status'],
    );
  }

  String get priorityText {
    switch (priority) {
      case 'HIGH':
        return '高';
      case 'MEDIUM':
        return '中';
      case 'LOW':
        return '低';
      default:
        return '中';
    }
  }

  String get typeText {
    switch (reminderType) {
      case 'WATER':
        return '浇水';
      case 'FERTILIZE':
        return '施肥';
      case 'SPRAY':
        return '喷药';
      case 'HARVEST':
        return '收获';
      case 'INSPECT':
        return '巡检';
      default:
        return '其他';
    }
  }
}

/// AI 识别记录模型
class AiRecognition {
  final int id;
  final String? userId;
  final int? fieldId;
  final String? fieldName;
  final int? cropId;
  final String? recognitionType;
  final String? imageUrl;
  final String? cropName;
  final String? growthStage;
  final double? confidence;
  final int? growthScore;
  final String? chlorophyllLevel;
  final String? waterRisk;
  final double? diseaseProbability;
  final String? diagnosisTitle;
  final String? diagnosisContent;
  final String? diagnosisLevel;
  final String? advice;

  AiRecognition({
    required this.id,
    this.userId,
    this.fieldId,
    this.fieldName,
    this.cropId,
    this.recognitionType,
    this.imageUrl,
    this.cropName,
    this.growthStage,
    this.confidence,
    this.growthScore,
    this.chlorophyllLevel,
    this.waterRisk,
    this.diseaseProbability,
    this.diagnosisTitle,
    this.diagnosisContent,
    this.diagnosisLevel,
    this.advice,
  });

  factory AiRecognition.fromJson(Map<String, dynamic> json) {
    return AiRecognition(
      id: json['id'] ?? 0,
      userId: json['userId'],
      fieldId: json['fieldId'],
      fieldName: json['fieldName'],
      cropId: json['cropId'],
      recognitionType: json['recognitionType'],
      imageUrl: json['imageUrl'],
      cropName: json['cropName'],
      growthStage: json['growthStage'],
      confidence: FieldInfo._toDouble(json['confidence']),
      growthScore: json['growthScore'],
      chlorophyllLevel: json['chlorophyllLevel'],
      waterRisk: json['waterRisk'],
      diseaseProbability: FieldInfo._toDouble(json['diseaseProbability']),
      diagnosisTitle: json['diagnosisTitle'],
      diagnosisContent: json['diagnosisContent'],
      diagnosisLevel: json['diagnosisLevel'],
      advice: json['advice'],
    );
  }
}

/// 经营总览模型
class BusinessDashboard {
  final double? totalAreaMu;
  final int? activeCropCount;
  final int? pendingTaskCount;
  final int? totalFieldCount;
  final List<FieldMonitorItem>? fieldMonitors;
  final List<TodayTask>? todayTasks;

  BusinessDashboard({
    this.totalAreaMu,
    this.activeCropCount,
    this.pendingTaskCount,
    this.totalFieldCount,
    this.fieldMonitors,
    this.todayTasks,
  });

  factory BusinessDashboard.fromJson(Map<String, dynamic> json) {
    return BusinessDashboard(
      totalAreaMu: FieldInfo._toDouble(json['totalAreaMu']),
      activeCropCount: json['activeCropCount'],
      pendingTaskCount: json['pendingTaskCount'],
      totalFieldCount: json['totalFieldCount'],
      fieldMonitors: (json['fieldMonitors'] as List<dynamic>?)
          ?.map((e) => FieldMonitorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      todayTasks: (json['todayTasks'] as List<dynamic>?)
          ?.map((e) => TodayTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 地块监控项模型
class FieldMonitorItem {
  final int? fieldId;
  final String? fieldCode;
  final String? fieldName;
  final String? cropName;
  final String? growthStage;
  final int? growthDays;
  final double? areaMu;
  final double? ndviValue;
  final String? soilMoisture;
  final List<String>? tags;
  final String? suggestion;

  FieldMonitorItem({
    this.fieldId,
    this.fieldCode,
    this.fieldName,
    this.cropName,
    this.growthStage,
    this.growthDays,
    this.areaMu,
    this.ndviValue,
    this.soilMoisture,
    this.tags,
    this.suggestion,
  });

  factory FieldMonitorItem.fromJson(Map<String, dynamic> json) {
    return FieldMonitorItem(
      fieldId: json['fieldId'],
      fieldCode: json['fieldCode'],
      fieldName: json['fieldName'],
      cropName: json['cropName'],
      growthStage: json['growthStage'],
      growthDays: json['growthDays'],
      areaMu: FieldInfo._toDouble(json['areaMu']),
      ndviValue: FieldInfo._toDouble(json['ndviValue']),
      soilMoisture: json['soilMoisture'],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      suggestion: json['suggestion'],
    );
  }
}

/// 今日任务模型
class TodayTask {
  final int? id;
  final String? taskType;
  final String? title;
  final String? subtitle;
  final String? priority;
  final String? fieldName;
  final bool? aiGenerated;

  TodayTask({
    this.id,
    this.taskType,
    this.title,
    this.subtitle,
    this.priority,
    this.fieldName,
    this.aiGenerated,
  });

  factory TodayTask.fromJson(Map<String, dynamic> json) {
    return TodayTask(
      id: json['id'],
      taskType: json['taskType'],
      title: json['title'],
      subtitle: json['subtitle'],
      priority: json['priority'],
      fieldName: json['fieldName'],
      aiGenerated: json['aiGenerated'],
    );
  }

  String get priorityText {
    switch (priority) {
      case 'HIGH':
        return '高';
      case 'MEDIUM':
        return '中';
      case 'LOW':
        return '低';
      default:
        return '中';
    }
  }
}
