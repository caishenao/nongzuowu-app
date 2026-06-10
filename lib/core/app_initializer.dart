/// ============================================================================
/// 文件名: app_initializer.dart
/// 描述: 应用初始化器 - 统一管理应用启动时的初始化逻辑
/// 
/// 设计模式: Facade Pattern (门面模式)
/// 
/// 门面模式提供一个统一的接口来访问子系统中的一组接口。
/// AppInitializer 就是一个门面，它封装了所有初始化逻辑。
/// 
/// 职责：
/// 1. 初始化依赖注入容器
/// 2. 初始化本地存储
/// 3. 初始化网络服务
/// 4. 注册所有服务和仓储
/// ============================================================================

import 'di_container.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../services/nong_api_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../domain/repositories/field_repository.dart';
import '../domain/repositories/crop_repository.dart';
import '../domain/usecases/usecases.dart';

/// 应用初始化器
/// 
/// 使用单例模式确保只初始化一次
class AppInitializer {
  // ==================== 单例模式 ====================
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  /// 是否已初始化
  bool _initialized = false;
  
  /// 依赖注入容器
  final DIContainer _di = DIContainer();

  /// 初始化应用
  /// 
  /// 必须在 runApp() 之前调用
  /// 按顺序初始化各个服务
  Future<void> initialize() async {
    if (_initialized) return;
    
    print('🚀 开始初始化应用...');
    
    try {
      // 1. 初始化本地存储
      await _initializeStorage();
      
      // 2. 初始化网络服务
      await _initializeNetwork();
      
      // 3. 注册服务
      _registerServices();
      
      // 4. 注册仓储
      _registerRepositories();
      
      // 5. 注册用例
      _registerUseCases();
      
      _initialized = true;
      print('✅ 应用初始化完成');
    } catch (e) {
      print('❌ 应用初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化本地存储
  Future<void> _initializeStorage() async {
    print('📦 初始化本地存储...');
    final storage = StorageService();
    await storage.init();
    _di.registerSingleton<StorageService>(storage);
  }

  /// 初始化网络服务
  Future<void> _initializeNetwork() async {
    print('🌐 初始化网络服务...');
    final apiService = ApiService();
    _di.registerSingleton<ApiService>(apiService);
    
    final nongApiService = NongApiService();
    _di.registerSingleton<NongApiService>(nongApiService);
  }

  /// 注册服务
  void _registerServices() {
    print('🔧 注册服务...');
    
    // 导出服务
    _di.registerLazySingleton<ExportService>(() => ExportService());
    
    // 通知服务
    _di.registerLazySingleton<NotificationService>(() => NotificationService());
  }

  /// 注册仓储
  void _registerRepositories() {
    print('📚 注册仓储...');
    
    // 地块仓储
    _di.registerLazySingleton<FieldRepository>(
      () => FieldRepositoryImpl(_di.get<ApiService>()),
    );
    
    // 作物仓储（暂时使用相同实现）
    // _di.registerLazySingleton<CropRepository>(
    //   () => CropRepositoryImpl(_di.get<ApiService>()),
    // );
  }

  /// 注册用例
  void _registerUseCases() {
    print('🎯 注册用例...');
    
    // 获取地块列表用例
    _di.registerFactory<GetFieldsUseCase>(
      () => GetFieldsUseCase(_di.get<FieldRepository>()),
    );
    
    // 获取作物列表用例
    // _di.registerFactory<GetCropsUseCase>(
    //   () => GetCropsUseCase(_di.get<CropRepository>()),
    // );
  }

  /// 获取依赖注入容器
  DIContainer get container => _di;
  
  /// 是否已初始化
  bool get isInitialized => _initialized;
}
