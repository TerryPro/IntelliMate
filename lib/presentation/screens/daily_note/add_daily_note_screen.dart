import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:provider/provider.dart';

class AddDailyNoteScreen extends StatefulWidget {
  const AddDailyNoteScreen({super.key});

  @override
  State<AddDailyNoteScreen> createState() => _AddDailyNoteScreenState();
}

class _AddDailyNoteScreenState extends State<AddDailyNoteScreen> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _mood = '开心';
  String _weather = '晴';
  bool _isPrivate = false;
  final List<String> _selectedImages = [];
  bool _isLoading = false;
  DailyNote? _editingNote;
  bool _isEditMode = false;
  
  // 模拟图片列表
  final List<String> _availableImages = [
    'assets/images/design.jpg',
  ];
  
  // 心情选项
  final List<String> _moods = ['开心', '平静', '伤心', '愤怒', '惊讶'];
  
  // 天气选项
  final List<String> _weathers = ['晴', '多云', '阴', '雨', '雪'];
  
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
          if (args.mood != null) {
            _mood = args.mood!;
          }
          if (args.weather != null) {
            _weather = args.weather!;
          }
          _isPrivate = args.isPrivate;
          if (args.images != null && args.images!.isNotEmpty) {
            _selectedImages.addAll(args.images!);
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
      final dailyNoteProvider = Provider.of<DailyNoteProvider>(context, listen: false);
      
      DailyNote? dailyNote;
      
      // 根据是否为编辑模式执行不同操作
      if (_isEditMode && _editingNote != null) {
        // 更新已有点滴 - 创建新的DailyNote对象保留原始ID和时间戳
        final updatedNote = DailyNote(
          id: _editingNote!.id,
          content: _contentController.text,
          author: _editingNote!.author,
          images: _selectedImages.isNotEmpty ? _selectedImages : null,
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          mood: _editingNote!.mood, // 保留原有的心情值
          weather: _editingNote!.weather, // 保留原有的天气值
          isPrivate: _editingNote!.isPrivate, // 保留原有的隐私设置
          likes: _editingNote!.likes,
          comments: _editingNote!.comments,
          codeSnippet: _editingNote!.codeSnippet,
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
          location: _locationController.text.isNotEmpty ? _locationController.text : null,
          // 移除心情、天气和隐私设置相关参数，使用默认值
          // mood: _mood,
          // weather: _weather,
          // isPrivate: _isPrivate,
        );
      }
      
      if ((dailyNote != null || _isEditMode) && mounted) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // 选择图片
  void _selectImage() {
    // 这里应该调用图片选择器
    // 暂时只是添加模拟图片
    if (_selectedImages.isEmpty && _availableImages.isNotEmpty) {
      setState(() {
        _selectedImages.add(_availableImages.first);
      });
    }
  }
  
  // 移除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
              _buildCustomAppBar(),
              
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
                      // 以下部分暂时移除
                      // const SizedBox(height: 20),
                      // 心情选择
                      // _buildMoodSelector(),
                      // const SizedBox(height: 20),
                      // 天气选择
                      // _buildWeatherSelector(),
                      // const SizedBox(height: 20),
                      // 隐私设置
                      // _buildPrivacyToggle(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
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
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 取消按钮
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
            ),
            child: const Text('取消'),
          ),
          
          // 标题
          Text(
            _isEditMode ? '编辑点滴' : '新建点滴',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // 发布按钮
          TextButton(
            onPressed: _saveDailyNote,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF3ECABB),
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
            ),
            child: _isLoading
                ? Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3ECABB)),
                    ),
                  )
                : const Text('发布'),
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
          // 已选择的图片
          if (_selectedImages.isNotEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
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
                  );
                },
              ),
            ),
          
          // 添加图片按钮
          GestureDetector(
            onTap: _selectImage,
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
              child: Row(
                children: [
                  Icon(
                    Icons.image,
                    color: Colors.grey.shade500,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '添加图片',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建位置输入
  Widget _buildLocationInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
        textAlign: TextAlign.right,
      ),
    );
  }
} 