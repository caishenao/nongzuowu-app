/// ============================================================================
/// 文件名: di_container.dart
/// 描述: 依赖注入容器 - 管理对象的创建和生命周期
/// 
/// 设计模式: Service Locator Pattern (服务定位器模式)
/// 
/// 依赖注入(DI)容器负责：
/// 1. 管理对象的创建（工厂模式）
/// 2. 管理对象的生命周期（单例/瞬时）
/// 3. 解决依赖关系
/// 4. 便于测试时替换依赖
/// 
/// 使用示例:
/// ```dart
/// // 初始化
/// final di = DIContainer();
/// di.registerLazySingleton<ApiService>(() => ApiService());
/// di.registerFactory<FieldRepository>(() => FieldRepositoryImpl(di.get()));
/// 
/// // 使用
/// final api = di.get<ApiService>();
/// final repo = di.get<FieldRepository>();
/// ```
/// ============================================================================

/// 依赖注入容器
/// 
/// 使用 Map 存储工厂函数，实现延迟初始化
class DIContainer {
  // ==================== 单例模式 ====================
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  /// 存储单例实例
  final Map<Type, dynamic> _singletons = {};
  
  /// 存储工厂函数（每次调用都创建新实例）
  final Map<Type, Function> _factories = {};
  
  /// 存储延迟单例工厂函数（首次使用时创建）
  final Map<Type, Function> _lazySingletons = {};

  // ==================== 注册方法 ====================

  /// 注册瞬时工厂
  /// 
  /// 每次获取时都会创建新实例
  /// 适用于无状态的对象或需要全新实例的场景
  /// 
  /// [T] 服务类型
  /// [factory] 工厂函数
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// 注册单例
  /// 
  /// 立即创建实例，之后每次获取都返回同一实例
  /// 适用于有状态的服务或需要全局共享的对象
  /// 
  /// [T] 服务类型
  /// [instance] 单例实例
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// 注册延迟单例
  /// 
  /// 首次获取时才创建实例，之后每次获取都返回同一实例
  /// 适用于初始化成本高或不一定每次都使用的服务
  /// 
  /// [T] 服务类型
  /// [factory] 工厂函数
  void registerLazySingleton<T>(T Function() factory) {
    _lazySingletons[T] = factory;
  }

  // ==================== 获取方法 ====================

  /// 获取服务实例
  /// 
  /// 按优先级查找：单例 > 延迟单例 > 工厂
  /// 如果未注册，抛出异常
  /// 
  /// [T] 服务类型
  /// 返回服务实例
  T get<T>() {
    // 1. 检查单例
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    
    // 2. 检查延迟单例
    if (_lazySingletons.containsKey(T)) {
      final instance = _lazySingletons[T]!() as T;
      _singletons[T] = instance; // 转为单例
      _lazySingletons.remove(T); // 移除工厂
      return instance;
    }
    
    // 3. 检查工厂
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    
    // 4. 未注册
    throw Exception('Service $T not registered. Please register it first.');
  }

  /// 尝试获取服务实例（不抛出异常）
  /// 
  /// 如果未注册，返回 null
  T? tryGet<T>() {
    try {
      return get<T>();
    } catch (e) {
      return null;
    }
  }

  /// 检查服务是否已注册
  bool isRegistered<T>() {
    return _singletons.containsKey(T) || 
           _lazySingletons.containsKey(T) || 
           _factories.containsKey(T);
  }

  // ==================== 管理方法 ====================

  /// 注销服务
  void unregister<T>() {
    _singletons.remove(T);
    _lazySingletons.remove(T);
    _factories.remove(T);
  }

  /// 清除所有注册
  void clear() {
    _singletons.clear();
    _lazySingletons.clear();
    _factories.clear();
  }

  /// 重置容器（用于测试）
  void reset() {
    clear();
  }

  /// 获取已注册的服务数量
  int get registeredCount {
    return _singletons.length + _lazySingletons.length + _factories.length;
  }

  /// 获取所有已注册的类型
  Set<Type> get registeredTypes {
    return {
      ..._singletons.keys,
      ..._lazySingletons.keys,
      ..._factories.keys,
    };
  }
}

/// 依赖注入扩展
/// 
/// 提供便捷的获取方法
extension DIContainerExtension on DIContainer {
  /// 获取服务（简写方式）
  T call<T>() => get<T>();
}
