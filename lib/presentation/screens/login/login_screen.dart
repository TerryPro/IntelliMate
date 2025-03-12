import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/user.dart';
import 'package:intellimate/presentation/providers/password_provider.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreeToTerms = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFirstTimeUser = false;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTimeUser();
  }

  // 检查是否是首次使用
  Future<void> _checkIfFirstTimeUser() async {
    final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    final hasPassword = passwordProvider.hasPassword;
    
    setState(() {
      _isFirstTimeUser = !hasPassword;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 登录方法
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请阅读并同意服务条款')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        if (_isFirstTimeUser) {
          // 首次使用，设置密码
          final success = await passwordProvider.setPassword(_passwordController.text);
          if (!success) {
            throw Exception('设置密码失败');
          }
          
          // 检查是否有现有用户
          final currentUser = await userProvider.getCurrentUser();
          if (currentUser != null) {
            // 已有用户，直接登录
            await userProvider.login(currentUser.id);
          } else {
            // 没有用户，创建一个新用户
            final newUser = User(
              id: const Uuid().v4(),
              username: _nicknameController.text,
              nickname: _nicknameController.text,
              avatar: null,
              email: null,
              phone: null,
              gender: '男',
              birthday: DateTime.now().toIso8601String(),
              signature: '欢迎使用智伴！',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            await userProvider.createUser(newUser);
          }
        } else {
          // 非首次使用，验证密码
          final isPasswordCorrect = await passwordProvider.verifyPassword(_passwordController.text);
          if (!isPasswordCorrect) {
            throw Exception('密码错误');
          }
          
          // 密码正确，获取用户并登录
          final currentUser = await userProvider.getCurrentUser();
          if (currentUser != null) {
            await userProvider.login(currentUser.id);
          } else {
            throw Exception('未找到用户信息');
          }
        }
        
        if (mounted) {
          // 跳转到主页
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('登录失败：$e')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo和标题
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assistant_rounded,
                          size: 50,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '智伴',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '您的个人智能助理',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),

                
                // 登录表单
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 昵称输入框 (仅首次使用时显示)
                      if (_isFirstTimeUser)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nicknameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white70,
                                ),
                                hintText: '请输入您的昵称',
                                hintStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入昵称';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      
                      // 密码输入框
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white70,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          hintText: _isFirstTimeUser ? '请设置密码' : '请输入密码',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          if (_isFirstTimeUser && value.length < 6) {
                            return '密码长度至少为6位';
                          }
                          return null;
                        },
                      ),
                      
                      // 确认密码输入框 (仅首次使用时显示)
                      if (_isFirstTimeUser)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                hintText: '请确认密码',
                                hintStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请确认密码';
                                }
                                if (value != _passwordController.text) {
                                  return '两次输入的密码不一致';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // 登录按钮
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  _isFirstTimeUser ? '创建账户' : '登录',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 