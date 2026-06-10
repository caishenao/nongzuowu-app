import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = StorageService();
  
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _serverUrl = 'http://localhost:8080/api';
  String _language = 'zh_CN';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 加载设置
  void _loadSettings() {
    setState(() {
      _darkMode = _storage.isDarkMode();
      _notificationsEnabled = _storage.isNotificationEnabled();
      _serverUrl = _storage.getServerUrl() ?? 'http://localhost:8080/api';
      _language = _storage.getLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: const Color(0xFF1B3A28),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // 服务器设置
          _buildSection(
            title: '服务器设置',
            children: [
              _buildServerUrlTile(),
            ],
          ),

          // 显示设置
          _buildSection(
            title: '显示设置',
            children: [
              _buildDarkModeTile(),
              _buildLanguageTile(),
            ],
          ),

          // 通知设置
          _buildSection(
            title: '通知设置',
            children: [
              _buildNotificationTile(),
            ],
          ),

          // 数据管理
          _buildSection(
            title: '数据管理',
            children: [
              _buildCacheTile(),
              _buildExportTile(),
            ],
          ),

          // 关于
          _buildSection(
            title: '关于',
            children: [
              _buildVersionTile(),
              _buildFeedbackTile(),
            ],
          ),

          // 退出登录
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '退出登录',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A6B52),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD7E2D1)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildServerUrlTile() {
    return ListTile(
      leading: const Icon(Icons.dns, color: Color(0xFF1B3A28)),
      title: const Text('服务器地址'),
      subtitle: Text(
        _serverUrl,
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showServerUrlDialog(),
    );
  }

  Widget _buildDarkModeTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode, color: Color(0xFF1B3A28)),
      title: const Text('深色模式'),
      subtitle: const Text('切换应用主题'),
      value: _darkMode,
      activeColor: const Color(0xFF1B3A28),
      onChanged: (value) async {
        await _storage.setDarkMode(value);
        setState(() {
          _darkMode = value;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(value ? '已切换到深色模式' : '已切换到浅色模式')),
          );
        }
      },
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      leading: const Icon(Icons.language, color: Color(0xFF1B3A28)),
      title: const Text('语言'),
      subtitle: Text(_language == 'zh_CN' ? '简体中文' : 'English'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(),
    );
  }

  Widget _buildNotificationTile() {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications, color: Color(0xFF1B3A28)),
      title: const Text('通知提醒'),
      subtitle: const Text('接收农事提醒通知'),
      value: _notificationsEnabled,
      activeColor: const Color(0xFF1B3A28),
      onChanged: (value) async {
        await _storage.setNotificationEnabled(value);
        setState(() {
          _notificationsEnabled = value;
        });
      },
    );
  }

  Widget _buildCacheTile() {
    return ListTile(
      leading: const Icon(Icons.cleaning_services, color: Color(0xFF1B3A28)),
      title: const Text('清除缓存'),
      subtitle: const Text('清除本地缓存数据'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showClearCacheDialog(),
    );
  }

  Widget _buildExportTile() {
    return ListTile(
      leading: const Icon(Icons.upload_file, color: Color(0xFF1B3A28)),
      title: const Text('导出数据'),
      subtitle: const Text('导出农业数据到文件'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据导出功能开发中...')),
        );
      },
    );
  }

  Widget _buildVersionTile() {
    return const ListTile(
      leading: Icon(Icons.info_outline, color: Color(0xFF1B3A28)),
      title: Text('版本'),
      subtitle: Text('v1.0.0'),
    );
  }

  Widget _buildFeedbackTile() {
    return ListTile(
      leading: const Icon(Icons.feedback, color: Color(0xFF1B3A28)),
      title: const Text('意见反馈'),
      subtitle: const Text('帮助我们改进应用'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('反馈功能开发中...')),
        );
      },
    );
  }

  /// 显示服务器地址对话框
  void _showServerUrlDialog() {
    final controller = TextEditingController(text: _serverUrl);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置服务器地址'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '服务器地址',
            hintText: 'http://localhost:8080/api',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                await _storage.setServerUrl(url);
                setState(() {
                  _serverUrl = url;
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('服务器地址已更新')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3A28),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('简体中文'),
              value: 'zh_CN',
              groupValue: _language,
              activeColor: const Color(0xFF1B3A28),
              onChanged: (value) async {
                if (value != null) {
                  await _storage.setLanguage(value);
                  setState(() {
                    _language = value;
                  });
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en_US',
              groupValue: _language,
              activeColor: const Color(0xFF1B3A28),
              onChanged: (value) async {
                if (value != null) {
                  await _storage.setLanguage(value);
                  setState(() {
                    _language = value;
                  });
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示清除缓存对话框
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有本地缓存数据吗？这不会影响您的账号信息。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 保留用户信息，清除其他缓存
              final token = _storage.getToken();
              final userInfo = _storage.getUserInfo();
              await _storage.clear();
              if (token != null) await _storage.setToken(token);
              if (userInfo != null) await _storage.setUserInfo(userInfo);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示退出登录对话框
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storage.clearUserData();
              if (mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
