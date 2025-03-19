import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/task.dart';
import 'package:intellimate/presentation/providers/task_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
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

  final List<String> _reminderOptions = [
    '无',
    '截止当天 09:00',
    '提前1小时',
    '提前1天',
    '自定义'
  ];

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
    } else if (isSameDay(
        _dueDate!, DateTime.now().add(const Duration(days: 1)))) {
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
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text.trim(),
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
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text.trim(),
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
      firstDate:
          DateTime.now().subtract(const Duration(days: 365)), // 允许选择过去的日期以支持编辑
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('错误'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          CustomEditorAppBar(
            title: _isEditing ? '编辑任务' : '添加任务',
            onBackTap: () => Navigator.pop(context),
            onSaveTap: _saveTask,
            isLoading: _isLoading,
          ),

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

                    // 任务分类
                    _buildCategorySection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    color: _priority == 3
                        ? const Color(0xFF3ECABB)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _priority == 3
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '高',
                        style: TextStyle(
                          color: _priority == 3
                              ? Colors.white
                              : Colors.grey.shade700,
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
                    color: _priority == 2
                        ? const Color(0xFF3ECABB)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _priority == 2
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '中',
                        style: TextStyle(
                          color: _priority == 2
                              ? Colors.white
                              : Colors.grey.shade700,
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
                    color: _priority == 1
                        ? const Color(0xFF3ECABB)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: _priority == 1
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '低',
                        style: TextStyle(
                          color: _priority == 1
                              ? Colors.white
                              : Colors.grey.shade700,
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
            _buildCategoryChip('个人', Icons.person),
            _buildCategoryChip('家庭', Icons.home),
            _buildCategoryChip('工作', Icons.work),
            _buildCategoryChip('学习', Icons.school),
            _buildCategoryChip('购物', Icons.shopping_cart),
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
}
