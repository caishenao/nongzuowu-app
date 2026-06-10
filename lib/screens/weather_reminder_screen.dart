import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nong_providers.dart';
import '../models/api_models.dart';
import '../widgets/common_widgets.dart';

class WeatherReminderScreen extends StatefulWidget {
  const WeatherReminderScreen({super.key});

  @override
  State<WeatherReminderScreen> createState() => _WeatherReminderScreenState();
}

class _WeatherReminderScreenState extends State<WeatherReminderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WeatherProvider>().loadLatestWeather();
      context.read<ReminderProvider>().loadTodayReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgLighter,
      child: Column(
        children: [
          const StatusBarWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildWeatherHeader(),
                    const SizedBox(height: 16),
                    _buildSoilRainfallSection(),
                    const SizedBox(height: 16),
                    _buildFarmingReminders(),
                    const SizedBox(height: 16),
                    _buildSmartSummary(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherHeader() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final weather = provider.latestWeather;
        final temp = weather?.temperature?.toStringAsFixed(0) ?? '24';
        final rainfall = weather?.rainfall?.toStringAsFixed(1) ?? '0';
        final humidity = weather?.soilMoisture?.toStringAsFixed(0) ?? '62';
        final desc = weather?.weatherDesc ?? '多云转阵雨';
        
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '气象农事提醒',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 250,
                        child: Text(
                          '北坡稻田 · $desc · 午后降雨概率 68%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD1D5DB),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF72D350),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud,
                      size: 23,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildWeatherMetric('${temp}°', '本地温度', const Color(0xFF72D350)),
                  const SizedBox(width: 1),
                  _buildWeatherMetric(rainfall, '有效降雨 mm', const Color(0xFF72D350)),
                  const SizedBox(width: 1),
                  _buildWeatherMetric('$humidity%', '土壤湿度', const Color(0xFF72D350)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherMetric(String value, String label, Color bgColor) {
    return Expanded(
      child: Container(
        height: 96,
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17211A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF42522D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilRainfallSection() {
    return Consumer<WeatherProvider>(
      builder: (context, provider, child) {
        final weather = provider.latestWeather;
        
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '土壤 / 降雨推断',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '15 min',
                  style: TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Row(
                children: [
                  // 地块湿度图
                  Container(
                    width: 124,
                    height: double.infinity,
                    color: const Color(0xFFCFE6C1),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 18, top: 24,
                          child: CustomPaint(
                            size: const Size(88, 78),
                            painter: MoistureShapePainter(),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: CustomPaint(
                            size: const Size(124, 34),
                            painter: RainPathPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 地块信息
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '北坡稻田',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '水稻 · 抽穗期 · 东南风 2级',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTag('需浇水', const Color(0xFFEEF7F5), const Color(0xFF315F6A)),
                            const SizedBox(width: 8),
                            _buildTag('AI黄叶风险', const Color(0xFFFFF0DC), const Color(0xFF7A3D22)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '午后阵雨前暂停灌溉；若 18:00 后雨量低于 5mm，再补水 12mm。',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF1A1A1A),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmingReminders() {
    return Consumer<ReminderProvider>(
      builder: (context, provider, child) {
        final reminders = provider.todayReminders;
        
        return Column(
          children: [
            const Row(
              children: [
                Text(
                  '今日农事提醒',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (provider.isLoading)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            else if (reminders.isEmpty)
              Container(
                height: 100,
                alignment: Alignment.center,
                child: const Text(
                  '今日暂无提醒',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7B6B),
                  ),
                ),
              )
            else
              ...reminders.map((reminder) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildReminderCard(reminder),
              )),
          ],
        );
      },
    );
  }

  Widget _buildReminderCard(FarmingReminder reminder) {
    IconData icon;
    Color iconBg;
    Color iconColor;
    
    switch (reminder.reminderType) {
      case 'WATER':
        icon = Icons.water_drop;
        iconBg = const Color(0xFF1A1A1A);
        iconColor = const Color(0xFF72D350);
        break;
      case 'FERTILIZE':
        icon = Icons.science;
        iconBg = const Color(0xFF72D350);
        iconColor = const Color(0xFF1A1A1A);
        break;
      case 'HARVEST':
        icon = Icons.grain;
        iconBg = const Color(0xFF1A1A1A);
        iconColor = const Color(0xFF72D350);
        break;
      default:
        icon = Icons.agriculture;
        iconBg = const Color(0xFF1A1A1A);
        iconColor = const Color(0xFF72D350);
    }
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  reminder.content ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          Text(
            reminder.priorityText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_queue,
            size: 24,
            color: Color(0xFF72D350),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '系统结合本地预报、土壤湿度和地块历史降雨，已把浇水与施肥提醒重新排序。',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFFF4F0E4),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MoistureShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF72D350)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path()
      ..moveTo(28, 4)
      ..lineTo(82, 18)
      ..lineTo(74, 62)
      ..lineTo(44, 78)
      ..lineTo(8, 54)
      ..lineTo(4, 22)
      ..close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RainPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF315F6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final path = Path()
      ..moveTo(0, 22)
      ..cubicTo(28, 4, 52, 36, 82, 14)
      ..cubicTo(102, 0, 112, 10, 124, 2);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
