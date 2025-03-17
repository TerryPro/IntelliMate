import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/presentation/providers/note_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 自定义顶部导航栏
          CustomEditorAppBar(
            title: _isEditing ? '编辑笔记' : '新建笔记',
            onBackTap: () => Navigator.pop(context),
            onSaveTap: _saveNote,
            isLoading: _isLoading,
          ),
          
          // 笔记内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleInput(),
                  const SizedBox(height: 16),
                  _buildContentInput(),
                  const SizedBox(height: 20),
                  _buildTagsSection(),
                  const SizedBox(height: 20),
                  _buildCategorySection(),
                ],
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
  
  Widget _buildTagsSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
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
  
  Widget _buildCategorySection() {
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
        ],
      ),
    );
  }
} 