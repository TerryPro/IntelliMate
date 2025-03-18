import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/presentation/providers/goal_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddGoalScreen extends StatefulWidget {
  final Goal? goal; // 如果为null，则是添加模式；否则是编辑模式

  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _category = '周目标';
  String _status = '未开始';
  double _progress = 0.0;

  bool _isLoading = false;
  final bool _isDeleting = false;

  // 分类列表
  final List<String> _categories = ['周目标', '月目标', '年度目标'];

  // 状态选项
  final List<String> _statusOptions = ['未开始', '进行中', '已完成', '已放弃', '落后'];

  // 是否是编辑模式
  bool get _isEditMode => widget.goal != null;

  @override
  void initState() {
    super.initState();

    // 如果是编辑模式，初始化数据
    if (_isEditMode) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description ?? '';
      _category = widget.goal!.category ?? '周目标';
      _progress = widget.goal!.progress;
      _status = widget.goal!.status;
      _startDate = widget.goal!.startDate;
      _endDate = widget.goal!.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 保存目标
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);

      if (_isEditMode) {
        // 更新现有目标
        final updatedGoal = Goal(
          id: widget.goal!.id,
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          startDate: _startDate,
          endDate: _endDate,
          progress: _progress,
          status: _status,
          category: _category,
          milestones: widget.goal!.milestones,
          createdAt: widget.goal!.createdAt,
          updatedAt: DateTime.now(),
        );

        await goalProvider.updateGoal(updatedGoal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目标更新成功')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // 创建新目标
        final newGoal = Goal(
          id: const Uuid().v4(),
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          startDate: _startDate,
          endDate: _endDate,
          progress: 0,
          status: '未开始',
          category: _category,
          milestones: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await goalProvider.createGoal(newGoal);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('目标创建成功')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 选择开始日期
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // 如果结束日期早于开始日期，则清除结束日期
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      });
    }
  }

  // 选择结束日期
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 7)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  // 清除结束日期
  void _clearEndDate() {
    setState(() {
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isDeleting) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          CustomEditorAppBar(
            title: _isEditMode ? '编辑目标' : '添加目标',
            onBackTap: () => Navigator.pop(context),
            onSaveTap: _saveGoal,
            isLoading: _isLoading,
            actions: _isEditMode ? [] : null,
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
                    _buildTitleInput(),
                    const SizedBox(height: 20),
                    _buildDescriptionInput(),
                    const SizedBox(height: 20),
                    _buildCategoryInput(),
                    const SizedBox(height: 20),
                    _buildDateInput(),
                    const SizedBox(height: 20),
                    if (_isEditMode) ...[
                      _buildProgressInput(),
                      const SizedBox(height: 20),
                      _buildStatusInput(),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建标题输入
  Widget _buildTitleInput() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: '目标标题',
        hintText: '请输入目标标题',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入目标标题';
        }
        return null;
      },
    );
  }

  // 构建描述输入
  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: '目标描述',
        hintText: '请输入目标描述',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 4,
    );
  }

  // 构建分类选择器
  Widget _buildCategoryInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '目标分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: _categories.map((category) {
              final isSelected = category == _category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _category = category;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 构建日期输入
  Widget _buildDateInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '日期设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '开始日期',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectStartDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy年MM月dd日').format(_startDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '结束日期',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (_endDate != null)
                TextButton(
                  onPressed: _clearEndDate,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('清除'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectEndDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _endDate != null
                        ? DateFormat('yyyy年MM月dd日').format(_endDate!)
                        : '无截止日期',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建状态选择器
  Widget _buildStatusInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '目标状态',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _statusOptions.map((status) {
              final isSelected = status == _status;
              Color color;
              Color textColor;

              switch (status) {
                case '未开始':
                  color = isSelected ? Colors.grey[700]! : Colors.grey[200]!;
                  textColor = isSelected ? Colors.white : Colors.grey[700]!;
                  break;
                case '进行中':
                  color = isSelected ? Colors.blue[600]! : Colors.blue[50]!;
                  textColor = isSelected ? Colors.white : Colors.blue[600]!;
                  break;
                case '已完成':
                  color = isSelected ? Colors.green[600]! : Colors.green[50]!;
                  textColor = isSelected ? Colors.white : Colors.green[600]!;
                  break;
                case '已放弃':
                  color = isSelected ? Colors.red[600]! : Colors.red[50]!;
                  textColor = isSelected ? Colors.white : Colors.red[600]!;
                  break;
                case '落后':
                  color = isSelected ? Colors.orange[600]! : Colors.orange[50]!;
                  textColor = isSelected ? Colors.white : Colors.orange[600]!;
                  break;
                default:
                  color = isSelected ? Colors.grey[700]! : Colors.grey[200]!;
                  textColor = isSelected ? Colors.white : Colors.grey[700]!;
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _status = status;
                    // 如果状态是已完成，则进度设为100%
                    if (status == '已完成') {
                      _progress = 100.0;
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 构建进度选择器
  Widget _buildProgressInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '完成进度',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_progress.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              thumbColor: AppColors.primary,
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey[200],
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _progress,
              min: 0,
              max: 100,
              divisions: 100,
              label: _progress.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _progress = value;
                  // 如果进度为100%，则状态设为已完成
                  if (value == 100) {
                    _status = '已完成';
                  } else if (_status == '已完成') {
                    _status = '进行中';
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
