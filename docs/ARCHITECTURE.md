# 农业管理系统 - 架构设计文档

## 目录

- [概述](#概述)
- [架构模式](#架构模式)
- [目录结构](#目录结构)
- [设计模式](#设计模式)
- [依赖注入](#依赖注入)
- [数据流](#数据流)
- [最佳实践](#最佳实践)

## 概述

本项目采用 **Clean Architecture（整洁架构）** 设计思想，结合 Flutter 的特点，实现了高内聚、低耦合的代码结构。

### 核心原则

1. **单一职责原则 (SRP)**：每个类只负责一件事
2. **开闭原则 (OCP)**：对扩展开放，对修改关闭
3. **里氏替换原则 (LSP)**：子类可以替换父类
4. **接口隔离原则 (ISP)**：使用小而专的接口
5. **依赖倒置原则 (DIP)**：依赖抽象而非具体实现

## 架构模式

### 分层架构

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (表现层)                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐       │
│  │ Screen  │  │ Widget  │  │ Page    │  │ Dialog  │       │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘       │
│       └────────────┼────────────┼────────────┘             │
│                    ▼                                        │
├─────────────────────────────────────────────────────────────┤
│               State Layer (状态层)                          │
│  ┌─────────────────────────────────────────────┐           │
│  │              Provider (状态管理)              │           │
│  └─────────────────────┬───────────────────────┘           │
│                        ▼                                    │
├─────────────────────────────────────────────────────────────┤
│             Domain Layer (领域层)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   UseCase   │  │   Model     │  │  Repository │        │
│  │   (用例)     │  │   (模型)     │  │   (接口)     │        │
│  └──────┬──────┘  └─────────────┘  └──────┬──────┘        │
│         │                                  │                │
├─────────┼──────────────────────────────────┼────────────────┤
│         ▼                                  ▼                │
│              Data Layer (数据层)                             │
│  ┌─────────────────┐          ┌─────────────────┐          │
│  │  Repository Impl │          │   DataSource    │          │
│  │   (仓储实现)      │◄────────►│   (数据源)       │          │
│  └─────────────────┘          └─────────────────┘          │
│         │                           │                       │
│         ▼                           ▼                       │
│  ┌─────────────┐            ┌─────────────┐                │
│  │  Remote API │            │  Local DB   │                │
│  │  (远程API)   │            │  (本地存储)   │                │
│  └─────────────┘            └─────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
lib/
├── core/                          # 核心层 - 基础设施
│   ├── constants.dart            # 常量定义
│   ├── di_container.dart         # 依赖注入容器
│   ├── extensions.dart           # 扩展方法
│   ├── result.dart               # 统一结果封装
│   ├── use_case.dart             # 用例基类
│   ├── app_initializer.dart      # 应用初始化器
│   └── repository/               # 仓储基类
│       └── base_repository.dart
│
├── domain/                        # 领域层 - 业务逻辑
│   ├── models/                   # 领域模型
│   ├── repositories/             # 仓储接口
│   │   ├── field_repository.dart
│   │   ├── crop_repository.dart
│   │   └── repositories.dart
│   └── usecases/                 # 用例
│       ├── get_fields_use_case.dart
│       ├── get_crops_use_case.dart
│       └── usecases.dart
│
├── data/                          # 数据层 - 数据访问
│   ├── datasources/              # 数据源
│   │   ├── remote/               # 远程数据源
│   │   └── local/                # 本地数据源
│   └── repositories/             # 仓储实现
│
├── presentation/                  # 表现层 - UI
│   ├── screens/                  # 页面
│   ├── widgets/                  # 组件
│   └── providers/                # 状态管理
│
├── services/                      # 服务层 - 通用服务
│   ├── api_service.dart          # API 服务
│   ├── storage_service.dart      # 存储服务
│   └── notification_service.dart # 通知服务
│
├── config/                        # 配置
│   └── api_config.dart
│
├── models/                        # 数据模型
│   └── api_models.dart
│
├── providers/                     # 状态管理
│   └── nong_providers.dart
│
├── screens/                       # 页面
├── widgets/                       # 通用组件
├── services/                      # 服务
└── main.dart                      # 入口文件
```

## 设计模式

### 1. 单例模式 (Singleton)

确保一个类只有一个实例，并提供全局访问点。

```dart
class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();
}
```

**使用场景**：依赖注入容器、存储服务、API 服务

### 2. 工厂模式 (Factory)

提供创建对象的接口，让子类决定实例化哪个类。

```dart
abstract class BaseRepository<T> {
  Future<Result<T>> create(T entity);
}

class FieldRepositoryImpl implements FieldRepository {
  @override
  Future<Result<FieldInfo>> create(FieldInfo entity) async {
    // 具体创建逻辑
  }
}
```

**使用场景**：仓储创建、用例创建

### 3. 仓储模式 (Repository)

分离数据访问逻辑与业务逻辑。

```dart
// 接口
abstract class FieldRepository extends BaseRepository<FieldInfo> {
  Future<Result<List<FieldInfo>>> searchByName(String name);
}

// 实现
class FieldRepositoryImpl implements FieldRepository {
  final ApiService _api;
  
  FieldRepositoryImpl(this._api);
  
  @override
  Future<Result<List<FieldInfo>>> searchByName(String name) async {
    return getAll(params: {'fieldName': name});
  }
}
```

**使用场景**：所有数据访问

### 4. 用例模式 (UseCase)

封装单个业务逻辑。

```dart
class GetFieldsUseCase extends UseCase<List<FieldInfo>, GetFieldsParams> {
  final FieldRepository _repository;

  GetFieldsUseCase(this._repository);

  @override
  Future<Result<List<FieldInfo>>> call(GetFieldsParams params) async {
    return _repository.getAll(params: params.toMap());
  }
}
```

**使用场景**：所有业务操作

### 5. 结果模式 (Result)

统一处理成功/失败状态。

```dart
final result = await repository.getAll();

result.when(
  success: (data) => showData(data),
  error: (message, code) => showError(message),
);
```

**使用场景**：所有异步操作

### 6. 观察者模式 (Observer)

使用 Provider 实现状态管理。

```dart
class FieldProvider extends ChangeNotifier {
  List<FieldInfo> _fields = [];
  
  List<FieldInfo> get fields => _fields;
  
  Future<void> loadFields() async {
    _fields = await repository.getAll();
    notifyListeners(); // 通知观察者
  }
}
```

**使用场景**：状态管理

### 7. 服务定位器模式 (Service Locator)

通过依赖注入容器获取服务。

```dart
final di = DIContainer();
final api = di.get<ApiService>();
final repo = di.get<FieldRepository>();
```

**使用场景**：依赖管理

## 依赖注入

### 注册服务

```dart
// 在 AppInitializer 中注册
void _registerServices() {
  // 单例 - 全局共享一个实例
  _di.registerSingleton<StorageService>(StorageService());
  
  // 延迟单例 - 首次使用时创建
  _di.registerLazySingleton<ExportService>(() => ExportService());
  
  // 工厂 - 每次获取都创建新实例
  _di.registerFactory<GetFieldsUseCase>(
    () => GetFieldsUseCase(_di.get<FieldRepository>()),
  );
}
```

### 使用服务

```dart
// 方式1：直接获取
final service = DIContainer().get<ApiService>();

// 方式2：通过构造函数注入
class MyService {
  final ApiService _api;
  
  MyService(this._api);
}
```

## 数据流

```
用户操作 (UI)
    ↓
调用 Provider 方法
    ↓
Provider 调用 UseCase
    ↓
UseCase 调用 Repository
    ↓
Repository 调用 DataSource (API/本地)
    ↓
返回 Result<T>
    ↓
Provider 更新状态
    ↓
UI 自动刷新
```

## 最佳实践

### 1. 命名规范

- **类名**：PascalCase（如 `FieldRepository`）
- **方法名**：camelCase（如 `getFields`）
- **常量**：camelCase 或 UPPER_SNAKE_CASE
- **文件名**：snake_case（如 `field_repository.dart`）

### 2. 注释规范

```dart
/// 类的文档注释
/// 
/// 说明类的职责和使用场景
class MyClass {
  /// 方法的文档注释
  /// 
  /// [param1] 参数说明
  /// [param2] 参数说明
  /// 返回值说明
  void myMethod(String param1, int param2) {
    // 行内注释
  }
}
```

### 3. 错误处理

```dart
// 使用 Result 模式
Future<Result<Data>> fetchData() async {
  try {
    final data = await api.getData();
    return Result.success(data);
  } catch (e) {
    return Result.error('获取数据失败: $e');
  }
}

// 使用时处理
result.when(
  success: (data) => handleSuccess(data),
  error: (message, code) => handleError(message),
);
```

### 4. 状态管理

```dart
class MyProvider extends ChangeNotifier {
  // 私有状态
  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;
  
  // 公开 getter
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 状态修改方法
  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _items = await repository.getAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 扩展指南

### 添加新功能

1. **定义模型**：在 `models/` 中添加数据模型
2. **定义接口**：在 `domain/repositories/` 中添加仓储接口
3. **实现仓储**：在 `data/repositories/` 中实现仓储
4. **创建用例**：在 `domain/usecases/` 中添加用例
5. **注册服务**：在 `app_initializer.dart` 中注册
6. **创建 Provider**：在 `providers/` 中添加状态管理
7. **创建页面**：在 `screens/` 中添加 UI

### 示例：添加"天气"功能

```dart
// 1. 模型
class WeatherInfo {
  final double temperature;
  final double humidity;
  // ...
}

// 2. 仓储接口
abstract class WeatherRepository {
  Future<Result<WeatherInfo>> getCurrent();
}

// 3. 仓储实现
class WeatherRepositoryImpl implements WeatherRepository {
  final ApiService _api;
  WeatherRepositoryImpl(this._api);
  
  @override
  Future<Result<WeatherInfo>> getCurrent() async {
    // 实现
  }
}

// 4. 用例
class GetWeatherUseCase extends NoParamsUseCase<WeatherInfo> {
  final WeatherRepository _repo;
  GetWeatherUseCase(this._repo);
  
  @override
  Future<Result<WeatherInfo>> call() => _repo.getCurrent();
}

// 5. 注册
_di.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(_di.get()));
_di.registerFactory(() => GetWeatherUseCase(_di.get()));

// 6. Provider
class WeatherProvider extends ChangeNotifier {
  final GetWeatherUseCase _useCase;
  WeatherProvider(this._useCase);
  // ...
}

// 7. 页面
class WeatherPage extends StatelessWidget {
  // ...
}
```
