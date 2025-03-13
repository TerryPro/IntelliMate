import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/user.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  
  String _gender = '男';
  DateTime _birthday = DateTime(1990, 1, 1);
  String? _avatarUrl;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  // 加载用户数据
  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.currentUser != null) {
      final user = userProvider.currentUser!;
      
      setState(() {
        _nicknameController.text = user.nickname;
        _phoneController.text = user.phone ?? '';
        _emailController.text = user.email ?? '';
        _bioController.text = user.signature ?? '';
        _gender = user.gender ?? '男';
        _birthday = user.birthday != null 
            ? DateTime.parse(user.birthday!) 
            : DateTime(1990, 1, 1);
        _avatarUrl = user.avatar;
      });
    }
  }
  
  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  // 保存个人信息
  Future<void> _saveProfile() async {
    // 表单验证
    if (_nicknameController.text.isEmpty) {
      _showErrorSnackBar('请输入昵称');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser != null) {
        // 更新现有用户
        final updatedUser = User(
          id: currentUser.id,
          username: currentUser.username,
          nickname: _nicknameController.text,
          avatar: _avatarUrl,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          gender: _gender,
          birthday: _birthday.toIso8601String(),
          signature: _bioController.text.isNotEmpty ? _bioController.text : null,
          createdAt: currentUser.createdAt,
          updatedAt: DateTime.now(),
        );
        
        final success = await userProvider.updateUser(updatedUser);
        
        if (success) {
          _showSuccessSnackBar();
          Navigator.pop(context);
        } else {
          _showErrorSnackBar('更新个人信息失败');
        }
      } else {
        // 创建新用户
        final newUser = User(
          id: const Uuid().v4(),
          username: _nicknameController.text,
          nickname: _nicknameController.text,
          avatar: _avatarUrl,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          gender: _gender,
          birthday: _birthday.toIso8601String(),
          signature: _bioController.text.isNotEmpty ? _bioController.text : null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final createdUser = await userProvider.createUser(newUser);
        
        if (createdUser != null) {
          _showSuccessSnackBar();
          Navigator.pop(context);
        } else {
          _showErrorSnackBar('创建个人信息失败');
        }
      }
    } catch (e) {
      _showErrorSnackBar('保存个人信息时发生错误: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
  
  // 显示成功提示
  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('个人信息已更新'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // 选择生日
  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _birthday) {
      setState(() {
        _birthday = picked;
      });
    }
  }
  
  // 选择头像
  Future<void> _selectAvatar() async {
    try {
      // 显示选择对话框
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('从相册选择'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('拍摄照片'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      _showErrorSnackBar('选择头像失败: $e');
    }
  }
  
  // 选择图片
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (image != null) {
        // 保存图片到应用目录
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final String savedPath = path.join(appDir.path, fileName);
        
        // 复制图片到应用目录
        final File savedImage = await File(image.path).copy(savedPath);
        
        setState(() {
          _avatarUrl = savedImage.path;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('头像已更新，点击保存完成修改'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('处理图片失败: $e');
    }
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
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 头像
                      _buildAvatarSection(),
                      
                      // 昵称
                      _buildInputField(
                        label: '昵称',
                        controller: _nicknameController,
                        icon: Icons.person,
                        hintText: '请输入昵称',
                      ),
                      
                      // 性别
                      _buildGenderSelector(),
                      
                      // 生日
                      _buildBirthdaySelector(),
                      
                      // 手机号
                      _buildInputField(
                        label: '手机号',
                        controller: _phoneController,
                        icon: Icons.phone_android,
                        hintText: '请输入手机号',
                        keyboardType: TextInputType.phone,
                      ),
                      
                      // 邮箱
                      _buildInputField(
                        label: '邮箱',
                        controller: _emailController,
                        icon: Icons.email,
                        hintText: '请输入邮箱',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      // 个性签名
                      _buildBioField(),
                      
                      // 隐私提示
                      _buildPrivacyTip(),
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
                '个人信息',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _saveProfile,
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
  
  // 构建头像部分
  Widget _buildAvatarSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _selectAvatar,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: _avatarUrl != null
                    ? DecorationImage(
                        image: _avatarUrl!.startsWith('http') 
                            ? NetworkImage(_avatarUrl!) as ImageProvider
                            : FileImage(File(_avatarUrl!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '点击修改头像',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建输入字段
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  icon,
                  color: Colors.grey,
                ),
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建性别选择器
  Widget _buildGenderSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '性别',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wc,
                  color: Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Radio<String>(
                        value: '男',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text('男'),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: '女',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text('女'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建生日选择器
  Widget _buildBirthdaySelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '生日',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectBirthday,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cake,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_birthday.year}年${_birthday.month}月${_birthday.day}日',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建个性签名字段
  Widget _buildBioField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '个性签名',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(
                    Icons.edit,
                    color: Colors.grey,
                  ),
                ),
                hintText: '填写个性签名',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建隐私提示
  Widget _buildPrivacyTip() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '个人信息存储说明',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '您的个人信息仅存储在本地设备，不会上传至任何服务器。请确保定期备份您的数据，以防数据丢失。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 