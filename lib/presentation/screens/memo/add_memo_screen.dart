import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddMemoScreen extends StatefulWidget {
  const AddMemoScreen({super.key, this.memo});

  final Memo? memo;

  @override
  State<AddMemoScreen> createState() => _AddMemoScreenState();
}

class _AddMemoScreenState extends State<AddMemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedPriority = '中';
  String _selectedCategory = '工作';
  bool _isCompleted = false;
  bool _isPinned = false;
  bool _isLoading = false;
  
  // 优先级选项
  final List<String> _priorities = ['高', '中', '低'];
  
  // 分类选项
  final List<String> _categories = ['工作', '学习', '生活', '健康', '其他'];
  
  @override
  void initState() {
    super.initState();
    
    // 如果是编辑现有备忘录，则填充数据
    if (widget.memo != null) {
      _titleController.text = widget.memo!.title;
      _contentController.text = widget.memo!.content;
      _selectedDate = widget.memo!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.memo!.date);
      _selectedPriority = widget.memo!.priority;
      _selectedCategory = widget.memo!.category ?? '工作';
      _isCompleted = widget.memo!.isCompleted;
      _isPinned = widget.memo!.isPinned;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _saveMemo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final memoProvider = Provider.of<MemoProvider>(context, listen: false);
      
      // 合并日期和时间
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      final success = await memoProvider.createMemo(
        title: _titleController.text,
        content: _contentController.text,
        date: dateTime,
        category: _selectedCategory,
        priority: _selectedPriority,
        isPinned: _isPinned,
        isCompleted: _isCompleted,
        completedAt: _isCompleted ? DateTime.now() : null,
      );

      if (success != null && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存备忘录失败，请重试')),
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
          _isLoading = false;
        });
      }
    }
  }
  
  // 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('zh'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // 选择时间
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 自定义顶部导航栏
                _buildCustomAppBar(),
                
                // 主体内容
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题输入
                          _buildTitleInput(),
                          
                          const SizedBox(height: 24),
                          
                          // 内容输入
                          _buildContentInput(),
                          
                          const SizedBox(height: 24),
                          
                          // 日期时间选择
                          _buildDateTimeSelector(),
                          
                          const SizedBox(height: 24),
                          
                          // 优先级选择
                          _buildPrioritySelector(),
                          
                          const SizedBox(height: 24),
                          
                          // 分类选择
                          _buildCategorySelector(),
                          
                          const SizedBox(height: 24),
                          
                          // 额外选项
                          _buildExtraOptions(),
                          
                          const SizedBox(height: 40),
                          
                          // 保存按钮
                          _buildSaveButton(),
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
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
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
              Text(
                widget.memo == null ? '添加备忘录' : '编辑备忘录',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _saveMemo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('保存'),
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
        labelText: '标题',
        hintText: '请输入备忘标题',
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
          return '请输入标题';
        }
        return null;
      },
    );
  }

  // 构建内容输入
  Widget _buildContentInput() {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        labelText: '内容',
        hintText: '请输入备忘内容',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 6,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入内容';
        }
        return null;
      },
    );
  }

  // 构建日期时间选择器
  Widget _buildDateTimeSelector() {
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
            '日期和时间',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('yyyy年MM月dd日').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.access_time, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建优先级选择器
  Widget _buildPrioritySelector() {
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
            '优先级',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _priorities.map((priority) {
              final isSelected = priority == _selectedPriority;
              Color color;
              Color textColor;
              
              switch (priority) {
                case '高':
                  color = isSelected ? const Color(0xFFDC2626) : const Color(0xFFFEE2E2);
                  textColor = isSelected ? Colors.white : const Color(0xFFDC2626);
                  break;
                case '中':
                  color = isSelected ? const Color(0xFFD97706) : const Color(0xFFFEF3C7);
                  textColor = isSelected ? Colors.white : const Color(0xFFD97706);
                  break;
                case '低':
                  color = isSelected ? const Color(0xFF16A34A) : const Color(0xFFDCFCE7);
                  textColor = isSelected ? Colors.white : const Color(0xFF16A34A);
                  break;
                default:
                  color = isSelected ? Colors.grey[600]! : Colors.grey[200]!;
                  textColor = isSelected ? Colors.white : Colors.grey[600]!;
              }
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
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
            '分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((category) {
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
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

  // 构建额外选项
  Widget _buildExtraOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('置顶备忘'),
            subtitle: const Text('将备忘显示在置顶区域'),
            secondary: const Icon(Icons.push_pin),
            value: _isPinned,
            activeColor: AppColors.primary,
            onChanged: (bool value) {
              setState(() {
                _isPinned = value;
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('标记为已完成'),
            subtitle: const Text('将备忘标记为已完成状态'),
            secondary: const Icon(Icons.check_circle),
            value: _isCompleted,
            activeColor: AppColors.primary,
            onChanged: (bool value) {
              setState(() {
                _isCompleted = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // 构建保存按钮
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveMemo,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '保存备忘',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 