import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/nong_providers.dart';
import 'screens/map_plotting_screen.dart';
import 'screens/crop_records_screen.dart';
import 'screens/weather_reminder_screen.dart';
import 'screens/ai_recognition_screen.dart';
import 'screens/business_overview_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FieldProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => OperationProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: '农业地块与农作物管理',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF1B3A28),
          scaffoldBackgroundColor: const Color(0xFFE9EFE5),
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B3A28),
            brightness: Brightness.light,
          ),
        ),
        home: const MainApp(),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapPlottingScreen(),
    const CropRecordsScreen(),
    const WeatherReminderScreen(),
    const AiRecognitionScreen(),
    const BusinessOverviewScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化加载数据
    _loadInitialData();
  }

  void _loadInitialData() {
    // 延迟加载，避免在 build 过程中调用
    Future.microtask(() {
      context.read<FieldProvider>().loadFields();
      context.read<CropProvider>().loadCrops();
      context.read<WeatherProvider>().loadLatestWeather();
      context.read<ReminderProvider>().loadTodayReminders();
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3EE),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.map_outlined, Icons.map, '地图'),
              _buildNavItem(1, Icons.sprout_outlined, Icons.sprout, '作物'),
              _buildNavItem(2, Icons.notifications_outlined, Icons.notifications, '提醒'),
              _buildNavItem(3, Icons.camera_alt_outlined, Icons.camera_alt, '识别'),
              _buildNavItem(4, Icons.dashboard_outlined, Icons.dashboard, '总览'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // 切换页面时刷新数据
        _onPageChanged(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDDE9D4) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF1B3A28) : const Color(0xFF4A6B52),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1B3A28) : const Color(0xFF4A6B52),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    switch (index) {
      case 0:
        context.read<FieldProvider>().loadFields();
        break;
      case 1:
        context.read<CropProvider>().loadCrops();
        break;
      case 2:
        context.read<ReminderProvider>().loadTodayReminders();
        context.read<WeatherProvider>().loadLatestWeather();
        break;
      case 3:
        context.read<AiProvider>().loadLatestRecognition();
        break;
      case 4:
        context.read<DashboardProvider>().loadDashboard();
        break;
    }
  }
}
