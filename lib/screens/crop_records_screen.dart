import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nong_providers.dart';
import '../models/api_models.dart';
import '../widgets/common_widgets.dart';

class CropRecordsScreen extends StatefulWidget {
  const CropRecordsScreen({super.key});

  @override
  State<CropRecordsScreen> createState() => _CropRecordsScreenState();
}

class _CropRecordsScreenState extends State<CropRecordsScreen> {
  @override
  void initState() {
    super.initState();
    // 加载作物数据
    Future.microtask(() {
      context.read<CropProvider>().loadCrops();
      context.read<OperationProvider>().loadOperations();
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
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 10),
                    _buildCropSummaryCard(),
                    const SizedBox(height: 10),
                    _buildCoreDataGrid(),
                    const SizedBox(height: 10),
                    _buildCropRecordTable(),
                    const SizedBox(height: 10),
                    _buildFieldOperationRecords(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '作物档案',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3322),
              ),
            ),
            const SizedBox(height: 4),
            Consumer<CropProvider>(
              builder: (context, provider, child) {
                final crop = provider.crops.isNotEmpty ? provider.crops.first : null;
                return Text(
                  crop != null ? '${crop.fieldName ?? "未知地块"} · ${crop.plantingArea ?? 0} 亩' : '暂无作物数据',
                  style: const TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 11,
                    color: Color(0xFF6B7B6B),
                  ),
                );
              },
            ),
          ],
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF1E3322),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 22, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildCropSummaryCard() {
    return Consumer<CropProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Container(
            height: 162,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3322),
              borderRadius: BorderRadius.circular(0),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final crop = provider.crops.isNotEmpty ? provider.crops.first : null;
        if (crop == null) {
          return Container(
            height: 162,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3322),
              borderRadius: BorderRadius.circular(0),
            ),
            child: const Center(
              child: Text(
                '暂无作物数据',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Container(
          height: 162,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3322),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Stack(
            children: [
              // 作物编号
              Positioned(
                left: 18, top: 18,
                child: Text(
                  crop.cropCode ?? 'CROP-2026-001',
                  style: const TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 11,
                    color: Color(0xFFBFD0BE),
                  ),
                ),
              ),
              // 作物名称
              Positioned(
                left: 18, top: 42,
                child: Text(
                  crop.cropName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              // 品种说明
              Positioned(
                left: 18, top: 82,
                child: SizedBox(
                  width: 170,
                  child: Text(
                    '${crop.variety ?? "未知品种"} · 批次 ${crop.batchNo ?? "01"} · 连作风险低',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFDDE8D6),
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              // 作物影像占位
              Positioned(
                right: 18, top: 18,
                child: Container(
                  width: 138,
                  height: 108,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6B3F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.grass,
                    size: 40,
                    color: Color(0xFF4A8B5C),
                  ),
                ),
              ),
              // 生长阶段标签
              Positioned(
                left: 18, bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: const Color(0xFF2D6B3F),
                  child: Text(
                    '${_getGrowthStageText(crop.growthStage)} · 第 ${crop.growthDays ?? 0} 天',
                    style: const TextStyle(
                      fontFamily: 'Geist Mono',
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // 健康指数
              Positioned(
                right: 24, bottom: 22,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6B3F),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NDVI ${crop.ndviValue ?? 0.0}',
                    style: const TextStyle(
                      fontFamily: 'Geist Mono',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGrowthStageText(String? stage) {
    switch (stage) {
      case 'SEEDLING': return '苗期';
      case 'TILLERING': return '分蘖期';
      case 'JOINTING': return '拔节期';
      case 'HEADING': return '抽穗期';
      case 'FILLING': return '灌浆期';
      case 'MATURE': return '成熟期';
      default: return '未知';
    }
  }

  Widget _buildCoreDataGrid() {
    return Consumer<CropProvider>(
      builder: (context, provider, child) {
        final crop = provider.crops.isNotEmpty ? provider.crops.first : null;
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2D6B3F),
            border: Border.all(color: const Color(0xFF1E3322)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildDataCell('开始耕种', crop?.sowDate ?? '未知', hasRightBorder: true, hasBottomBorder: true),
                  _buildDataCell('播种面积', '${crop?.plantingArea ?? 0} 亩', hasRightBorder: false, hasBottomBorder: true),
                ],
              ),
              Row(
                children: [
                  _buildDataCell('生长阶段', _getGrowthStageText(crop?.growthStage), hasRightBorder: true, hasBottomBorder: false),
                  _buildDataCell('预计采收', crop?.harvestDate ?? '未知', hasRightBorder: false, hasBottomBorder: false),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataCell(String label, String value, {required bool hasRightBorder, required bool hasBottomBorder}) {
    return Expanded(
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            right: hasRightBorder ? const BorderSide(color: Color(0xFF1E3322)) : BorderSide.none,
            bottom: hasBottomBorder ? const BorderSide(color: Color(0xFF1E3322)) : BorderSide.none,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFDDE8D6),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropRecordTable() {
    return Consumer<CropProvider>(
      builder: (context, provider, child) {
        final crop = provider.crops.isNotEmpty ? provider.crops.first : null;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '地块作物记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3322),
                  ),
                ),
                Text(
                  '当前批次',
                  style: TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 10,
                    color: const Color(0xFF2D6B3F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD7E2D1)),
              ),
              child: Column(
                children: [
                  _buildRecordRow('地块', crop?.fieldName ?? '未知地块', '墒情 67%'),
                  _buildRecordRow('品种', crop?.variety ?? '未知品种', crop?.batchNo ?? 'MZ-04'),
                  _buildRecordRow('负责人', '李文青', '2 天/次'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordRow(String label, String value, String note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 30,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD7E2D1))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7B6B),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3322),
            ),
          ),
          const Spacer(),
          Text(
            note,
            style: const TextStyle(
              fontFamily: 'Geist Mono',
              fontSize: 10,
              color: Color(0xFF6B7B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldOperationRecords() {
    return Consumer<OperationProvider>(
      builder: (context, provider, child) {
        final operations = provider.operations.take(3).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '田间操作记录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3322),
                  ),
                ),
                Text(
                  '近7天 ${operations.length}条',
                  style: const TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 10,
                    color: Color(0xFF6B7B6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD7E2D1)),
              ),
              child: operations.isEmpty
                  ? Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: const Text(
                        '暂无操作记录',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7B6B),
                        ),
                      ),
                    )
                  : Column(
                      children: operations.map((op) => _buildOperationRow(op)).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOperationRow(FieldOperation op) {
    final date = op.operationDate ?? '';
    final dateShort = date.length >= 10 ? date.substring(5, 10) : date;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 43,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD7E2D1))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              dateShort,
              style: TextStyle(
                fontFamily: 'Geist Mono',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D6B3F),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  op.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3322),
                  ),
                ),
                Text(
                  op.detail ?? '',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7B6B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            op.status ?? '已完成',
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF2D6B3F),
            ),
          ),
        ],
      ),
    );
  }
}
