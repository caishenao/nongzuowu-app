import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../services/nong_api_service.dart';

/// 地块管理状态
class FieldProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  List<FieldInfo> _fields = [];
  FieldInfo? _currentField;
  bool _isLoading = false;
  String? _error;

  List<FieldInfo> get fields => _fields;
  FieldInfo? get currentField => _currentField;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载地块列表
  Future<void> loadFields({String? fieldName, String? fieldType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getFields(fieldName: fieldName, fieldType: fieldType);
      _fields = result.records;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载地块详情
  Future<void> loadFieldDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentField = await _api.getField(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建地块
  Future<bool> createField(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final field = await _api.createField(request);
      _fields.insert(0, field);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新地块
  Future<bool> updateField(int id, Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final field = await _api.updateField(id, request);
      final index = _fields.indexWhere((f) => f.id == id);
      if (index != -1) {
        _fields[index] = field;
      }
      if (_currentField?.id == id) {
        _currentField = field;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除地块
  Future<bool> deleteField(int id) async {
    try {
      final success = await _api.deleteField(id);
      if (success) {
        _fields.removeWhere((f) => f.id == id);
        if (_currentField?.id == id) {
          _currentField = null;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 作物管理状态
class CropProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  List<CropInfo> _crops = [];
  CropInfo? _currentCrop;
  bool _isLoading = false;
  String? _error;

  List<CropInfo> get crops => _crops;
  CropInfo? get currentCrop => _currentCrop;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载作物列表
  Future<void> loadCrops({String? cropName, int? fieldId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getCrops(cropName: cropName, fieldId: fieldId);
      _crops = result.records;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载作物详情
  Future<void> loadCropDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentCrop = await _api.getCrop(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建作物
  Future<bool> createCrop(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final crop = await _api.createCrop(request);
      _crops.insert(0, crop);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 田间操作状态
class OperationProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  List<FieldOperation> _operations = [];
  bool _isLoading = false;
  String? _error;

  List<FieldOperation> get operations => _operations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载操作记录
  Future<void> loadOperations({int? fieldId, int? cropId, String? operationType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getOperations(
        fieldId: fieldId,
        cropId: cropId,
        operationType: operationType,
      );
      _operations = result.records;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建操作记录
  Future<bool> createOperation(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final operation = await _api.createOperation(request);
      _operations.insert(0, operation);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 气象数据状态
class WeatherProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  WeatherData? _latestWeather;
  List<WeatherData> _weatherList = [];
  bool _isLoading = false;
  String? _error;

  WeatherData? get latestWeather => _latestWeather;
  List<WeatherData> get weatherList => _weatherList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载最新气象数据
  Future<void> loadLatestWeather({int? fieldId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestWeather = await _api.getLatestWeather(fieldId: fieldId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载气象数据列表
  Future<void> loadWeatherList({int? fieldId, String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherList = await _api.getWeatherData(
        fieldId: fieldId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 农事提醒状态
class ReminderProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  List<FarmingReminder> _reminders = [];
  List<FarmingReminder> _todayReminders = [];
  bool _isLoading = false;
  String? _error;

  List<FarmingReminder> get reminders => _reminders;
  List<FarmingReminder> get todayReminders => _todayReminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载提醒列表
  Future<void> loadReminders({int? fieldId, String? reminderType, bool? isCompleted}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.getReminders(
        fieldId: fieldId,
        reminderType: reminderType,
        isCompleted: isCompleted,
      );
      _reminders = result.records;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载今日提醒
  Future<void> loadTodayReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayReminders = await _api.getTodayReminders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建提醒
  Future<bool> createReminder(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reminder = await _api.createReminder(request);
      _reminders.insert(0, reminder);
      _todayReminders.insert(0, reminder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 完成提醒
  Future<bool> completeReminder(int id) async {
    try {
      final reminder = await _api.completeReminder(id);
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = reminder;
      }
      _todayReminders.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// AI 识别状态
class AiProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  List<AiRecognition> _recognitions = [];
  AiRecognition? _latestRecognition;
  bool _isLoading = false;
  String? _error;

  List<AiRecognition> get recognitions => _recognitions;
  AiRecognition? get latestRecognition => _latestRecognition;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载识别记录
  Future<void> loadRecognitions({int? fieldId, int? cropId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _recognitions = await _api.getRecognitions(fieldId: fieldId, cropId: cropId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载最新识别记录
  Future<void> loadLatestRecognition({int? fieldId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _latestRecognition = await _api.getLatestRecognition(fieldId: fieldId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建识别记录
  Future<bool> createRecognition(Map<String, dynamic> request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final recognition = await _api.createRecognition(request);
      _recognitions.insert(0, recognition);
      _latestRecognition = recognition;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// 经营总览状态
class DashboardProvider extends ChangeNotifier {
  final NongApiService _api = NongApiService();
  
  BusinessDashboard? _dashboard;
  bool _isLoading = false;
  String? _error;

  BusinessDashboard? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载经营总览数据
  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _api.getDashboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
