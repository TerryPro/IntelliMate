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
  
  // 模拟图片列表
  final List<String> _availableImages = [
    'assets/images/design.jpg',
  ];
  
  // 心情选项
  final List<String> _moods = ['开心', '平静', '伤心', '愤怒', '惊讶'];
  
  // 天气选项
  final List<String> _weathers = ['晴', '多云', '阴', '雨', '雪'];
  
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
      
      final dailyNote = await dailyNoteProvider.createDailyNote(
        content: _contentController.text,
        author: '用户',
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        mood: _mood,
        weather: _weather,
        isPrivate: _isPrivate,
      );
      
      if (dailyNote != null && mounted) {
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
                      const SizedBox(height: 20),
                      
                      // 心情选择
                      _buildMoodSelector(),
                      const SizedBox(height: 20),
                      
                      // 天气选择
                      _buildWeatherSelector(),
                      const SizedBox(height: 20),
                      
                      // 隐私设置
                      _buildPrivacyToggle(),
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
                  Navigator.pushNamed(context, AppRoutes.home);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
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
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '添加点滴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _saveDailyNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3ECABB),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              '发布',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
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
  
  // 构建心情选择
  Widget _buildMoodSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // 心情选择
          const Text(
            '今天的心情',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // 心情选项
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moods.map((mood) => _buildMoodOption(mood)).toList(),
          ),
        ],
      ),
    );
  }
  
  // 构建天气选择
  Widget _buildWeatherSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // 天气选择
          const Text(
            '今天的天气',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // 天气选项
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _weathers.map((weather) => _buildWeatherOption(weather)).toList(),
          ),
        ],
      ),
    );
  }
  
  // 构建隐私设置
  Widget _buildPrivacyToggle() {
    return Column(
      children: [
        // 谁可以看
        _buildSettingItem(
          icon: Icons.lock,
          title: '谁可以看',
          trailing: Row(
            children: [
              Text(
                _isPrivate ? '仅自己' : '公开',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade300,
                size: 20,
              ),
            ],
          ),
          onTap: () {
            setState(() {
              _isPrivate = !_isPrivate;
            });
          },
        ),
      ],
    );
  }
  
  // 构建心情选项
  Widget _buildMoodOption(String mood) {
    final isSelected = _mood == mood;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _mood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3ECABB) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          mood,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  // 构建天气选项
  Widget _buildWeatherOption(String weather) {
    final isSelected = _weather == weather;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _weather = weather;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3ECABB) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          weather,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  
  // 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
} 