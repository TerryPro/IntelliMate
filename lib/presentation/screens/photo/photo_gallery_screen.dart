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
          // 标题栏
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
          
          // 相册列表
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
            // 使用ListView替代GridView
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.albums.length,
              itemBuilder: (context, index) => _buildAlbumCard(provider.albums[index], provider),
            ),
        ],
      ),
    );
  }
  
  // 新的相册卡片样式
  Widget _buildAlbumCard(PhotoAlbum album, PhotoProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // 导航到相册详情页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumDetailScreen(albumId: album.id),
            ),
          );
        },
        child: Column(
          children: [
            // 相册封面部分
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: AppTheme.primaryVeryLightColor,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 相册封面图片
                    album.coverPhotoPath != null 
                      ? Image.file(
                          File(album.coverPhotoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.photo_album,
                              color: AppTheme.primaryColor,
                              size: 60,
                            );
                          },
                        )
                      : const Icon(
                          Icons.photo_album,
                          color: AppTheme.primaryColor,
                          size: 60,
                        ),
                    
                    // 渐变遮罩
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    
                    // 添加进行中/已完成标签 (参考旅行卡片)
                    if (album.photoCount > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            '活跃',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    // 相册标题
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Text(
                        album.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 相册信息部分
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 相册描述
                  if (album.description != null && album.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        album.description!,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // 相册信息(照片数、创建日期)和操作按钮放在同一行
                  Row(
                    children: [
                      // 照片数量信息
                      _buildInfoItem(Icons.photo, '${album.photoCount}张照片'),
                      const SizedBox(width: 16),
                      // 创建日期信息
                      _buildInfoItem(
                        Icons.access_time, 
                        '${_formatDate(album.dateCreated)}'
                      ),
                      // 操作按钮置于右侧
                      const Spacer(),
                      // 编辑按钮 - 采用圆形灰色背景
                      _buildCircleIconButton(
                        Icons.edit_outlined,
                        AppTheme.primaryColor,
                        () => _showEditAlbumDialog(context, album, provider),
                      ),
                      const SizedBox(width: 8),
                      // 删除按钮 - 采用圆形灰色背景
                      _buildCircleIconButton(
                        Icons.delete_outline,
                        Colors.red,
                        () => _showDeleteAlbumDialog(context, album, provider),
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
  
  // 构建圆形图标按钮 (类似备忘录样式)
  Widget _buildCircleIconButton(IconData icon, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }
  
  // 构建信息项
  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
  
  // 显示编辑相册对话框
  void _showEditAlbumDialog(BuildContext context, PhotoAlbum album, PhotoProvider provider) {
    final TextEditingController nameController = TextEditingController(text: album.name);
    final TextEditingController descController = TextEditingController(text: album.description);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '编辑相册',
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
                controller: nameController,
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
                controller: descController,
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
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('请输入相册名称'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.errorColor,
                  )
                );
                return;
              }
              
              Navigator.pop(dialogContext);
              
              // 更新相册
              final updatedAlbum = album.copyWith(
                name: nameController.text.trim(),
                description: descController.text.trim().isNotEmpty 
                    ? descController.text.trim() 
                    : null,
                dateModified: DateTime.now(),
              );
              
              final success = await provider.updateAlbum(updatedAlbum);
              
              if (!mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('相册更新成功'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.successColor,
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('相册更新失败，请重试'),
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
              '保存',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
  
  // 显示删除相册对话框
  void _showDeleteAlbumDialog(BuildContext context, PhotoAlbum album, PhotoProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '删除相册',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '确定要删除此相册吗？',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (album.photoCount > 0)
              Text(
                '注意：相册中的${album.photoCount}张照片将保留，但不再属于此相册。',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                ),
              ),
          ],
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
              Navigator.pop(dialogContext);
              
              // 删除相册
              final success = await provider.deleteAlbum(album.id);
              
              if (!mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('相册删除成功'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.successColor,
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('相册删除失败，请重试'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.errorColor,
                  )
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              '删除',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
} 