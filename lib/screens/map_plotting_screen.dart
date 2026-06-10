import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/common_widgets.dart';

class MapPlottingScreen extends StatefulWidget {
  const MapPlottingScreen({super.key});

  @override
  State<MapPlottingScreen> createState() => _MapPlottingScreenState();
}

class _MapPlottingScreenState extends State<MapPlottingScreen> {
  bool _isSatelliteView = false;
  String _fieldName = '西坡 3 号玉米地';
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  // 地图控制器
  final MapController _mapController = MapController();

  // 边界点列表
  final List<LatLng> _boundaryPoints = [];

  // 中心点（默认北京附近农田区域）
  LatLng _center = const LatLng(39.9042, 116.4074);
  double _zoom = 15.0;

  // 计算结果
  double _areaSqm = 0;
  double _areaMu = 0;
  double _perimeter = 0;

  @override
  void initState() {
    super.initState();
    _nameController.text = _fieldName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      child: Column(
        children: [
          const StatusBarWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildMapArea(),
                  const SizedBox(height: 14),
                  _buildAreaCalculation(),
                  const SizedBox(height: 14),
                  _buildActionPanel(),
                ],
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
              '地图圈地',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '点击地图添加边界点，自动计算面积',
              style: AppTextStyles.subtitle,
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSatelliteView = !_isSatelliteView;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSatelliteView ? Icons.map : Icons.satellite_alt,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  _isSatelliteView ? '地图' : '卫星',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapArea() {
    return Expanded(
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Stack(
          children: [
            // FlutterMap 地图
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
                onTap: (tapPosition, point) {
                  _addBoundaryPoint(point);
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _center = position.center ?? _center;
                      _zoom = position.zoom ?? _zoom;
                    });
                  }
                },
              ),
              children: [
                // 地图瓦片层
                TileLayer(
                  urlTemplate: _isSatelliteView
                      ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.nongzuowu_app',
                  maxZoom: 19,
                ),
                // 多边形层 - 绘制边界
                if (_boundaryPoints.length >= 3)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _boundaryPoints,
                        color: const Color(0x552D5E3A),
                        borderColor: AppColors.border,
                        borderStrokeWidth: 3,
                        isFilled: true,
                      ),
                    ],
                  ),
                // 标记层 - 边界点
                MarkerLayer(
                  markers: _boundaryPoints.asMap().entries.map((entry) {
                    return Marker(
                      point: entry.value,
                      width: 24,
                      height: 24,
                      child: GestureDetector(
                        onLongPress: () {
                          _removeBoundaryPoint(entry.key);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // 线段层 - 连接点的线
                if (_boundaryPoints.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _boundaryPoints,
                        color: AppColors.border,
                        strokeWidth: 3,
                      ),
                    ],
                  ),
              ],
            ),

            // 正在描绘标签
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _boundaryPoints.isEmpty ? '点击地图添加点' : '正在描绘边界',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 撤销按钮
            Positioned(
              right: 16,
              top: 16,
              child: GestureDetector(
                onTap: _undoLastPoint,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.13),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.undo, size: 20, color: AppColors.primaryDark),
                ),
              ),
            ),

            // 清除按钮
            if (_boundaryPoints.isNotEmpty)
              Positioned(
                right: 16,
                top: 66,
                child: GestureDetector(
                  onTap: _clearAllPoints,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.13),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  ),
                ),
              ),

            // 当前点标签
            if (_boundaryPoints.isNotEmpty)
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_boundaryPoints.length} 个边界点',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (_boundaryPoints.length < 3)
                        const Text(
                          '至少需要 3 个点',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.warning,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // 比例尺
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildScaleBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleBar() {
    // 根据缩放级别估算比例尺
    double metersPerPixel = 156543.03392 * cos(_center.latitude * pi / 180) / pow(2, _zoom);
    double scaleWidth = 100; // 像素宽度
    double scaleMeters = metersPerPixel * scaleWidth;

    String scaleText;
    if (scaleMeters >= 1000) {
      scaleText = '${(scaleMeters / 1000).toStringAsFixed(1)} km';
    } else {
      scaleText = '${scaleMeters.round()} m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgLight.withOpacity(0.9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: scaleWidth / 2,
            height: 3,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            scaleText,
            style: const TextStyle(
              fontFamily: 'Geist Mono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCalculation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildMetricCell('实测面积', _formatNumber(_areaSqm), 'm²', hasRightBorder: true),
              _buildMetricCell('换算亩数', _areaMu.toStringAsFixed(2), '亩', hasRightBorder: true),
              _buildMetricCell('边界周长', _perimeter.round().toString(), 'm'),
            ],
          ),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 亩 = 666.67 m²',
                  style: TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'GPS 精度 ±3m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double number) {
    if (number == 0) return '0';
    if (number >= 1000) {
      return number.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return number.toStringAsFixed(1);
  }

  Widget _buildMetricCell(String label, String value, String unit, {bool hasRightBorder = false}) {
    return Expanded(
      child: Container(
        height: 86,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            right: hasRightBorder ? const BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Geist Mono',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Column(
      children: [
        // 地块名称输入
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _isEditingName
                    ? TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _fieldName = value;
                            _isEditingName = false;
                          });
                        },
                      )
                    : Text(
                        _fieldName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditingName = !_isEditingName;
                  });
                },
                child: Icon(
                  _isEditingName ? Icons.check : Icons.edit,
                  size: 17,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 保存按钮
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _boundaryPoints.length >= 3 ? _saveField : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _boundaryPoints.length >= 3
                  ? AppColors.primaryDark
                  : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.save,
                  size: 20,
                  color: _boundaryPoints.length >= 3 ? Colors.white : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  '保存地块',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _boundaryPoints.length >= 3 ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 添加边界点
  void _addBoundaryPoint(LatLng point) {
    setState(() {
      _boundaryPoints.add(point);
      _calculateAreaAndPerimeter();
    });
  }

  // 移除指定边界点
  void _removeBoundaryPoint(int index) {
    setState(() {
      _boundaryPoints.removeAt(index);
      _calculateAreaAndPerimeter();
    });
  }

  // 撤销最后一个点
  void _undoLastPoint() {
    if (_boundaryPoints.isNotEmpty) {
      setState(() {
        _boundaryPoints.removeLast();
        _calculateAreaAndPerimeter();
      });
    }
  }

  // 清除所有点
  void _clearAllPoints() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有边界点吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _boundaryPoints.clear();
                _areaSqm = 0;
                _areaMu = 0;
                _perimeter = 0;
              });
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 计算面积和周长
  void _calculateAreaAndPerimeter() {
    if (_boundaryPoints.length < 3) {
      _areaSqm = 0;
      _areaMu = 0;
      _perimeter = 0;
      return;
    }

    // 使用 Shoelace 公式计算面积
    _areaSqm = _calculatePolygonArea(_boundaryPoints);
    _areaMu = _areaSqm / 666.67;

    // 计算周长
    _perimeter = _calculatePerimeter(_boundaryPoints);
  }

  // Shoelace 公式计算多边形面积（返回平方米）
  double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0;

    double area = 0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += points[i].longitude * points[j].latitude;
      area -= points[j].longitude * points[i].latitude;
    }

    area = area.abs() / 2;

    // 将经纬度面积转换为平方米
    // 1 度纬度 ≈ 111319.9 米
    // 1 度经度 ≈ 111319.9 * cos(纬度) 米
    double latRad = points[0].latitude * pi / 180;
    double metersPerDegreeLat = 111319.9;
    double metersPerDegreeLng = 111319.9 * cos(latRad);

    area = area * metersPerDegreeLat * metersPerDegreeLng;

    return area;
  }

  // 计算周长（返回米）
  _calculatePerimeter(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    double perimeter = 0;
    int n = points.length;

    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      perimeter += _calculateDistance(points[i], points[j]);
    }

    return perimeter;
  }

  // 计算两点间距离（米）
  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371000; // 地球半径（米）

    double lat1 = p1.latitude * pi / 180;
    double lat2 = p2.latitude * pi / 180;
    double dLat = (p2.latitude - p1.latitude) * pi / 180;
    double dLng = (p2.longitude - p1.longitude) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // 保存地块
  void _saveField() {
    if (_boundaryPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少需要 3 个边界点才能保存')),
      );
      return;
    }

    // 这里可以添加保存逻辑
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('地块名称: $_fieldName'),
            Text('面积: ${_areaSqm.toStringAsFixed(1)} m² (${_areaMu.toStringAsFixed(2)} 亩)'),
            Text('周长: ${_perimeter.toStringAsFixed(1)} m'),
            Text('边界点数: ${_boundaryPoints.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
