import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intl/intl.dart';

class TravelDetailScreen extends StatefulWidget {
  final Travel travel;
  
  const TravelDetailScreen({
    super.key,
    required this.travel,
  });

  @override
  State<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends State<TravelDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 标签列表
  final List<String> _tabs = ['行程', '住宿', '交通', '花费', '照片', '笔记'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部封面和信息
          _buildHeader(),
          
          // 标签栏
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          
          // 标签内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItineraryTab(),
                _buildAccommodationTab(),
                _buildTransportationTab(),
                _buildExpenseTab(),
                _buildPhotosTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
      
      // 浮动按钮
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // 根据当前标签添加不同的内容
          _showAddOptions(context);
        },
      ),
    );
  }
  
  // 构建顶部封面和信息
  Widget _buildHeader() {
    // 格式化日期
    final dateFormat = DateFormat('yyyy.MM.dd');
    final startDateStr = dateFormat.format(widget.travel.startDate);
    final endDateStr = dateFormat.format(widget.travel.endDate);
    
    // 计算旅行天数
    final duration = widget.travel.endDate.difference(widget.travel.startDate).inDays + 1;
    final durationText = '$duration天${duration > 1 ? '${duration - 1}晚' : ''}';
    
    // 根据旅行状态设置标签颜色和文本
    Color statusColor;
    String statusText;
    
    switch (widget.travel.status) {
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
    
    return Stack(
      children: [
        // 背景图片
        Image.network(
          _getTravelImage(),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 60,
              ),
            );
          },
        ),
        
        // 渐变遮罩
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.getColorWithOpacity(Colors.black, 0.3),
                AppColors.blackWithOpacity50,
              ],
            ),
          ),
        ),
        
        // 返回按钮
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.getColorWithOpacity(Colors.black, 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // 更多按钮
        Positioned(
          top: MediaQuery.of(context).padding.top,
          right: 16,
          child: GestureDetector(
            onTap: () {
              _showMoreOptions(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.getColorWithOpacity(Colors.black, 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // 旅行信息
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态标签
              Container(
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
              
              const SizedBox(height: 8),
              
              // 旅行标题
              Text(
                widget.travel.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 旅行日期和天数
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$startDateStr - $endDateStr',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    durationText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 目的地
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.travel.places.join(' - '),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 获取旅行图片
  String _getTravelImage() {
    // 根据旅行目的地或状态返回不同的图片
    switch (widget.travel.status) {
      case TravelStatus.ongoing:
        return 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05';
      case TravelStatus.completed:
        return 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b';
      case TravelStatus.planning:
        return 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e';
    }
  }
  
  // 构建行程标签页
  Widget _buildItineraryTab() {
    return _buildEmptyState(
      icon: Icons.route,
      title: '暂无行程安排',
      message: '点击下方按钮添加行程安排',
    );
  }
  
  // 构建住宿标签页
  Widget _buildAccommodationTab() {
    return _buildEmptyState(
      icon: Icons.hotel,
      title: '暂无住宿信息',
      message: '点击下方按钮添加住宿信息',
    );
  }
  
  // 构建交通标签页
  Widget _buildTransportationTab() {
    return _buildEmptyState(
      icon: Icons.directions_car,
      title: '暂无交通信息',
      message: '点击下方按钮添加交通信息',
    );
  }
  
  // 构建花费标签页
  Widget _buildExpenseTab() {
    return _buildEmptyState(
      icon: Icons.attach_money,
      title: '暂无花费记录',
      message: '点击下方按钮添加花费记录',
    );
  }
  
  // 构建照片标签页
  Widget _buildPhotosTab() {
    return _buildEmptyState(
      icon: Icons.photo_library,
      title: '暂无照片',
      message: '点击下方按钮添加照片',
    );
  }
  
  // 构建笔记标签页
  Widget _buildNotesTab() {
    return _buildEmptyState(
      icon: Icons.note,
      title: '暂无旅行笔记',
      message: '点击下方按钮添加旅行笔记',
    );
  }
  
  // 构建空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // 显示添加选项
  void _showAddOptions(BuildContext context) {
    final currentTab = _tabs[_tabController.index];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '添加$currentTab',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              _buildAddOptionItem(
                icon: _getTabIcon(currentTab),
                title: '添加$currentTab',
                onTap: () {
                  Navigator.pop(context);
                  // 添加内容
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
  
  // 获取标签图标
  IconData _getTabIcon(String tab) {
    switch (tab) {
      case '行程':
        return Icons.route;
      case '住宿':
        return Icons.hotel;
      case '交通':
        return Icons.directions_car;
      case '花费':
        return Icons.attach_money;
      case '照片':
        return Icons.photo_camera;
      case '笔记':
        return Icons.note;
    }
    return Icons.add;
  }
  
  // 构建添加选项项
  Widget _buildAddOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: onTap,
    );
  }
  
  // 显示更多选项
  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑旅行'),
                onTap: () {
                  Navigator.pop(context);
                  // 编辑旅行
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享旅行'),
                onTap: () {
                  Navigator.pop(context);
                  // 分享旅行
                },
              ),
              if (widget.travel.status == TravelStatus.planning)
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.green),
                  title: const Text('开始旅行'),
                  onTap: () {
                    Navigator.pop(context);
                    // 开始旅行
                  },
                ),
              if (widget.travel.status == TravelStatus.ongoing)
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.blue),
                  title: const Text('完成旅行'),
                  onTap: () {
                    Navigator.pop(context);
                    // 完成旅行
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除旅行'),
                onTap: () {
                  Navigator.pop(context);
                  // 删除旅行
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
} 