import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 加载数据
  Future<void> _loadData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 顶部栏
          _buildHeader(),

          // 内容区域 - 用Expanded包裹确保滚动区域能够填满剩余空间
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 快捷操作
                    _buildQuickActions(),

                    const SizedBox(height: 32),

                    // 功能模块
                    _buildModules(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建顶部栏
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      color: const Color(0xFF3ECABB), // primary-400
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '我的助理',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              // 跳转到个人信息页面
              Navigator.pushNamed(context, AppRoutes.profileEdit);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=80&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // 加载失败时显示备用图标
                    return const Icon(
                      Icons.person,
                      color: Color(0xFF3ECABB),
                      size: 24,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建快捷操作
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.flash_on, // 快捷操作的图标
              color: Color(0xFF3ECABB), // primary-400
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // text-gray-800
              ),
            ),
          ],
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            _buildQuickActionItem(
              icon: FontAwesomeIcons.pen,
              label: '点滴记录',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addDailyNote);
              },
            ),
            _buildQuickActionItem(
              icon: FontAwesomeIcons.calendarPlus,
              label: '添加日程',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addSchedule);
              },
            ),
            _buildQuickActionItem(
              icon: FontAwesomeIcons.plus,
              label: '新建任务',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addTask);
              },
            ),
            _buildQuickActionItem(
              icon: FontAwesomeIcons.solidNoteSticky,
              label: '添加备忘',
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.addMemo);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 构建快捷操作项
  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3ECABB).withValues(alpha: 0.2), // 浅色背景
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: const Color(0xFF3ECABB), // primary-400
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280), // text-gray-500
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 构建功能模块
  Widget _buildModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.apps, // 功能模块的图标
              color: Color(0xFF3ECABB), // primary-400
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '功能模块',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937), // text-gray-800
              ),
            ),
          ],
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: [
            _buildModuleItem(
              title: '笔记管理',
              icon: FontAwesomeIcons.book,
              startColor: const Color(0xFFFBBF24), // from-yellow-400
              endColor: const Color(0xFFF59E0B), // to-yellow-500
              onTap: () {
                // 直接导航到笔记页面
                Navigator.pushNamed(context, AppRoutes.note);
              },
            ),
            _buildModuleItem(
              title: '财务管理',
              icon: FontAwesomeIcons.wallet,
              startColor: const Color(0xFFF87171), // from-red-400
              endColor: const Color(0xFFEF4444), // to-red-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.finance);
              },
            ),
            _buildModuleItem(
              title: '图片管理',
              icon: FontAwesomeIcons.images,
              startColor: const Color(0xFFF472B6), // from-pink-400
              endColor: const Color(0xFFEC4899), // to-pink-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.photoGallery);
              },
            ),
            _buildModuleItem(
              title: '目标管理',
              icon: FontAwesomeIcons.bullseye,
              startColor: const Color(0xFFA5B4FC), // from-indigo-400
              endColor: const Color(0xFF818CF8), // to-indigo-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.goal);
              },
            ),
            _buildModuleItem(
              title: '旅游管理',
              icon: FontAwesomeIcons.plane,
              startColor: const Color(0xFF7DD3FC), // from-blue-300
              endColor: const Color(0xFF38BDF8), // to-blue-400
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.travel);
              },
            ),
            _buildModuleItem(
              title: '系统设置',
              icon: FontAwesomeIcons.gear,
              startColor: const Color(0xFF9CA3AF), // from-gray-400
              endColor: const Color(0xFF6B7280), // to-gray-500
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
          ],
        ),
      ],
    );
  }

  // 构建模块项
  Widget _buildModuleItem({
    required String title,
    required IconData icon,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: startColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: FaIcon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
