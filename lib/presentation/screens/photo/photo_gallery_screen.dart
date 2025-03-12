import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/presentation/widgets/app_bar_widget.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  // 当前选中的标签索引
  int _selectedTabIndex = 0;
  
  // 标签列表
  final List<String> _tabs = ['全部图片', '最近添加', '收藏', '已分享'];
  
  // 模拟相册数据
  final List<PhotoAlbum> _albums = [
    PhotoAlbum(
      id: '1',
      name: '旅行',
      coverPhotoPath: 'https://images.unsplash.com/photo-1527631746610-bca00a040d60',
      dateCreated: DateTime.now().subtract(const Duration(days: 30)),
      dateModified: DateTime.now().subtract(const Duration(days: 5)),
      photoCount: 86,
    ),
    PhotoAlbum(
      id: '2',
      name: '美食',
      coverPhotoPath: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
      dateCreated: DateTime.now().subtract(const Duration(days: 60)),
      dateModified: DateTime.now().subtract(const Duration(days: 10)),
      photoCount: 42,
    ),
    PhotoAlbum(
      id: '3',
      name: '家人',
      coverPhotoPath: 'https://images.unsplash.com/photo-1511895426328-dc8714191300',
      dateCreated: DateTime.now().subtract(const Duration(days: 90)),
      dateModified: DateTime.now().subtract(const Duration(days: 2)),
      photoCount: 128,
    ),
  ];
  
  // 模拟最近照片数据
  final List<String> _recentPhotos = [
    'https://images.unsplash.com/photo-1682687220063-4742bd7fd538',
    'https://images.unsplash.com/photo-1682687220208-22d7a2543e88',
    'https://images.unsplash.com/photo-1682687220923-c58b9a4592ea',
    'https://images.unsplash.com/photo-1695765386912-e419c3dd4921',
    'https://images.unsplash.com/photo-1695765386912-e419c3dd4921',
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
                    // 统计信息卡片
                    _buildStatsCard(),
                    
                    // 分类标签
                    _buildCategoryTabs(),
                    
                    // 相册列表
                    _buildAlbumSection(),
                    
                    // 最近照片
                    _buildRecentPhotosSection(),
                    
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
                '图片管理',
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
                  // 搜索图片
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
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
                    // 添加图片
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建统计信息卡片
  Widget _buildStatsCard() {
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
        children: [
          // 存储空间使用情况
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '已使用空间',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 0.35,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '350MB',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '1GB',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 统计数字
          Row(
            children: [
              Expanded(
                child: _buildStatItem('256', '总图片'),
              ),
              Expanded(
                child: _buildStatItem('12', '相册'),
              ),
              Expanded(
                child: _buildStatItem('28', '本月新增'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建统计项
  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
  
  // 构建分类标签
  Widget _buildCategoryTabs() {
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
  
  // 构建相册部分
  Widget _buildAlbumSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // 标题栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的相册',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // 管理相册
                },
                icon: const Icon(
                  Icons.settings,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: const Text(
                  '管理',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 相册网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              // 创建新相册
              _buildCreateAlbumItem(),
              
              // 相册列表
              ..._albums.map((album) => _buildAlbumItem(album)),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建创建相册项
  Widget _buildCreateAlbumItem() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // 创建相册
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '创建相册',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建相册项
  Widget _buildAlbumItem(PhotoAlbum album) {
    return GestureDetector(
      onTap: () {
        // 导航到相册详情页面
        Navigator.pushNamed(
          context,
          '/photo_gallery/album',
          arguments: album,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.blackWithOpacity05,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 相册封面
              Image.network(
                album.coverPhotoPath ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
              
              // 渐变遮罩
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.blackWithOpacity50,
                    ],
                    stops: [0.6, 1.0],
                  ),
                ),
              ),
              
              // 相册信息
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${album.photoCount}张照片',
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
        ),
      ),
    );
  }
  
  // 构建最近照片部分
  Widget _buildRecentPhotosSection() {
    return Column(
      children: [
        // 标题栏
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近照片',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // 查看全部
              },
              child: const Text(
                '查看全部',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 照片网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _recentPhotos.length + 1, // 加1是为了显示"更多"项
          itemBuilder: (context, index) {
            if (index < _recentPhotos.length) {
              return _buildPhotoItem(_recentPhotos[index]);
            } else {
              return _buildMorePhotosItem();
            }
          },
        ),
      ],
    );
  }
  
  // 构建照片项
  Widget _buildPhotoItem(String photoUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
              size: 30,
            ),
          );
        },
      ),
    );
  }
  
  // 构建更多照片项
  Widget _buildMorePhotosItem() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _recentPhotos.last,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[300]);
            },
          ),
          Container(
            color: AppColors.blackWithOpacity50,
            child: const Center(
              child: Text(
                '+42',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 