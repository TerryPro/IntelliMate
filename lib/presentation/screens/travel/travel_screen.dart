import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intl/intl.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  // 当前选中的标签索引
  int _selectedTabIndex = 0;
  
  // 标签列表
  final List<String> _tabs = ['全部', '计划中', '进行中', '已完成'];
  
  // 模拟旅行数据
  final List<Travel> _travels = [
    Travel(
      id: 1,
      title: '云南之旅',
      startDate: DateTime(2023, 7, 15),
      endDate: DateTime(2023, 7, 22),
      destination: '昆明',
      places: ['昆明', '大理', '丽江'],
      peopleCount: 3,
      budget: 6000,
      status: TravelStatus.ongoing,
      photoCount: 36,
    ),
    Travel(
      id: 2,
      title: '上海周末游',
      startDate: DateTime(2023, 6, 24),
      endDate: DateTime(2023, 6, 25),
      destination: '上海',
      places: ['上海'],
      peopleCount: 2,
      budget: 2000,
      actualCost: 1860,
      status: TravelStatus.completed,
      photoCount: 48,
    ),
    Travel(
      id: 3,
      title: '北京之行',
      startDate: DateTime(2023, 10, 1),
      endDate: DateTime(2023, 10, 7),
      destination: '北京',
      places: ['北京'],
      peopleCount: 4,
      budget: 8000,
      status: TravelStatus.planning,
      tasks: [
        TravelTask(
          id: 1,
          title: '预订机票',
          type: TravelTaskType.transportation,
        ),
        TravelTask(
          id: 2,
          title: '预订酒店',
          type: TravelTaskType.accommodation,
        ),
        TravelTask(
          id: 3,
          title: '准备行李',
          type: TravelTaskType.packing,
        ),
      ],
    ),
  ];
  
  // 旅行工具列表
  final List<Map<String, dynamic>> _travelTools = [
    {
      'icon': Icons.route,
      'label': '行程规划',
      'color': Colors.blue,
    },
    {
      'icon': Icons.hotel,
      'label': '住宿管理',
      'color': Colors.green,
    },
    {
      'icon': Icons.book,
      'label': '旅行日志',
      'color': Colors.amber,
    },
    {
      'icon': Icons.attach_money,
      'label': '花费记录',
      'color': Colors.red,
    },
    {
      'icon': Icons.luggage,
      'label': '行李清单',
      'color': Colors.purple,
    },
    {
      'icon': Icons.confirmation_number,
      'label': '票务管理',
      'color': Colors.indigo,
    },
    {
      'icon': Icons.location_on,
      'label': '景点收藏',
      'color': Colors.pink,
    },
    {
      'icon': Icons.more_horiz,
      'label': '更多',
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 旅行统计卡片
                    _buildTravelStatsCard(),
                    
                    // 旅行类型选择
                    _buildTravelTypeTabs(),
                    
                    // 旅行列表
                    _buildTravelList(),
                    
                    // 旅行工具
                    _buildTravelTools(),
                    
                    // 底部间距
                    const SizedBox(height: 80),
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
        color: Color(0xFF3ECABB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, 'appRoutes.home');
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                '旅游管理',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 刷新旅游数据
                  setState(() {
                    // 刷新逻辑
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF3ECABB),
                    size: 20,
                  ),
                  onPressed: () {
                    // 添加旅行
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建旅行统计卡片
  Widget _buildTravelStatsCard() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '旅行统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '8',
                  '已去城市',
                  Colors.blue.shade50,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '12',
                  '旅行天数',
                  Colors.green.shade50,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '¥9,860',
                  '总花费',
                  Colors.purple.shade50,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建统计项
  Widget _buildStatItem(String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建旅行类型标签
  Widget _buildTravelTypeTabs() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 构建旅行列表
  Widget _buildTravelList() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的旅行',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // 筛选功能
                },
                icon: const Icon(
                  Icons.filter_list,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: const Text(
                  '筛选',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 旅行卡片列表
          ..._travels.map((travel) => _buildTravelCard(travel)),
        ],
      ),
    );
  }
  
  // 构建旅行卡片
  Widget _buildTravelCard(Travel travel) {
    // 根据旅行状态设置标签颜色
    Color statusColor;
    String statusText;
    
    switch (travel.status) {
      case TravelStatus.planning:
        statusColor = Colors.amber;
        statusText = '计划中';
        break;
      case TravelStatus.ongoing:
        statusColor = Colors.green;
        statusText = '进行中';
        break;
      case TravelStatus.completed:
        statusColor = Colors.blue;
        statusText = '已完成';
        break;
    }
    
    // 格式化日期
    final dateFormat = DateFormat('yyyy.MM.dd');
    final startDateStr = dateFormat.format(travel.startDate);
    final endDateStr = dateFormat.format(travel.endDate);
    
    // 计算旅行天数
    final duration = travel.endDate.difference(travel.startDate).inDays + 1;
    final durationText = '$duration天${duration > 1 ? '${duration - 1}晚' : ''}';
    
    return GestureDetector(
      onTap: () {
        // 导航到旅行详情页面
        Navigator.pushNamed(
          context,
          '/travel/detail',
          arguments: travel,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            // 顶部图片和标题
            Stack(
              children: [
                // 背景图片
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    _getTravelImage(travel),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                
                // 渐变遮罩
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.blackWithOpacity50,
                      ],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),
                
                // 状态标签
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // 旅行标题和日期
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        travel.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$startDateStr - $endDateStr',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // 旅行详情
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 目的地和天数
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                travel.places.join(' - '),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        durationText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 底部信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 人数
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${travel.peopleCount}人',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      // 预算/花费
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            travel.status == TravelStatus.completed
                                ? '花费: ¥${travel.actualCost?.toStringAsFixed(0) ?? 0}'
                                : '预算: ¥${travel.budget.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      
                      // 照片数量或待完成任务
                      Row(
                        children: [
                          Icon(
                            travel.status == TravelStatus.planning
                                ? Icons.checklist
                                : Icons.photo_camera,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            travel.status == TravelStatus.planning
                                ? '待完成: ${travel.tasks?.length ?? 0}项'
                                : '${travel.photoCount ?? 0}张照片',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 获取旅行图片
  String _getTravelImage(Travel travel) {
    // 根据旅行目的地或状态返回不同的图片
    switch (travel.status) {
      case TravelStatus.ongoing:
        return 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05';
      case TravelStatus.completed:
        return 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b';
      case TravelStatus.planning:
        return 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e';
    }
  }
  
  // 构建旅行工具
  Widget _buildTravelTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '旅行工具',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _travelTools.length,
          itemBuilder: (context, index) {
            final tool = _travelTools[index];
            return _buildToolItem(
              icon: tool['icon'],
              label: tool['label'],
              color: tool['color'],
            );
          },
        ),
      ],
    );
  }
  
  // 构建工具项
  Widget _buildToolItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.getColorWithOpacity(color, 0.1),
            borderRadius: BorderRadius.circular(28),
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
            color: Colors.black87,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 