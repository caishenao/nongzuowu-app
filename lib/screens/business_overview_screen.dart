import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nong_providers.dart';
import '../models/api_models.dart';


class BusinessOverviewScreen extends StatefulWidget {
  const BusinessOverviewScreen({super.key});

  @override
  State<BusinessOverviewScreen> createState() => _BusinessOverviewScreenState();
}

class _BusinessOverviewScreenState extends State<BusinessOverviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8EF),
      child: Column(
        children: [
          _buildStatusBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFarmOverviewHeader(),
                    const SizedBox(height: 16),
                    _buildFieldMonitoring(),
                    const SizedBox(height: 16),
                    _buildDailyTasks(),
                    const SizedBox(height: 16),
                    _buildSmartReminder(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D2A1F),
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 17, color: const Color(0xFF1D2A1F)),
              const SizedBox(width: 7),
              Icon(Icons.wifi, size: 17, color: const Color(0xFF1D2A1F)),
              const SizedBox(width: 7),
              Icon(Icons.battery_full, size: 17, color: const Color(0xFF1D2A1F)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmOverviewHeader() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final dashboard = provider.dashboard;
        final totalArea = dashboard?.totalAreaMu?.toStringAsFixed(1) ?? '0';
        final cropCount = dashboard?.activeCropCount ?? 0;
        final taskCount = dashboard?.pendingTaskCount ?? 0;
        final fieldCount = dashboard?.totalFieldCount ?? 0;
        
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF17211A),
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
                        '经营总览',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF9F4E8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 250,
                        child: Text(
                          '今天 $taskCount 块地需要关注，优先处理缺水与虫害风险',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFC9D6C3),
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
                      color: Color(0xFFD7F05B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 23, color: Color(0xFF17211A)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildOverviewMetric(totalArea, '耕地 / 亩', const Color(0xFFD7F05B)),
                  const SizedBox(width: 1),
                  _buildOverviewMetric('$cropCount', '作物 / 批', const Color(0xFFD7F05B)),
                  const SizedBox(width: 1),
                  _buildOverviewMetric('$taskCount', '待办 / 项', const Color(0xFFD7F05B)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewMetric(String value, String label, Color bgColor) {
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
                fontFamily: 'Roboto Mono',
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

  Widget _buildFieldMonitoring() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final monitors = provider.dashboard?.fieldMonitors ?? [];
        
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '地块监控',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17211A),
                  ),
                ),
                const Text(
                  '全部',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF60722C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.isLoading)
              Container(
                height: 150,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            else if (monitors.isEmpty)
              Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8CF),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: const Text(
                  '暂无地块监控数据',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C654B),
                  ),
                ),
              )
            else
              ...monitors.take(2).map((monitor) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildFieldMonitorCard(monitor),
              )),
          ],
        );
      },
    );
  }

  Widget _buildFieldMonitorCard(FieldMonitorItem monitor) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8CF),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          // 地块缩略图
          Container(
            width: 124,
            height: double.infinity,
            color: const Color(0xFFBFD0A6),
            child: Stack(
              children: [
                Positioned(
                  left: 18, top: 24,
                  child: CustomPaint(
                    size: const Size(88, 78),
                    painter: FieldShapePainter(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: CustomPaint(
                    size: const Size(124, 34),
                    painter: CanalLinePainter(),
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
                Text(
                  monitor.fieldName ?? '未知地块',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17211A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${monitor.cropName ?? "未知作物"} · 播种第 ${monitor.growthDays ?? 0} 天 · ${monitor.areaMu ?? 0} 亩',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5C654B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (monitor.tags != null)
                      ...monitor.tags!.map((tag) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildStatusTag(tag, 
                          tag == '需浇水' ? const Color(0xFFEEF7F5) : const Color(0xFFFFF0DC),
                          tag == '需浇水' ? const Color(0xFF315F6A) : const Color(0xFF7A3D22),
                        ),
                      )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  monitor.suggestion ?? '建议傍晚补水 18-22mm，明早复拍叶片确认氮肥需求。',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2F3A2C),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String text, Color bgColor, Color textColor) {
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

  Widget _buildDailyTasks() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final tasks = provider.dashboard?.todayTasks ?? [];
        
        return Column(
          children: [
            const Row(
              children: [
                Text(
                  '今日农事任务',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17211A),
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
            else if (tasks.isEmpty)
              Container(
                height: 100,
                alignment: Alignment.center,
                child: const Text(
                  '今日暂无任务',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C654B),
                  ),
                ),
              )
            else
              ...tasks.take(3).map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTaskCard(task),
              )),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(TodayTask task) {
    IconData icon;
    Color iconBg;
    Color iconColor;
    
    switch (task.taskType) {
      case 'WATER':
        icon = Icons.water_drop;
        iconBg = const Color(0xFF315F6A);
        iconColor = Colors.white;
        break;
      case 'FERTILIZE':
        icon = Icons.eco;
        iconBg = const Color(0xFFD7F05B);
        iconColor = const Color(0xFF17211A);
        break;
      case 'INSPECT':
        icon = Icons.camera_alt;
        iconBg = const Color(0xFF17211A);
        iconColor = Colors.white;
        break;
      default:
        icon = Icons.agriculture;
        iconBg = const Color(0xFF17211A);
        iconColor = Colors.white;
    }
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE3D2)),
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
                  task.title ?? '未知任务',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF17211A),
                  ),
                ),
                Text(
                  task.subtitle ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667158),
                  ),
                ),
              ],
            ),
          ),
          Text(
            task.priorityText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF60722C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartReminder() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF263326),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 24,
            color: Color(0xFFD7F05B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '未来 24 小时无有效降雨，系统已把缺水地块排到任务顶部。',
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

class FieldShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4F7B3A)
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = const Color(0xFFF6F8EF)
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

class CanalLinePainter extends CustomPainter {
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
