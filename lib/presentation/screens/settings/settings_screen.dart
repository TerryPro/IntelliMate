import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'debug_info_screen.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 用户信息
  String _username = '未登录用户';
  String _phone = '';
  String _bio = '';
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 加载用户数据
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;

      if (user != null) {
        setState(() {
          _username = user.nickname;
          _phone = user.phone ?? '';
          _bio = user.signature ?? '';
          _avatarUrl = user.avatar;
        });
      }
    } catch (e) {
      debugPrint('加载用户数据失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 用户信息卡片
                          _buildUserInfoCard(),

                          // 基础设置
                          _buildSettingSection('基础设置', [
                            _buildSettingItem(
                              icon: Icons.person,
                              title: '个人信息',
                              onTap: () => Navigator.pushNamed(
                                      context, AppRoutes.profileEdit)
                                  .then((_) => _loadUserData()),
                            ),
                            _buildSettingItem(
                              icon: Icons.lock,
                              title: '密码修改',
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.passwordChange),
                            ),
                            _buildSettingItem(
                              icon: Icons.notifications,
                              title: '通知设置',
                              onTap: () {},
                            ),
                          ]),

                          // 数据管理
                          _buildSettingSection('数据管理', [
                            _buildSettingItem(
                              icon: Icons.file_upload,
                              title: '数据导入导出',
                              onTap: () {},
                            ),
                            _buildSettingItem(
                              icon: Icons.cloud_upload,
                              title: '数据备份',
                              subtitle: '自动备份已开启',
                              onTap: () {},
                            ),
                          ]),

                          // 系统信息
                          _buildSettingSection('系统信息', [
                            _buildSettingItem(
                              icon: Icons.storage,
                              title: '存储空间',
                              subtitle: '已用 45MB/1GB',
                              onTap: () {},
                            ),
                            _buildSettingItem(
                              icon: Icons.delete,
                              title: '缓存管理',
                              subtitle: '12MB',
                              onTap: () {},
                            ),
                            _buildSettingItem(
                              icon: Icons.info,
                              title: '版本信息',
                              subtitle: 'v2.1.0',
                              onTap: () {},
                            ),
                            _buildSettingItem(
                              icon: Icons.bug_report,
                              title: '调试信息',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DebugInfoScreen(),
                                  ),
                                );
                              },
                            ),
                          ]),

                          // 账号安全
                          _buildSettingSection('账号安全', [
                            _buildSettingItem(
                              icon: Icons.security,
                              title: '隐私设置',
                              onTap: () {},
                            ),
                            _buildSettingItem(
                              icon: Icons.person_off,
                              title: '账号注销',
                              onTap: () {},
                            ),
                          ]),

                          // 退出登录按钮
                          _buildLogoutButton(),
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
              const Text(
                '系统设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              image: _avatarUrl != null
                  ? DecorationImage(
                      image: _getAvatarImage(_avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _avatarUrl == null
                ? const Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 24,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // 获取头像图片
  ImageProvider _getAvatarImage(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return FileImage(File(url));
    }
  }

  // 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.profileEdit)
          .then((_) => _loadUserData()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackWithOpacity05,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: _avatarUrl != null
                    ? DecorationImage(
                        image: _getAvatarImage(_avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.grey,
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_phone.isNotEmpty)
                    Text(
                      _phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (_bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _bio,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // 构建设置分区
  Widget _buildSettingSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.blackWithOpacity05,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  // 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade100,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade300,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // 构建退出登录按钮
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 退出登录逻辑
          _showLogoutConfirmDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
        ),
        child: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 显示退出登录确认对话框
  void _showLogoutConfirmDialog() {
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
          TextButton(
            onPressed: () {
              // 执行退出登录操作
              Navigator.pop(context);
              // 返回登录页面
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
