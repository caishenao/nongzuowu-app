import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/api_models.dart';

/// 数据导出服务
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  /// 导出地块数据为 CSV
  Future<String> exportFieldsToCsv(List<FieldInfo> fields) async {
    final buffer = StringBuffer();
    
    // 写入表头
    buffer.writeln('地块编号,地块名称,地块类型,面积(平方米),面积(亩),周长(米),土壤类型,灌溉方式,状态');
    
    // 写入数据
    for (final field in fields) {
      buffer.writeln(
        '${field.fieldCode ?? ""},'
        '${field.fieldName},'
        '${_getFieldTypeText(field.fieldType)},'
        '${field.area ?? 0},'
        '${field.areaMu ?? 0},'
        '${field.perimeter ?? 0},'
        '${field.soilType ?? ""},'
        '${field.irrigationType ?? ""},'
        '${field.status == 1 ? "正常" : "废弃"}'
      );
    }
    
    return buffer.toString();
  }

  /// 导出作物数据为 CSV
  Future<String> exportCropsToCsv(List<CropInfo> crops) async {
    final buffer = StringBuffer();
    
    // 写入表头
    buffer.writeln('作物编号,作物名称,品种,地块,批次,播种日期,采收日期,生长阶段,生长天数,面积(亩),NDVI');
    
    // 写入数据
    for (final crop in crops) {
      buffer.writeln(
        '${crop.cropCode ?? ""},'
        '${crop.cropName},'
        '${crop.variety ?? ""},'
        '${crop.fieldName ?? ""},'
        '${crop.batchNo ?? ""},'
        '${crop.sowDate ?? ""},'
        '${crop.harvestDate ?? ""},'
        '${_getGrowthStageText(crop.growthStage)},'
        '${crop.growthDays ?? 0},'
        '${crop.plantingArea ?? 0},'
        '${crop.ndviValue ?? 0}'
      );
    }
    
    return buffer.toString();
  }

  /// 导出操作记录为 CSV
  Future<String> exportOperationsToCsv(List<FieldOperation> operations) async {
    final buffer = StringBuffer();
    
    // 写入表头
    buffer.writeln('日期,地块,操作类型,标题,详情,操作人,状态');
    
    // 写入数据
    for (final op in operations) {
      buffer.writeln(
        '${op.operationDate ?? ""},'
        '${op.fieldName ?? ""},'
        '${_getOperationTypeText(op.operationType)},'
        '${op.title},'
        '${op.detail ?? ""},'
        '${op.operatorName ?? ""},'
        '${op.status ?? "已完成"}'
      );
    }
    
    return buffer.toString();
  }

  /// 导出提醒数据为 CSV
  Future<String> exportRemindersToCsv(List<FarmingReminder> reminders) async {
    final buffer = StringBuffer();
    
    // 写入表头
    buffer.writeln('日期,地块,类型,标题,内容,优先级,是否完成,AI生成');
    
    // 写入数据
    for (final reminder in reminders) {
      buffer.writeln(
        '${reminder.remindDate ?? ""},'
        '${reminder.fieldName ?? ""},'
        '${reminder.typeText},'
        '${reminder.title},'
        '${reminder.content ?? ""},'
        '${reminder.priorityText},'
        '${reminder.isCompleted == true ? "是" : "否"},'
        '${reminder.aiGenerated == true ? "是" : "否"}'
      );
    }
    
    return buffer.toString();
  }

  /// 保存文件到本地
  Future<String> saveToFile(String content, String filename) async {
    try {
      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      
      // 写入文件
      await file.writeAsString(content, encoding: utf8);
      
      return path;
    } catch (e) {
      throw Exception('保存文件失败: $e');
    }
  }

  /// 生成带时间戳的文件名
  String generateFilename(String prefix, String extension) {
    final now = DateTime.now();
    final timestamp = '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    return '${prefix}_$timestamp.$extension';
  }

  String _pad(int number) {
    return number.toString().padLeft(2, '0');
  }

  String _getFieldTypeText(String? type) {
    switch (type) {
      case 'FARMLAND': return '耕地';
      case 'ORCHARD': return '果园';
      case 'GREENHOUSE': return '大棚';
      default: return '未知';
    }
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

  String _getOperationTypeText(String? type) {
    switch (type) {
      case 'FERTILIZE': return '施肥';
      case 'IRRIGATE': return '灌溉';
      case 'SPRAY': return '喷药';
      case 'INSPECT': return '巡检';
      case 'HARVEST': return '收获';
      default: return '其他';
    }
  }
}
