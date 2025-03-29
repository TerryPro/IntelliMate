import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/presentation/providers/photo_provider.dart';

class PhotoDetailScreen extends StatefulWidget {
  final Photo photo;
  final int index;
  final List<Photo> photos;
  
  const PhotoDetailScreen({
    super.key,
    required this.photo,
    required this.index,
    required this.photos,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _pageController = PageController(initialPage: _currentIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 照片查看器
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return _buildPhotoView(photo);
            },
          ),
          
          // 顶部应用栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                Consumer<PhotoProvider>(
                  builder: (context, provider, _) {
                    final currentPhoto = widget.photos[_currentIndex];
                    return IconButton(
                      icon: Icon(
                        currentPhoto.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: currentPhoto.isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () async {
                        if (currentPhoto.id != null) {
                          await provider.togglePhotoFavorite(
                            currentPhoto.id!,
                            !currentPhoto.isFavorite,
                          );
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    _showMoreOptions(context, widget.photos[_currentIndex]);
                  },
                ),
              ],
            ),
          ),
          
          // 底部信息
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Consumer<PhotoProvider>(
                builder: (context, provider, _) {
                  final currentPhoto = widget.photos[_currentIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPhoto.name ?? '未命名照片',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '拍摄于 ${_formatDate(currentPhoto.dateCreated)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      if (currentPhoto.description != null &&
                          currentPhoto.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          currentPhoto.description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建照片查看视图
  Widget _buildPhotoView(Photo photo) {
    return GestureDetector(
      onTap: () {
        // 点击切换控件的显示/隐藏
      },
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Center(
          child: Image.file(
            File(photo.path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  // 显示更多选项菜单
  void _showMoreOptions(BuildContext context, Photo photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('分享', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // 分享功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('编辑', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditPhotoDialog(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.white),
              title: const Text('删除', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, photo);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // 显示编辑照片对话框
  void _showEditPhotoDialog(BuildContext context, Photo photo) {
    final TextEditingController nameController = TextEditingController(text: photo.name);
    final TextEditingController descriptionController = TextEditingController(text: photo.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑照片信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '照片名称',
                hintText: '输入照片名称',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '照片描述',
                hintText: '输入照片描述',
              ),
              maxLines: 3,
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
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              
              Navigator.pop(context);
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              if (photo.id != null) {
                final updatedPhoto = photo.copyWith(
                  name: name.isNotEmpty ? name : photo.name,
                  description: description.isNotEmpty ? description : photo.description,
                );
                
                await provider.updatePhoto(updatedPhoto);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmation(BuildContext context, Photo photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除照片'),
        content: const Text('确定要删除这张照片吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final provider = Provider.of<PhotoProvider>(context, listen: false);
              if (photo.id != null) {
                final success = await provider.deletePhoto(photo.id!);
                if (success && context.mounted) {
                  Navigator.pop(context); // 返回上一页
                }
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  // 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
} 