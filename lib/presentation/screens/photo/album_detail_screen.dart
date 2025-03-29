import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/presentation/providers/photo_provider.dart';
import 'package:intellimate/presentation/widgets/app_bar_widget.dart';
import 'package:intellimate/presentation/screens/photo/photo_detail_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;
  
  const AlbumDetailScreen({
    super.key,
    required this.albumId,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // 加载相册中的照片
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAlbumPhotos();
    });
  }
  
  // 加载相册照片
  Future<void> _loadAlbumPhotos() async {
    final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
    await photoProvider.loadAlbumPhotos(widget.albumId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoProvider>(
      builder: (context, photoProvider, child) {
        final albumPhotos = photoProvider.currentAlbumPhotos;
        final currentAlbum = photoProvider.currentAlbum;
        
        if (currentAlbum == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Scaffold(
          body: Column(
            children: [
              // 自定义AppBar
              AppBarWidget(
                title: currentAlbum.name,
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
                      _showMoreOptions(context, currentAlbum);
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
                            currentAlbum.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${currentAlbum.photoCount}张照片',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容区域
              if (photoProvider.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (photoProvider.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          photoProvider.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAlbumPhotos,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (albumPhotos.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: Colors.grey,
                          size: 64,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '相册中暂无照片',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // 照片网格
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAlbumPhotos,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: albumPhotos.length,
                      itemBuilder: (context, index) {
                        final photo = albumPhotos[index];
                        return _buildPhotoItem(photo, index);
                      },
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddPhotoDialog(context, currentAlbum.id),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }
  
  // 构建照片项
  Widget _buildPhotoItem(Photo photo, int index) {
    return GestureDetector(
      onTap: () {
        // 查看照片详情
        _showPhotoDetail(context, photo, index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photo.path),
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
            if (photo.isFavorite)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // 查看照片详情
  void _showPhotoDetail(BuildContext context, Photo photo, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoDetailScreen(
          photo: photo,
          index: index,
          photos: Provider.of<PhotoProvider>(context, listen: false).currentAlbumPhotos,
        ),
      ),
    );
  }
  
  // 显示更多选项
  void _showMoreOptions(BuildContext context, PhotoAlbum album) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑相册'),
            onTap: () {
              Navigator.pop(context);
              _showEditAlbumDialog(context, album);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('删除相册'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAlbumConfirmation(context, album);
            },
          ),
        ],
      ),
    );
  }
  
  // 显示编辑相册对话框
  void _showEditAlbumDialog(BuildContext context, PhotoAlbum album) {
    final TextEditingController nameController = TextEditingController(text: album.name);
    final TextEditingController descriptionController = TextEditingController(text: album.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑相册'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '相册名称',
                hintText: '请输入相册名称',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '相册描述',
                hintText: '请输入相册描述',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('相册名称不能为空')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              final updatedAlbum = PhotoAlbum(
                id: album.id,
                name: nameController.text.trim(),
                coverPhotoPath: album.coverPhotoPath,
                dateCreated: album.dateCreated,
                dateModified: DateTime.now(),
                photoCount: album.photoCount,
                description: descriptionController.text.trim(),
              );
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              await provider.updateAlbum(updatedAlbum);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
  
  // 显示删除相册确认对话框
  void _showDeleteAlbumConfirmation(BuildContext context, PhotoAlbum album) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除相册'),
        content: Text('确定要删除相册 "${album.name}" 吗？相册中的照片不会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              await provider.deleteAlbum(album.id);
              
              if (context.mounted) {
                Navigator.pop(context); // 返回上一页
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  // 显示添加照片对话框
  void _showAddPhotoDialog(BuildContext context, String albumId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('拍摄照片'),
            onTap: () async {
              Navigator.pop(context);
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              await provider.takePhoto(albumId: albumId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () async {
              Navigator.pop(context);
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              await provider.pickPhotos(albumId: albumId);
            },
          ),
        ],
      ),
    );
  }
} 