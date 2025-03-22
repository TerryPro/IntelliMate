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

  DateTimeRange? _dateRange;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _category = '周目标';
  String _status = '未开始';
  double _progress = 0.0;

  bool _isLoading = false;
  final bool _isDeleting = false;

  // 分类列表
  final List<String> _categories = ['周目标', '月目标', '季目标', '年目标'];

  // 当前选择的周
  DateTime _selectedWeekStart =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  // 当前选择的月
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  // 当前选择的季度
  int _selectedQuarter = ((DateTime.now().month - 1) ~/ 3) + 1;
  int _selectedQuarterYear = DateTime.now().year;
  // 当前年份
  final int _currentYear = DateTime.now().year;

  // 状态选项
  final List<String> _statusOptions = ['未开始', '进行中', '已完成', '已放弃', '落后'];

  // 是否是编辑模式
  bool get _isEditMode => widget.goal != null;

  @override
  void initState() {
    super.initState();

    // 如果是编辑模式，初始化数据
    _updateDefaultDateRange();
    if (_isEditMode) {
      _titleController.text = widget.goal!.title;
      _descriptionController.text = widget.goal!.description ?? '';
      _category = widget.goal!.category ?? '周目标';
      _progress = widget.goal!.progress;
      _status = widget.goal!.status;
      _startDate = widget.goal!.startDate;
      _endDate = widget.goal!.endDate;

      // 设置选择器的初始值
      if (_category == '周目标') {
        _selectedWeekStart =
            _startDate.subtract(Duration(days: _startDate.weekday - 1));
      } else if (_category == '月目标') {
        _selectedMonth = DateTime(_startDate.year, _startDate.month);
      } else if (_category == '季目标') {
        _selectedQuarter = ((_startDate.month - 1) ~/ 3) + 1;
        _selectedQuarterYear = _startDate.year;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 验证时间范围
  // 更新默认日期范围
  void _updateDefaultDateRange() {
    final now = DateTime.now();

    if (_category == '周目标') {
      final startOfWeek = _selectedWeekStart;
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      _dateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
    } else if (_category == '月目标') {
      final startOfMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endOfMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      _dateRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
    } else if (_category == '季目标') {
      final quarterStartMonth = (_selectedQuarter - 1) * 3 + 1;
      final startOfQuarter =
          DateTime(_selectedQuarterYear, quarterStartMonth, 1);
      final endOfQuarter =
          DateTime(_selectedQuarterYear, quarterStartMonth + 3, 0);
      _dateRange = DateTimeRange(start: startOfQuarter, end: endOfQuarter);
    } else if (_category == '年目标') {
      // 年目标设置为本年开始到本年结束
      final startOfYear = DateTime(_currentYear, 1, 1);
      final endOfYear = DateTime(_currentYear, 12, 31, 23, 59, 59);
      _dateRange = DateTimeRange(start: startOfYear, end: endOfYear);
    } else {
      // 默认情况
      _dateRange = DateTimeRange(
        start: now,
        end: now.add(const Duration(days: 7)),
      );
    }

    _startDate = _dateRange!.start;
    _endDate = _dateRange!.end;
  }

  // 日期格式化方法
  String _getDateText(DateTime? date) {
    return date != null ? DateFormat('yyyy/MM/dd').format(date) : '选择日期';
  }

  bool _validateDateRange() {
    if (_dateRange == null) return true;

    final currentYear = DateTime.now().year;
    if (_startDate.year != currentYear || _endDate?.year != currentYear) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('时间范围必须在本年度内')));
      return false;
    }
    return true;
  }

  // 保存目标
  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate() || !_validateDateRange()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);

      _updateDefaultDateRange();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
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

  // 选择开始日期
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(_currentYear, 1, 1), // 限制在本年
      lastDate: DateTime(_currentYear, 12, 31), // 限制在本年
      locale: const Locale('zh'), // 使用中文
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
      lastDate: DateTime(_currentYear, 12, 31), // 限制在本年
      locale: const Locale('zh'), // 使用中文
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

  // 选择周
  void _selectWeek(DateTime date) {
    setState(() {
      // 计算所选日期所在周的周一
      _selectedWeekStart = date.subtract(Duration(days: date.weekday - 1));
      _updateDefaultDateRange();
    });
  }

  // 选择月份
  void _selectMonth(DateTime date) {
    setState(() {
      _selectedMonth = DateTime(date.year, date.month);
      _updateDefaultDateRange();
    });
  }

  // 选择季度
  void _selectQuarter(int quarter, int year) {
    setState(() {
      _selectedQuarter = quarter;
      _selectedQuarterYear = year;
      _updateDefaultDateRange();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目标标题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
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
        ),
      ],
    );
  }

  // 构建描述输入
  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '目标描述',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
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
        ),
      ],
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
                    _updateDefaultDateRange();
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

          // 根据目标分类显示不同的日期选择器
          if (_category == '周目标') ...[
            _buildWeekSelector(),
            const SizedBox(height: 16),
          ] else if (_category == '月目标') ...[
            _buildMonthSelector(),
            const SizedBox(height: 16),
          ] else if (_category == '季目标') ...[
            _buildQuarterSelector(),
            const SizedBox(height: 16),
          ],

          const Text(
            '开始日期',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _category == '周目标' ||
                    _category == '月目标' ||
                    _category == '季目标' ||
                    _category == '年目标'
                ? null
                : _selectStartDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: _category == '周目标' ||
                        _category == '月目标' ||
                        _category == '季目标' ||
                        _category == '年目标'
                    ? Colors.grey[100]
                    : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getDateText(_startDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: _category == '周目标' ||
                              _category == '月目标' ||
                              _category == '季目标' ||
                              _category == '年目标'
                          ? Colors.grey[700]
                          : Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: _category == '周目标' ||
                            _category == '月目标' ||
                            _category == '季目标' ||
                            _category == '年目标'
                        ? Colors.grey[400]
                        : Colors.black,
                  ),
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
              if (_endDate != null &&
                  !(_category == '周目标' ||
                      _category == '月目标' ||
                      _category == '季目标' ||
                      _category == '年目标'))
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
            onTap: _category == '周目标' ||
                    _category == '月目标' ||
                    _category == '季目标' ||
                    _category == '年目标'
                ? null
                : _selectEndDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: _category == '周目标' ||
                        _category == '月目标' ||
                        _category == '季目标' ||
                        _category == '年目标'
                    ? Colors.grey[100]
                    : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _endDate != null ? _getDateText(_endDate!) : '无截止日期',
                    style: TextStyle(
                      fontSize: 16,
                      color: _category == '周目标' ||
                              _category == '月目标' ||
                              _category == '季目标' ||
                              _category == '年目标'
                          ? Colors.grey[700]
                          : Colors.black,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: _category == '周目标' ||
                            _category == '月目标' ||
                            _category == '季目标' ||
                            _category == '年目标'
                        ? Colors.grey[400]
                        : Colors.black,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建周选择器
  Widget _buildWeekSelector() {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final isCurrentWeek = _selectedWeekStart.year == currentWeekStart.year &&
        _selectedWeekStart.month == currentWeekStart.month &&
        _selectedWeekStart.day == currentWeekStart.day;

    final endOfWeek = _selectedWeekStart.add(const Duration(days: 6));
    final weekDisplay =
        '${DateFormat('MM/dd').format(_selectedWeekStart)} - ${DateFormat('MM/dd').format(endOfWeek)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择周',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showWeekPickerDialog();
          },
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
                  isCurrentWeek ? '本周 ($weekDisplay)' : weekDisplay,
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 完善 _showWeekPickerDialog 函数，按照月度选择器风格实现，只显示本月的周，并采用单列显示
  void _showWeekPickerDialog() {
    final year = _currentYear;
    final selectedMonth = _selectedWeekStart.month;
    final firstDayOfMonth = DateTime(year, selectedMonth, 1);
    final lastDayOfMonth = DateTime(year, selectedMonth + 1, 0);
    final firstMonday =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
    final List<DateTime> weeks = [];
    DateTime weekStart = firstMonday;
    // 只添加本月的周
    while (weekStart.isBefore(lastDayOfMonth) ||
        weekStart.isAtSameMomentAs(lastDayOfMonth)) {
      if (weekStart.month == selectedMonth) {
        weeks.add(weekStart);
      }
      weekStart = weekStart.add(const Duration(days: 7));
    }

    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF3ECABB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: Text(
                    '选择周($year年$selectedMonth月)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  // 设置为一列显示, 并将 childAspectRatio 从 1.5 调整为 3.0 以降低每一周的高度
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 5.0,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: weeks.length,
                  itemBuilder: (context, index) {
                    final weekStart = weeks[index];
                    final weekEnd = weekStart.add(const Duration(days: 6));
                    final isSelected =
                        _selectedWeekStart.year == weekStart.year &&
                            _selectedWeekStart.month == weekStart.month &&
                            _selectedWeekStart.day == weekStart.day;
                    final isCurrentWeek =
                        currentWeekStart.year == weekStart.year &&
                            currentWeekStart.month == weekStart.month &&
                            currentWeekStart.day == weekStart.day;
                    final weekText =
                        '${DateFormat('MM/dd').format(weekStart)} - ${DateFormat('MM/dd').format(weekEnd)}';
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWeekStart = weekStart;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                weekText + (isCurrentWeek ? ' (本周)' : ''),
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      _selectWeek(_selectedWeekStart);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 构建月选择器
  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择月份',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showMonthPickerDialog();
          },
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
                  isCurrentMonth
                      ? '本月 (${_selectedMonth.year}年${_selectedMonth.month}月)'
                      : '${_selectedMonth.year}年${_selectedMonth.month}月',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 显示月份选择对话框
  void _showMonthPickerDialog() {
    final year = _currentYear;
    final months = List.generate(12, (index) => index + 1);
    final now = DateTime.now();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                titlePadding: EdgeInsets.zero,
                title: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3ECABB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '选择月份($year年)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final month = months[index];
                      final isSelected = _selectedMonth.month == month &&
                          _selectedMonth.year == year;
                      final isCurrentMonth =
                          now.month == month && now.year == year;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMonth = DateTime(year, month, 1);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              isCurrentMonth ? '$month月(本月)' : '$month月',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        _selectMonth(_selectedMonth);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('确定'),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  // 构建季度选择器
  Widget _buildQuarterSelector() {
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    final isCurrentQuarter =
        _selectedQuarterYear == now.year && _selectedQuarter == currentQuarter;

    final quarterStartMonth = (_selectedQuarter - 1) * 3 + 1;
    final quarterEndMonth = quarterStartMonth + 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择季度',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            _showQuarterPickerDialog();
          },
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
                  isCurrentQuarter
                      ? '本季度 ($_selectedQuarterYear年Q$_selectedQuarter: $quarterStartMonth-$quarterEndMonth月)'
                      : '$_selectedQuarterYear年Q$_selectedQuarter: $quarterStartMonth-$quarterEndMonth月',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 完善 _showQuarterPickerDialog 函数，按照月度选择器的风格和操作实现
  void _showQuarterPickerDialog() {
    final year = _currentYear;
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF3ECABB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: Text(
                    '选择季度($year年)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final quarter = index + 1;
                    final isSelected = _selectedQuarter == quarter;
                    final isCurrentQ =
                        (quarter == currentQuarter && year == now.year);
                    final quarterStartMonth = (quarter - 1) * 3 + 1;
                    final quarterEndMonth = quarterStartMonth + 2;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedQuarter = quarter;
                          _selectedQuarterYear = year;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Q$quarter',
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$quarterStartMonth-$quarterEndMonth月${isCurrentQ ? " (本季度)" : ""}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      _selectQuarter(_selectedQuarter, year);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('确定'),
                  ),
                ),
              ],
            );
          },
        );
      },
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
