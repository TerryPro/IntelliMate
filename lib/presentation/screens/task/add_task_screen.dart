import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatefulWidget {
  final String? taskId;
  
  const AddTaskScreen({super.key, this.taskId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _dueDate = DateTime.now();
  String _dueDateText = '今天';
  
  int _priority = 3; // 默认高优先级
  String _category = '工作';
  String? _reminder = '截止当天 09:00';
  String? _repeatOption = '不重复';
  
  final List<String> _reminderOptions = ['无', '截止当天 09:00', '提前1小时', '提前1天', '自定义'];
  final List<String> _repeatOptions = ['不重复', '每天', '每周', '每月', '每年'];
  
  // 子任务列表
  final List<String> _subtasks = [];
  final TextEditingController _newSubtaskController = TextEditingController();
  
  bool _isLoading = true;
  bool _isEditing = false;
  Task? _existingTask;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.taskId != null;
    
    // 如果是编辑模式，加载现有任务数据
    if (_isEditing) {
      _loadExistingTask();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 加载现有任务数据
  Future<void> _loadExistingTask() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final task = await taskProvider.getTaskById(widget.taskId!);
      
      if (task != null) {
        setState(() {
          _existingTask = task;
          
          // 填充表单数据
          _titleController.text = task.title;
          if (task.description != null) {
            _descriptionController.text = task.description!;
          }
          
          if (task.dueDate != null) {
            _dueDate = task.dueDate;
            _updateDueDateText();
          } else {
            _dueDate = null;
            _dueDateText = '无截止日期';
          }
          
          if (task.priority != null) {
            _priority = task.priority!;
          }
          
          if (task.category != null) {
            _category = task.category!;
          }
          
          // 这里可以加载子任务，但当前Task实体类没有子任务字段
        });
      } else {
        setState(() {
          _errorMessage = '找不到指定任务';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载任务失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _newSubtaskController.dispose();
    super.dispose();
  }
  
  // 更新截止日期文本
  void _updateDueDateText() {
    if (_dueDate == null) {
      _dueDateText = '无截止日期';
      return;
    }
    
    if (isSameDay(_dueDate!, DateTime.now())) {
      _dueDateText = '今天';
    } else if (isSameDay(_dueDate!, DateTime.now().add(const Duration(days: 1)))) {
      _dueDateText = '明天';
    } else {
      _dueDateText = '${_dueDate!.year}年${_dueDate!.month}月${_dueDate!.day}日';
    }
  }
  
  // 保存任务
  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        bool success = false;
        
        if (_isEditing && _existingTask != null) {
          // 编辑现有任务
          final updatedTask = Task(
            id: _existingTask!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text.trim(),
            dueDate: _dueDate,
            isCompleted: _existingTask!.isCompleted,
            category: _category,
            priority: _priority,
            createdAt: _existingTask!.createdAt,
            updatedAt: DateTime.now(),
          );
          
          success = await taskProvider.updateTask(updatedTask);
        } else {
          // 创建新任务
          final task = await taskProvider.createTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text.trim(),
            dueDate: _dueDate,
            isCompleted: false,
            category: _category,
            priority: _priority,
          );
          
          success = task != null;
        }
        
        if (success && mounted) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = '保存任务失败';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = '保存任务时出错: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  // 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // 允许选择过去的日期以支持编辑
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3ECABB),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _updateDueDateText();
      });
    }
  }
  
  // 清除截止日期
  void _clearDueDate() {
    setState(() {
      _dueDate = null;
      _dueDateText = '无截止日期';
    });
  }
  
  // 判断两个日期是否是同一天
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  // 添加子任务
  void _addSubtask() {
    if (_newSubtaskController.text.isNotEmpty) {
      setState(() {
        _subtasks.add(_newSubtaskController.text);
        _newSubtaskController.clear();
      });
    }
  }

  // 删除子任务
  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(_isEditing ? '编辑任务' : '添加任务'),
          backgroundColor: const Color(0xFF3ECABB),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(_isEditing ? '编辑任务' : '添加任务'),
          backgroundColor: const Color(0xFF3ECABB),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_isEditing) {
                    _loadExistingTask();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(_isEditing ? '重试' : '返回'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
          // 表单内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 任务标题
                    _buildTitleSection(),
                    const SizedBox(height: 20),
                    
                    // 任务描述
                    _buildDescriptionSection(),
                    const SizedBox(height: 20),
                    
                    // 截止日期
                    _buildDueDateSection(),
                    const SizedBox(height: 20),
                    
                    // 优先级
                    _buildPrioritySection(),
                    const SizedBox(height: 20),
                    
                    // 提醒
                    _buildReminderSection(),
                    const SizedBox(height: 20),
                    
                    // 重复
                    _buildRepeatSection(),
                    const SizedBox(height: 20),
                    
                    // 任务分类
                    _buildCategorySection(),
                    const SizedBox(height: 20),
                    
                    // 子任务
                    _buildSubtasksSection(),
                    const SizedBox(height: 20),
                    
                    // 附件
                    _buildAttachmentsSection(),
                    const SizedBox(height: 40),
                  ],
                ),
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
        color: Color(0xFF3ECABB),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isEditing ? '编辑任务' : '添加任务',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (_isEditing)
                GestureDetector(
                  onTap: _showDeleteConfirmation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: _saveTask,
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
        ],
      ),
    );
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个任务吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTask();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
  
  // 删除任务
  Future<void> _deleteTask() async {
    if (!_isEditing || _existingTask == null) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final success = await taskProvider.deleteTask(_existingTask!.id);
      
      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已删除')),
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = '删除任务失败，请重试';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('删除任务失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '删除任务失败: $e';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除任务失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // 构建标题部分
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务标题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: '请输入任务标题',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3ECABB), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入任务标题';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  // 构建描述部分
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '添加任务描述...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3ECABB), width: 1),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
  
  // 构建截止日期部分
  Widget _buildDueDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '截止日期',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF3ECABB),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _dueDateText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_dueDate != null) 
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearDueDate,
              ),
          ],
        ),
      ],
    );
  }
  
  // 构建优先级部分
  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '优先级',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _priority = 3;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _priority == 3 ? const Color(0xFF3ECABB) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _priority == 3 ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '高',
                        style: TextStyle(
                          color: _priority == 3 ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _priority = 2;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _priority == 2 ? const Color(0xFF3ECABB) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _priority == 2 ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '中',
                        style: TextStyle(
                          color: _priority == 2 ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _priority = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _priority == 1 ? const Color(0xFF3ECABB) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _priority == 1 ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '低',
                        style: TextStyle(
                          color: _priority == 1 ? Colors.white : Colors.grey.shade700,
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
    );
  }
  
  // 构建提醒部分
  Widget _buildReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '提醒',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // 显示提醒选项
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _reminderOptions.map((option) {
                      return ListTile(
                        title: Text(option),
                        trailing: option == _reminder
                            ? const Icon(Icons.check, color: Color(0xFF3ECABB))
                            : null,
                        onTap: () {
                          setState(() {
                            _reminder = option;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF3ECABB),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _reminder ?? '选择提醒时间',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建重复部分
  Widget _buildRepeatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '重复',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // 显示重复选项
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _repeatOptions.map((option) {
                      return ListTile(
                        title: Text(option),
                        trailing: option == _repeatOption
                            ? const Icon(Icons.check, color: Color(0xFF3ECABB))
                            : null,
                        onTap: () {
                          setState(() {
                            _repeatOption = option;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.repeat,
                  color: Color(0xFF3ECABB),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _repeatOption ?? '不重复',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建任务分类部分
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务分类',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCategoryChip('工作', Icons.work),
            _buildCategoryChip('学习', Icons.school),
            _buildCategoryChip('个人', Icons.person),
            _buildCategoryChip('家庭', Icons.home),
            _buildCategoryChip('购物', Icons.shopping_cart),
            _buildCategoryChip('旅行', Icons.flight),
          ],
        ),
      ],
    );
  }
  
  // 构建分类选项
  Widget _buildCategoryChip(String label, IconData icon) {
    final isSelected = _category == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _category = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3ECABB) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建子任务部分
  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '子任务',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: _addSubtask,
              icon: const Icon(
                Icons.add,
                size: 16,
                color: Color(0xFF3ECABB),
              ),
              label: const Text(
                '添加',
                style: TextStyle(
                  color: Color(0xFF3ECABB),
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // 已有子任务
              ..._subtasks.asMap().entries.map((entry) {
                final index = entry.key;
                final subtask = entry.value;
                return _buildSubtaskItem(subtask, index);
              }),
              
              // 添加新子任务输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3ECABB),
                          width: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _newSubtaskController,
                        decoration: const InputDecoration(
                          hintText: '添加子任务...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _addSubtask(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 构建子任务项
  Widget _buildSubtaskItem(String subtask, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF3ECABB),
                width: 2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              subtask,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeSubtask(index),
          ),
        ],
      ),
    );
  }
  
  // 构建附件部分
  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '附件',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '0/5',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryWithOpacity10,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload,
                  color: Color(0xFF3ECABB),
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '点击上传附件',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 