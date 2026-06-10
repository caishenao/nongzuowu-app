import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class AiRecognitionScreen extends StatelessWidget {
  const AiRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      child: Column(
        children: [
          const StatusBarWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCameraHero(),
                    const SizedBox(height: 12),
                    _buildRecognitionSummary(),
                    const SizedBox(height: 12),
                    _buildGrowthDataGrid(),
                    const SizedBox(height: 12),
                    _buildProblemDiagnosis(),
                    const SizedBox(height: 12),
                    _buildAiAdvice(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraHero() {
    return Container(
      height: 188,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // 标题文字
          Positioned(
            left: 18, top: 16,
            child: Text(
              'AI 长势识别',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCFE8B8),
              ),
            ),
          ),
          Positioned(
            left: 18, top: 42,
            child: SizedBox(
              width: 158,
              child: Text(
                '拍照判断作物长势',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.05,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18, top: 104,
            child: SizedBox(
              width: 154,
              child: Text(
                '对准叶片或整株，AI 自动识别旺长、缺水、病斑和肥力状态。',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFDDE9D4),
                  height: 1.35,
                ),
              ),
            ),
          ),
          // 作物扫描预览区
          Positioned(
            right: 18, top: 18,
            child: Container(
              width: 142,
              height: 142,
              color: const Color(0xFF2D5E3A),
              child: Stack(
                children: [
                  // 扫描框
                  Positioned(
                    left: 20, top: 18,
                    child: Container(
                      width: 86,
                      height: 2,
                      color: const Color(0xFFCFE8B8),
                    ),
                  ),
                  Positioned(
                    left: 20, top: 18,
                    child: Container(
                      width: 2,
                      height: 86,
                      color: const Color(0xFFCFE8B8),
                    ),
                  ),
                  Positioned(
                    left: 20, bottom: 18,
                    child: Container(
                      width: 86,
                      height: 2,
                      color: const Color(0xFFCFE8B8),
                    ),
                  ),
                  Positioned(
                    right: 18, top: 18,
                    child: Container(
                      width: 2,
                      height: 86,
                      color: const Color(0xFFCFE8B8),
                    ),
                  ),
                  // 中心图标
                  Center(
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: const Color(0xFF4A8B5C).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 开始拍照按钮
          Positioned(
            left: 18, bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFCFE8B8),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 7),
                  const Text(
                    '开始拍照',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionSummary() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _buildSummaryItem('识别作物', '玉米', hasRightBorder: true),
          _buildSummaryItem('置信度', '96%', hasRightBorder: true),
          _buildSummaryItem('生育期', '拔节期'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool hasRightBorder = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: hasRightBorder ? BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMedium,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthDataGrid() {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildGrowthMetric('82', '长势评分', hasRightBorder: true),
          _buildGrowthMetric('高', '叶绿素', hasRightBorder: true),
          _buildGrowthMetric('中', '缺水风险', hasRightBorder: true),
          _buildGrowthMetric('12%', '病斑概率'),
        ],
      ),
    );
  }

  Widget _buildGrowthMetric(String value, String label, {bool hasRightBorder = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            right: hasRightBorder ? BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFFD9E7CF),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemDiagnosis() {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '问题诊断',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '轻度预警',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '叶尖轻微卷曲，土壤表层偏干；未发现明显虫害，局部叶色偏浅可能与氮肥吸收不足有关。',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAdvice() {
    return Container(
      height: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0DC),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI 建议',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildAdviceItem(Icons.water_drop, '今日傍晚补水 18-22mm'),
          const SizedBox(height: 6),
          _buildAdviceItem(Icons.sprout, '48 小时内追施氮肥 6kg/亩'),
          const SizedBox(height: 6),
          _buildAdviceItem(Icons.center_focus_strong, '三天后复拍同一地块对比'),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textDark),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
