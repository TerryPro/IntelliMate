import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:provider/provider.dart';

class EditMemoScreen extends StatefulWidget {
  const EditMemoScreen({Key? key}) : super(key: key);

  @override
  State<EditMemoScreen> createState() => _EditMemoScreenState();
}

class _EditMemoScreenState extends State<EditMemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  String _selectedCategory = '工作';
  String _selectedPriority = '中';
  bool _isCompleted = false;
  bool _isPinned = false;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  
  Memo? _memo;
  String? _memoId;
  
  final List<String> _categories = ['工作', '学习', '生活', '其他'];
  final List<String> _priorities = ['高', '中', '低'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _memoId = ModalRoute.of(context)?.settings.arguments as String?;
    if (_memoId != null && _isLoading) {
      _loadMemo(_memoId!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadMemo(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      final memo = await memoProvider.getMemoById(id);
      
      if (memo != null && mounted) {
        setState(() {
          _memo = memo;
          _titleController.text = memo.title;
          _contentController.text = memo.content;
          _selectedCategory = memo.category ?? '工作';
          _selectedPriority = memo.priority;
          _isCompleted = memo.isCompleted;
          _isPinned = memo.isPinned;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('找不到备忘录')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载备忘录失败: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateMemo() async {
    if (!_formKey.currentState!.validate() || _memo == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      
      final updatedMemo = Memo(
        id: _memo!.id,
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
        isCompleted: _isCompleted,
        isPinned: _isPinned,
        createdAt: _memo!.createdAt,
        updatedAt: DateTime.now(),
        date: _memo!.date,
      );
      
      final success = await memoProvider.updateMemo(updatedMemo);

      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新备忘录失败，请重试')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteMemo() async {
    if (_memo == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除备忘录'),
        content: const Text('确定要删除这个备忘录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed != true || !mounted) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      final success = await memoProvider.deleteMemo(_memo!.id);
      
      if (success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除备忘录失败，请重试')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑备忘录'),
        actions: [
          if (!_isLoading && !_isSaving && !_isDeleting)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteMemo,
            ),
          if (!_isLoading && !_isSaving && !_isDeleting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateMemo,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSaving || _isDeleting
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: '标题',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入标题';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(
                            labelText: '内容',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入内容';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '分类',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _categories.map((category) {
                            return ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '优先级',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _priorities.map((priority) {
                            Color chipColor;
                            switch (priority) {
                              case '高':
                                chipColor = Colors.red.shade100;
                                break;
                              case '中':
                                chipColor = Colors.orange.shade100;
                                break;
                              case '低':
                              default:
                                chipColor = Colors.green.shade100;
                                break;
                            }
                            
                            return ChoiceChip(
                              label: Text(priority),
                              selected: _selectedPriority == priority,
                              selectedColor: chipColor,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedPriority = priority;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text('已完成'),
                          value: _isCompleted,
                          onChanged: (value) {
                            setState(() {
                              _isCompleted = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('置顶'),
                          value: _isPinned,
                          onChanged: (value) {
                            setState(() {
                              _isPinned = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_memo != null)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '创建时间: ${_formatDate(_memo!.createdAt)}\n最后更新: ${_formatDate(_memo!.updatedAt)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 