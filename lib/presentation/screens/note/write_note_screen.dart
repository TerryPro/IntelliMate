import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WriteNoteScreen extends StatefulWidget {
  const WriteNoteScreen({super.key});

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
  Note? _note;
  
  // 附件列表
  final List<String> _attachments = [];
  
  // 分类列表
  final List<String> _categories = ['工作', '学习', '生活', '灵感'];
  
  // 标签列表
  final List<String> _availableTags = ['重要', '技术', '会议', '计划', '创意', '问题'];
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNoteData();
    });
  }
  
  void _initNoteData() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Note) {
      _note = args;
      setState(() {
        _isEditing = true;
        _titleController.text = _note!.title;
        _contentController.text = _note!.content;
        if (_note!.category != null) {
          _selectedCategory = _note!.category!;
        }
        if (_note!.tags != null) {
          _selectedTags = List.from(_note!.tags!);
        }
        _isFavorite = _note!.isFavorite;
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _saveNote() async {
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
      
      if (_isEditing && _note != null) {
        final updatedNote = Note(
          id: _note!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          category: _selectedCategory,
          tags: _selectedTags.isEmpty ? null : _selectedTags,
          isFavorite: _isFavorite,
          createdAt: _note!.createdAt,
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
        final newNote = Note(
          id: '',
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
  
  void _addAttachment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('添加附件功能尚未实现'),
      ),
    );
  }
  
  void _togglePrivacy() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }
  
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
          _buildCustomAppBar(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleInput(),
                  
                  _buildCategorySelector(),
                  
                  _buildEditToolbar(),
                  
                  _buildContentInput(),
                  
                  _buildAttachmentArea(),
                  
                  _buildBottomOptions(),
                  
                  _buildAutoSaveHint(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
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
              Text(
                _isEditing ? '编辑笔记' : '新建笔记',
                style: const TextStyle(
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
  
  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
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
  
  Widget _buildToolbarDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.shade200,
    );
  }
  
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