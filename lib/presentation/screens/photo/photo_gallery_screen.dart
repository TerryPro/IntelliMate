import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/app/theme/app_theme.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/presentation/providers/photo_provider.dart';
import 'package:intellimate/presentation/screens/photo/album_detail_screen.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  // 用于新建相册的控制器
  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _albumDescController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // 加载照片和相册数据
    _loadData();
  }
  
  @override
  void dispose() {
    _albumNameController.dispose();
    _albumDescController.dispose();
    super.dispose();
  }
  
  // 加载数据
  Future<void> _loadData() async {
    final provider = Provider.of<PhotoProvider>(context, listen: false);
    await provider.loadAllPhotos();
    await provider.loadAllAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 使用统一的顶部导航栏
          UnifiedAppBar(
            title: '图片管理',
            actions: [
              AppBarRefreshButton(
                onTap: () {
                  // 刷新功能
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('正在刷新...'))
                  );
                },
              ),
              const SizedBox(width: 8),
              AppBarAddButton(
                onTap: () {
                  // 创建相册功能
                  _showCreateAlbumDialog(context);
                },
              ),
            ],
          ),
          
          // 内容区域
          Expanded(
            child: Consumer<PhotoProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('重新加载'),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 统计信息卡片
                          _buildStatsCard(provider),
                          
                          // 相册列表
                          _buildAlbumSection(provider),
                          
                          // 底部间距
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建统计信息卡片
  Widget _buildStatsCard(PhotoProvider provider) {
    // 计算存储空间
    final int totalSize = provider.photos.fold(0, (sum, photo) => sum + photo.size);
    final double usedMB = totalSize / (1024 * 1024); // 转换为MB
    const double totalMB = 1024; // 假设总空间为1GB
    final double usageRatio = usedMB / totalMB;
    
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
                        value: usageRatio.clamp(0.0, 1.0),
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
                          '${usedMB.toStringAsFixed(2)}MB',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${totalMB.toStringAsFixed(0)}MB',
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
                child: _buildStatItem('${provider.photos.length}', '总图片'),
              ),
              Expanded(
                child: _buildStatItem('${provider.albums.length}', '相册'),
              ),
              Expanded(
                child: _buildStatItem(
                  '${provider.photos.where((p) => 
                    p.dateCreated.isAfter(DateTime.now().subtract(const Duration(days: 30)))
                  ).length}', 
                  '本月新增'
                ),
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
  
  // 构建相册部分
  Widget _buildAlbumSection(PhotoProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // 标题栏 - 删除管理功能和图标
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '我的相册',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          
          // 相册网格 - 删除创建相册的大面板
          if (provider.albums.isEmpty)
            // 空状态显示
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_album_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无相册',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateAlbumDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('创建相册'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          else
            // 相册网格
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: provider.albums.map((album) => _buildAlbumItem(album)).toList(),
            ),
        ],
      ),
    );
  }
  
  // 构建相册项
  Widget _buildAlbumItem(PhotoAlbum album) {
    return GestureDetector(
      onTap: () {
        // 导航到相册详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlbumDetailScreen(albumId: album.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 相册封面
              album.coverPhotoPath != null 
                ? Image.file(
                    File(album.coverPhotoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primaryVeryLightColor,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppTheme.primaryColor,
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.primaryVeryLightColor,
                    child: const Icon(
                      Icons.photo_album,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  ),
              
              // 渐变遮罩
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                    stops: const [0.6, 1.0],
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
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.photo,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${album.photoCount}张照片',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
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
  
  // 显示创建相册对话框 - 优化UI风格
  void _showCreateAlbumDialog(BuildContext context) {
    _albumNameController.clear();
    _albumDescController.clear();
       
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '创建相册',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _albumNameController,
                decoration: InputDecoration(
                  labelText: '相册名称',
                  hintText: '请输入相册名称',
                  prefixIcon: const Icon(Icons.photo_album_outlined, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _albumDescController,
                decoration: InputDecoration(
                  labelText: '相册描述 (可选)',
                  hintText: '请输入相册描述',
                  prefixIcon: const Icon(Icons.description_outlined, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              '取消',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_albumNameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('请输入相册名称'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.errorColor,
                  )
                );
                return;
              }
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              final albumName = _albumNameController.text.trim();
              final albumDesc = _albumDescController.text.trim().isNotEmpty
                  ? _albumDescController.text.trim()
                  : null;
              
              Navigator.pop(dialogContext);
              
              final albumId = await provider.createNewAlbum(
                albumName,
                description: albumDesc,
              );
              
              if (!mounted) return;
              
              if (albumId != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('相册 "$albumName" 创建成功'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.successColor,
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('创建相册失败，请重试'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.errorColor,
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              '创建',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
} 