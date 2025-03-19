import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/core/memo_config.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class EditMemoScreen extends StatefulWidget {
  const EditMemoScreen({super.key});

  @override
  State<EditMemoScreen> createState() => _EditMemoScreenState();
}

class _EditMemoScreenState extends State<EditMemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = MemoConfig.categories[0];
  bool _isLoading = true;
  bool _isSaving = false;
  // 删除_isDeleting状态变量

  Memo? _memo;
  String? _memoId;

  final List<String> _categories = MemoConfig.categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _memoId = ModalRoute.of(context)?.settings.arguments as String?;
    if (_memoId != null && _isLoading) {
      _loadMemo(_memoId!);
    } else if (_memoId == null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadMemo(String id) async {
    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      final memo = await memoProvider.getMemoById(id);

      if (memo != null) {
        setState(() {
          _memo = memo;
          _titleController.text = memo.title;
          _contentController.text = memo.content;
          _selectedCategory = memo.category ?? '工作';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('未找到备忘录'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载错误: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _createMemo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);

      final success = await memoProvider.createMemo(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
      );

      if (success != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备忘录创建成功'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('创建失败，请重试'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发生错误: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
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

  Future<void> _updateMemo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_memo == null) {
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
        createdAt: _memo!.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await memoProvider.updateMemo(updatedMemo);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备忘录更新成功'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('更新失败，请重试'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发生错误: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
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

  @override
  Widget build(BuildContext context) {
    final isEditing = _memo != null;
    final title = isEditing ? '编辑备忘' : '新建备忘';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // 使用CustomEditorAppBar替换自定义顶部导航栏
              CustomEditorAppBar(
                title: title,
                onBackTap: () => Navigator.pop(context),
                onSaveTap: isEditing ? _updateMemo : _createMemo,
                isLoading: _isSaving,
                actions: isEditing ? [] : null,
              ),

              // 主体内容
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题输入
                              _buildFormLabel('标题'),
                              const SizedBox(height: 8),
                              _buildTitleInput(),
                              const SizedBox(height: 20),

                              // 类别选择
                              _buildFormLabel('类别'),
                              const SizedBox(height: 8),
                              _buildCategorySelector(),
                              const SizedBox(height: 20),

                              // 内容输入
                              _buildFormLabel('内容'),
                              const SizedBox(height: 8),
                              _buildContentInput(),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),

          // 加载指示器
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建标题输入
  Widget _buildTitleInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: '请输入备忘录标题',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '请输入标题';
          }
          return null;
        },
      ),
    );
  }

  // 构建类别选择器
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: MemoConfig.categories.map((category) {
            final isSelected = category == _selectedCategory;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? MemoConfig.getCategoryColor(category)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MemoConfig.getCategoryIcon(category),
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      MemoConfig.getCategoryText(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 构建内容输入
  Widget _buildContentInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _contentController,
        decoration: InputDecoration(
          hintText: '请输入备忘录内容（可选）',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF333333),
          height: 1.5,
        ),
        maxLines: 10,
        validator: (value) {
          return null;
        },
      ),
    );
  }

  // 构建表单标签
  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4B5563),
      ),
    );
  }
}
