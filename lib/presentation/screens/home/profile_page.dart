import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 用户信息
  String _username = '未登录用户';
  String _bio = '';
  String? _avatarUrl;
  bool _isLoading = true;
  
  // 统计数据
  String _completedTasks = '0';
  String _inProgressTasks = '0';
  String _completionRate = '0%';

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
          _bio = user.signature ?? '暂无个性签名';
          _avatarUrl = user.avatar;
          
          // 这里可以加载任务统计数据
          // 暂时使用模拟数据
          _completedTasks = '12';
          _inProgressTasks = '8';
          _completionRate = '95%';
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
  
  // 获取头像图片
  ImageProvider _getAvatarImage(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return FileImage(File(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 顶部用户信息区域
                _buildUserHeader(context),
                
                // 主体内容
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // 我的功能区
                          _buildFunctionSection(context),
                          
                          // 设置区域
                          _buildSettingsSection(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
  
  // 构建顶部用户信息区域
  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // 用户基本信息
          Row(
            children: [
              // 头像
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.white, width: 2),
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
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 20),
              // 用户名和签名
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bio,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 编辑按钮
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profileEdit).then((_) => _loadUserData());
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 用户数据统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildUserStat(_completedTasks, '已完成任务'),
              _buildUserStat(_inProgressTasks, '进行中任务'),
              _buildUserStat(_completionRate, '完成率'),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建用户统计项
  Widget _buildUserStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  // 构建功能区
  Widget _buildFunctionSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '我的功能',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFunctionItem(
                context,
                icon: Icons.favorite,
                label: '我的收藏',
                color: Colors.red,
                onTap: () {},
              ),
              _buildFunctionItem(
                context,
                icon: Icons.history,
                label: '浏览历史',
                color: Colors.blue,
                onTap: () {},
              ),
              _buildFunctionItem(
                context,
                icon: Icons.star,
                label: '我的评价',
                color: Colors.amber,
                onTap: () {},
              ),
              _buildFunctionItem(
                context,
                icon: Icons.download,
                label: '我的下载',
                color: Colors.green,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建功能项
  Widget _buildFunctionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1 * 255),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建设置区域
  Widget _buildSettingsSection(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          _buildSettingItem(
            context,
            icon: Icons.settings,
            title: '系统设置',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.help,
            title: '帮助与反馈',
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            icon: Icons.info,
            title: '关于我们',
            onTap: () {},
          ),
          _buildSettingItem(
            context,
            icon: Icons.share,
            title: '分享应用',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ),
    );
  }
  
  // 构建设置项
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
        if (showDivider)
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
      ],
    );
  }
} 