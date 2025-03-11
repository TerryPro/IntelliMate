import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
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
                  border: Border.all(color: Colors.white, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 用户名和签名
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '小明',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '提高效率，成就更好的自己',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8 * 255),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // 编辑按钮
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.profileEdit);
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
              _buildUserStat('12', '已完成任务'),
              _buildUserStat('8', '进行中任务'),
              _buildUserStat('95%', '完成率'),
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
            color: Colors.white.withValues(alpha: 0.8 * 255),
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