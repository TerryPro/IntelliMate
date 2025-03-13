import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/user.dart';
import 'package:intellimate/presentation/providers/password_provider.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:intellimate/data/models/user_model.dart';
import 'package:intellimate/presentation/screens/home/home_screen.dart';

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
  
  // 添加Provider引用
  late PasswordProvider _passwordProvider;
  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    // 初始化Provider
    _passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _checkIfFirstTimeUser();
  }

  // 检查是否是首次使用
  Future<void> _checkIfFirstTimeUser() async {
    final hasPassword = _passwordProvider.hasPassword;
    
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
      
      try {
        setState(() {
          _isLoading = true;
        });
  
        // 判断是否是第一次登录
        final isFirstLogin = !_passwordProvider.hasPassword;
        if (isFirstLogin) {
          // 第一次登录，设置密码
          await _passwordProvider.setPassword(_passwordController.text);
          
          // 尝试获取当前用户
          final currentUser = await _userProvider.getCurrentUser();
          
          if (currentUser == null) {
            // 创建新用户
            print('未找到现有用户，创建新用户');
            final id = const Uuid().v4();
            final now = DateTime.now();
            
            final user = UserModel(
              id: id,
              username: '用户${Random().nextInt(10000)}',
              nickname: '新用户',
              avatar: null,
              email: null,
              phone: null,
              gender: '保密',
              birthday: null,
              signature: '这个人很懒，什么都没留下',
              createdAt: now,
              updatedAt: now,
            );
            
            print('准备创建用户: $user');
            final createdUser = await _userProvider.createUser(user);
            print('用户创建结果: ${createdUser != null ? '成功' : '失败'}');
            
            if (createdUser == null) {
              throw Exception('创建用户失败，请重试');
            }
            
            // 设置为当前用户
            await _userProvider.login(createdUser.id);
            print('用户登录成功，ID: ${createdUser.id}');
            
            // 立即验证用户是否真的创建成功
            final verifiedUser = await _userProvider.getCurrentUser();
            if (verifiedUser == null) {
              throw Exception('用户创建成功，但无法获取，请重试');
            }
            print('成功验证新用户: ${verifiedUser.username}');
          } else {
            // 如果已有用户，直接登录
            print('找到现有用户: ${currentUser.username}，使用该用户登录');
            await _userProvider.login(currentUser.id);
          }
        } else {
          // 已有密码，验证密码
          final isValid = await _passwordProvider.verifyPassword(_passwordController.text);
          if (!isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('密码错误，请重试')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
          
          // 获取当前用户
          final user = await _userProvider.getCurrentUser();
          print('验证密码后获取用户: ${user?.username ?? "未找到"}');
          
          if (user == null) {
            // 如果没有找到用户，很可能是之前的数据库初始化问题
            print('未找到用户信息，可能是之前数据库初始化失败，尝试重置');
            await _passwordProvider.clearPassword();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('未找到用户信息，请重新注册')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
  
        // 登录成功，跳转到主页
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        print('登录过程中发生错误: $e');
        print('错误堆栈: ${StackTrace.current}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: ${e.toString()}')),
        );
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