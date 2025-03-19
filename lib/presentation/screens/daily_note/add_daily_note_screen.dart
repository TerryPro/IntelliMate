import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intellimate/utils/app_logger.dart';

class AddDailyNoteScreen extends StatefulWidget {
  const AddDailyNoteScreen({super.key});

  @override
  State<AddDailyNoteScreen> createState() => _AddDailyNoteScreenState();
}

class _AddDailyNoteScreenState extends State<AddDailyNoteScreen> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();

  final List<String> _selectedImages = [];
  bool _isLoading = false;
  DailyNote? _editingNote;
  bool _isEditMode = false;

  // 图片选择器
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is DailyNote) {
        setState(() {
          _editingNote = args;
          _isEditMode = true;

          _contentController.text = args.content;
          if (args.location != null) {
            _locationController.text = args.location!;
          }
          if (args.images != null && args.images!.isNotEmpty) {
            _selectedImages.addAll(args.images!);
            // 尝试加载第一张图片
            try {
              final imagePath = args.images!.first;
              final file = File(imagePath);
              if (file.existsSync()) {
                _selectedImage = file;
              }
            } catch (e) {
              AppLogger.log('加载已有图片失败: $e');
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // 保存日常点滴
  Future<void> _saveDailyNote() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入内容'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dailyNoteProvider =
          Provider.of<DailyNoteProvider>(context, listen: false);

      DailyNote? dailyNote;

      // 根据是否为编辑模式执行不同操作
      if (_isEditMode && _editingNote != null) {
        // 更新已有点滴 - 创建新的DailyNote对象保留原始ID和时间戳
        final updatedNote = DailyNote(
          id: _editingNote!.id,
          content: _contentController.text,
          author: _editingNote!.author,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          location: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          isPrivate: false, // 设置为非私密
          createdAt: _editingNote!.createdAt,
          updatedAt: DateTime.now(), // 更新时间戳
        );

        final success = await dailyNoteProvider.updateDailyNote(updatedNote);
        if (success) {
          dailyNote = updatedNote;
        }
      } else {
        // 创建新点滴
        dailyNote = await dailyNoteProvider.createDailyNote(
          content: _contentController.text,
          author: '用户',
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          location: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          isPrivate: false, // 设置为非私密
        );
      }

      if ((dailyNote != null || _isEditMode) && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 选择图片
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          // 清空之前的图片列表，因为我们只允许一张图片
          _selectedImages.clear();
          // 存储图片路径
          _selectedImages.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选择图片失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 拍摄照片
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
          // 清空之前的图片列表，因为我们只允许一张图片
          _selectedImages.clear();
          // 存储图片路径
          _selectedImages.add(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('拍照失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 移除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // 自定义顶部导航栏
              CustomEditorAppBar(
                title: _isEditMode ? '编辑点滴' : '新建点滴',
                onBackTap: () => Navigator.pop(context),
                onSaveTap: _saveDailyNote,
                isLoading: _isLoading,
              ),

              // 主体内容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 内容输入框
                      _buildContentInput(),
                      const SizedBox(height: 20),

                      // 图片选择区域
                      _buildImageSelector(),
                      const SizedBox(height: 20),

                      // 位置输入
                      _buildLocationInput(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // 构建内容输入框
  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: '记录你的点滴...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // 构建图片选择区域
  Widget _buildImageSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '添加照片',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // 已选择的图片
          if (_selectedImage != null)
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 添加图片按钮
          if (_selectedImage == null)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.blackWithOpacity05,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Colors.grey.shade500,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '从相册选择',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.blackWithOpacity05,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.grey.shade500,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '拍摄照片',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // 构建位置输入
  Widget _buildLocationInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '位置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    hintText: '添加位置',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
