import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/common_widgets.dart';

/// 登录页面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = StorageService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 加载保存的凭据
  void _loadSavedCredentials() {
    final savedUsername = _storage.getString('saved_username');
    final rememberMe = _storage.getBool('remember_me') ?? false;
    
    if (savedUsername != null && rememberMe) {
      _usernameController.text = savedUsername;
      _rememberMe = true;
    }
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟登录请求
      await Future.delayed(const Duration(seconds: 2));

      // 模拟登录成功
      final username = _usernameController.text;
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // 保存用户信息
      await _storage.setToken(token);
      await _storage.setUserInfo({
        'userId': '1',
        'username': username,
        'realName': username == 'admin' ? '管理员' : username,
        'phone': '13800138000',
        'email': '$username@example.com',
      });

      // 保存凭据（如果勾选了记住我）
      if (_rememberMe) {
        await _storage.setString('saved_username', username);
        await _storage.setBool('remember_me', true);
      } else {
        await _storage.remove('saved_username');
        await _storage.setBool('remember_me', false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登录成功'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 返回上一页或跳转到主页
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('登录失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo 和标题
                  _buildHeader(),
                  const SizedBox(height: 48),
                  
                  // 用户名输入框
                  _buildUsernameField(),
                  const SizedBox(height: 16),
                  
                  // 密码输入框
                  _buildPasswordField(),
                  const SizedBox(height: 8),
                  
                  // 记住我
                  _buildRememberMe(),
                  const SizedBox(height: 32),
                  
                  // 登录按钮
                  _buildLoginButton(),
                  const SizedBox(height: 16),
                  
                  // 注册链接
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF1B3A28),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.agriculture,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        
        // 标题
        const Text(
          '农业管理系统',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B3A28),
          ),
        ),
        const SizedBox(height: 8),
        
        // 副标题
        Text(
          '智能农业 · 科学种植',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: '用户名',
        hintText: '请输入用户名',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入用户名';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: '密码',
        hintText: '请输入密码',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入密码';
        }
        if (value.length < 6) {
          return '密码长度不能少于6位';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: const Color(0xFF1B3A28),
        ),
        const Text(
          '记住我',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF4A6B52),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: 实现忘记密码功能
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请联系管理员重置密码')),
            );
          },
          child: const Text(
            '忘记密码？',
            style: TextStyle(
              color: Color(0xFF1B3A28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B3A28),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                '登 录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: 跳转到注册页面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('注册功能开发中...')),
            );
          },
          child: const Text(
            '立即注册',
            style: TextStyle(
              color: Color(0xFF1B3A28),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
