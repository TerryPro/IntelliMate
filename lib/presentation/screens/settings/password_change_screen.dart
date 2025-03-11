import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  String _passwordStrength = '中';
  double _strengthLevel = 2; // 1-弱, 2-中, 3-强
  
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  // 检查密码强度
  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthLevel = 0;
      });
      return;
    }
    
    // 简单的密码强度检查逻辑
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;
    
    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;
    if (hasMinLength) strength++;
    
    setState(() {
      if (strength <= 2) {
        _passwordStrength = '弱';
        _strengthLevel = 1;
      } else if (strength <= 4) {
        _passwordStrength = '中';
        _strengthLevel = 2;
      } else {
        _passwordStrength = '强';
        _strengthLevel = 3;
      }
    });
  }
  
  // 保存密码
  void _savePassword() {
    // 表单验证
    if (_currentPasswordController.text.isEmpty) {
      _showErrorSnackBar('请输入当前密码');
      return;
    }
    
    if (_newPasswordController.text.isEmpty) {
      _showErrorSnackBar('请输入新密码');
      return;
    }
    
    if (_confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('请确认新密码');
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('两次输入的密码不一致');
      return;
    }
    
    // 密码强度检查
    if (_strengthLevel < 2) {
      _showErrorSnackBar('密码强度太弱，请设置更复杂的密码');
      return;
    }
    
    // 模拟密码修改成功
    _showSuccessDialog();
  }
  
  // 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  // 显示成功对话框
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改成功'),
        content: const Text('密码已成功修改，请使用新密码登录'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回设置页面
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
          // 主体内容
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 安全图标
                    _buildSecurityIcon(),
                    
                    // 当前密码
                    _buildPasswordField(
                      label: '当前密码',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      icon: Icons.key,
                      onToggleObscure: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                    
                    // 新密码
                    _buildPasswordField(
                      label: '新密码',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      icon: Icons.lock,
                      onToggleObscure: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                      onChanged: _checkPasswordStrength,
                      showStrength: true,
                    ),
                    
                    // 确认新密码
                    _buildPasswordField(
                      label: '确认新密码',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      icon: Icons.lock,
                      onToggleObscure: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    
                    // 密码要求提示
                    _buildPasswordRequirements(),
                    
                    // 忘记密码
                    _buildForgotPassword(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建自定义顶部导航栏
  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.home);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '修改密码',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _savePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '保存',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建安全图标
  Widget _buildSecurityIcon() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock,
            color: AppColors.primary,
            size: 40,
          ),
        ),
        const Text(
          '设置新密码',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 32),
          child: Text(
            '为了保障您的账号安全，请定期修改密码',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  // 构建密码输入框
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required IconData icon,
    required VoidCallback onToggleObscure,
    Function(String)? onChanged,
    bool showStrength = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscureText,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: '请输入${label.toLowerCase()}',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          if (showStrength && _passwordStrength.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '密码强度：',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _passwordStrength,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStrengthColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _strengthLevel >= 1 ? Colors.green : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _strengthLevel >= 2 ? Colors.amber : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: _strengthLevel >= 3 ? Colors.red : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  // 获取密码强度颜色
  Color _getStrengthColor() {
    switch (_strengthLevel) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // 构建密码要求提示
  Widget _buildPasswordRequirements() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '密码要求：',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                _buildRequirementItem('长度至少8个字符'),
                _buildRequirementItem('包含至少一个大写字母'),
                _buildRequirementItem('包含至少一个小写字母'),
                _buildRequirementItem('包含至少一个数字'),
                _buildRequirementItem('包含至少一个特殊字符'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建密码要求项
  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建忘记密码
  Widget _buildForgotPassword() {
    return Center(
      child: TextButton(
        onPressed: () {
          // 忘记密码逻辑
        },
        child: const Text(
          '忘记密码？',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 