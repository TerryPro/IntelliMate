import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WriteNoteScreen extends StatefulWidget {
  const WriteNoteScreen({super.key, this.note});

  final Note? note;

  @override
  State<WriteNoteScreen> createState() => _WriteNoteScreenState();
}

class _WriteNoteScreenState extends State<WriteNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedCategory = '工作';
  List<String> _selectedTags = [];
  bool _isFavorite = false;
  bool _isLoading = false;
  String? _error;
  bool _isEditing = false;
  
  // 附件列表
  final List<String> _attachments = [];
  
  // 分类列表
  final List<String> _categories = ['工作', '学习', '生活', '灵感'];
  
  // 标签列表
  final List<String> _availableTags = ['重要', '技术', '会议', '计划', '创意', '问题'];
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑现有笔记，则填充数据
    if (widget.note != null) {
      _isEditing = true;
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      if (widget.note!.category != null) {
        _selectedCategory = widget.note!.category!;
      }
      if (widget.note!.tags != null) {
        _selectedTags = List.from(widget.note!.tags!);
      }
      _isFavorite = widget.note!.isFavorite;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  // 保存笔记
  Future<void> _saveNote() async {
    // 基本验证
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }
    
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      
      if (_isEditing && widget.note != null) {
        // 更新现有笔记
        final updatedNote = Note(
          id: widget.note!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          tags: _selectedTags.isEmpty ? null : _selectedTags,
          isFavorite: _isFavorite,
          createdAt: widget.note!.createdAt,
          updatedAt: DateTime.now(),
        );
        
        await noteProvider.updateNote(updatedNote);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('笔记已更新')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // 创建新笔记
        final newNote = Note(
          id: '', // ID会在仓库中生成
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          tags: _selectedTags.isEmpty ? null : _selectedTags,
          isFavorite: _isFavorite,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await noteProvider.createNote(newNote);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('笔记已创建')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $_error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 添加标签
  void _addTag() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标签'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Chip(
                label: Text(tag),
                backgroundColor: isSelected 
                    ? const Color(0xFFD5F5F2) 
                    : Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? const Color(0xFF26B0A1) 
                      : Colors.grey.shade700,
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }
  
  // 添加附件
  void _addAttachment() {
    // 这里应该调用文件选择器
    // 暂时只是显示一个提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('添加附件功能尚未实现'),
      ),
    );
  }
  
  // 切换隐私设置
  void _togglePrivacy() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }
  
  // 切换提醒设置
  void _toggleReminder() {
    setState(() {
      // 提醒设置逻辑
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
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
                  // 笔记标题
                  _buildTitleInput(),
                  
                  // 笔记分类
                  _buildCategorySelector(),
                  
                  // 编辑工具栏
                  _buildEditToolbar(),
                  
                  // 笔记内容
                  _buildContentInput(),
                  
                  // 附件区域
                  _buildAttachmentArea(),
                  
                  // 底部选项
                  _buildBottomOptions(),
                  
                  // 自动保存提示
                  _buildAutoSaveHint(),
                ],
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
        color: AppColors.primary,
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
                    color: AppColors.white,
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
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '编写笔记',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _saveNote,
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
              '保存',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建标题输入
  Widget _buildTitleInput() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: '请输入标题...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Divider(color: Colors.grey.shade200),
        const SizedBox(height: 16),
      ],
    );
  }
  
  // 构建分类选择器
  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          // 分类选择
          GestureDetector(
            onTap: () {
              // 显示分类选择对话框
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('选择分类'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _categories.map((category) {
                      return RadioListTile<String>(
                        title: Text(category),
                        value: category,
                        groupValue: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEFBFA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder,
                    color: Color(0xFF3ECABB),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedCategory,
                    style: const TextStyle(
                      color: Color(0xFF3ECABB),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF3ECABB),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 标签添加
          GestureDetector(
            onTap: _addTag,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tag,
                    color: Colors.grey.shade500,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '添加标签',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.add,
                    color: Colors.grey.shade500,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建编辑工具栏
  Widget _buildEditToolbar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolbarButton(Icons.format_bold),
            _buildToolbarButton(Icons.format_italic),
            _buildToolbarButton(Icons.format_underlined),
            _buildToolbarDivider(),
            _buildToolbarButton(Icons.format_list_bulleted),
            _buildToolbarButton(Icons.format_list_numbered),
            _buildToolbarButton(Icons.check_box),
            _buildToolbarDivider(),
            _buildToolbarButton(Icons.link),
            _buildToolbarButton(Icons.image),
            _buildToolbarButton(Icons.table_chart),
            _buildToolbarButton(Icons.code),
            _buildToolbarDivider(),
            _buildToolbarButton(Icons.title),
            _buildToolbarButton(Icons.format_quote),
          ],
        ),
      ),
    );
  }
  
  // 构建工具栏按钮
  Widget _buildToolbarButton(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: IconButton(
        icon: Icon(icon, color: Colors.grey.shade600),
        onPressed: () {
          // 实现相应的格式化功能
        },
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
  
  // 构建工具栏分隔线
  Widget _buildToolbarDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.shade200,
    );
  }
  
  // 构建内容输入
  Widget _buildContentInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        minLines: 10,
        decoration: const InputDecoration(
          hintText: '开始编写笔记内容...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
  
  // 构建附件区域
  Widget _buildAttachmentArea() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '附件',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_attachments.length}/5',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 添加附件按钮
              GestureDetector(
                onTap: _addAttachment,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '添加',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建底部选项
  Widget _buildBottomOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          // 隐私设置
          GestureDetector(
            onTap: _togglePrivacy,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '收藏',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _isFavorite ? '已收藏' : '未收藏',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 提醒
          GestureDetector(
            onTap: _toggleReminder,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '提醒',
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '不提醒',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建自动保存提示
  Widget _buildAutoSaveHint() {
    final now = DateFormat('HH:mm').format(DateTime.now());
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            Text(
              '笔记将自动保存至云端',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '上次保存时间：$now',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 