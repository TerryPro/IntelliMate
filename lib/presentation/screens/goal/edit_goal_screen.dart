import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/goal.dart';
import 'package:intellimate/presentation/providers/goal_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditGoalScreen extends StatefulWidget {
  final Goal goal;

  const EditGoalScreen({super.key, required this.goal});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late String _selectedCategory;
  late double _progress;
  late String _status;
  late DateTime _startDate;
  late DateTime? _endDate;
  
  bool _isLoading = false;
  bool _isDeleting = false;
  
  // 分类列表
  final List<String> _categories = ['周目标', '月目标', '年度目标'];
  
  // 状态选项
  final List<String> _statusOptions = ['未开始', '进行中', '已完成', '已放弃', '落后'];
  
  @override
  void initState() {
    super.initState();
    
    // 初始化数据
    _titleController.text = widget.goal.title;
    _descriptionController.text = widget.goal.description ?? '';
    _selectedCategory = widget.goal.category ?? '周目标';
    _progress = widget.goal.progress;
    _status = widget.goal.status;
    _startDate = widget.goal.startDate;
    _endDate = widget.goal.endDate;
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
      
      final updatedGoal = Goal(
        id: widget.goal.id,
        title: _titleController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        startDate: _startDate,
        endDate: _endDate,
        progress: _progress,
        status: _status,
        category: _selectedCategory,
        milestones: widget.goal.milestones,
        createdAt: widget.goal.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await goalProvider.updateGoal(updatedGoal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目标更新成功')),
        );
        Navigator.pop(context);
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
  
  // 删除目标
  Future<void> _deleteGoal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个目标吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      await goalProvider.deleteGoal(widget.goal.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('目标已删除')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
        setState(() {
          _isDeleting = false;
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildCustomAppBar(),
          
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleInput(),
                    
                    const SizedBox(height: 20),
                    
                    _buildDescriptionInput(),
                    
                    const SizedBox(height: 20),
                    
                    _buildCategorySelector(),
                    
                    const SizedBox(height: 20),
                    
                    _buildStatusSelector(),
                    
                    const SizedBox(height: 20),
                    
                    _buildProgressSelector(),
                    
                    const SizedBox(height: 20),
                    
                    _buildDateSelector(),
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                '编辑目标',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _isDeleting ? null : _deleteGoal,
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete,
                    color: _isDeleting ? Colors.grey : Colors.white,
                    size: 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
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
  Widget _buildCategorySelector() {
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
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
  
  // 构建状态选择器
  Widget _buildStatusSelector() {
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
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  Widget _buildProgressSelector() {
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
              overlayColor: AppColors.primary.withOpacity(0.2),
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
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建日期选择器
  Widget _buildDateSelector() {
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
                    _endDate != null ? DateFormat('yyyy年MM月dd日').format(_endDate!) : '无截止日期',
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
} 