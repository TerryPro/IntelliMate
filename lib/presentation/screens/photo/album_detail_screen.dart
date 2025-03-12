import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/presentation/widgets/app_bar_widget.dart';

class AlbumDetailScreen extends StatefulWidget {
  final PhotoAlbum album;
  
  const AlbumDetailScreen({
    super.key,
    required this.album,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  // 模拟照片数据
  late List<String> _photos;
  
  @override
  void initState() {
    super.initState();
    
    // 根据相册生成模拟照片数据
    _photos = List.generate(
      widget.album.photoCount,
      (index) => 'https://source.unsplash.com/random/300x300?sig=$index',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 自定义AppBar
          AppBarWidget(
            title: widget.album.name,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  // 搜索功能
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {
                  // 更多选项
                  _showMoreOptions(context);
                },
              ),
            ],
          ),
          
          // 相册信息
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.photo_album,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.album.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.album.photoCount}张照片',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // 添加照片
                  },
                  icon: const Icon(
                    Icons.add_photo_alternate,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    '添加',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 照片网格
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                return _buildPhotoItem(_photos[index], index);
              },
            ),
          ),
        ],
      ),
      
      // 删除浮动按钮部分
    );
  }
  
  // 构建照片项
  Widget _buildPhotoItem(String photoUrl, int index) {
    return GestureDetector(
      onTap: () {
        // 查看照片详情
        _showPhotoDetail(context, photoUrl, index);
      },
      child: ClipRRect(
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
      ),
    );
  }
  
  // 显示照片详情
  void _showPhotoDetail(BuildContext context, String photoUrl, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 顶部操作栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      '${index + 1}/${_photos.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {
                        // 更多操作
                      },
                    ),
                  ],
                ),
              ),
              
              // 照片展示
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 60,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // 底部操作栏
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackWithOpacity05,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.share, '分享'),
                    _buildActionButton(Icons.edit, '编辑'),
                    _buildActionButton(Icons.favorite_border, '收藏'),
                    _buildActionButton(Icons.delete_outline, '删除'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 构建操作按钮
  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            // 按钮操作
          },
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
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
                title: const Text('编辑相册'),
                onTap: () {
                  Navigator.pop(context);
                  // 编辑相册
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享相册'),
                onTap: () {
                  Navigator.pop(context);
                  // 分享相册
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除相册'),
                onTap: () {
                  Navigator.pop(context);
                  // 删除相册
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