import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/schedule.dart';
import 'package:intellimate/presentation/providers/schedule_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class AddScheduleScreen extends StatefulWidget {
  final String? scheduleId; // 用于编辑现有日程
  
  const AddScheduleScreen({super.key, this.scheduleId});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour + 1,
  );
  
  String? _reminder = '提前15分钟';
  final List<String> _reminderOptions = ['无', '提前5分钟', '提前15分钟', '提前30分钟', '提前1小时', '提前1天'];
  
  String _selectedCategory = '工作';
  final List<Map<String, dynamic>> _categories = [
    {'name': '工作', 'icon': Icons.work, 'selected': true},
    {'name': '学习', 'icon': Icons.school, 'selected': false},
    {'name': '健康', 'icon': Icons.favorite, 'selected': false},
    {'name': '社交', 'icon': Icons.people, 'selected': false},
  ];
  
  bool _isAllDay = false;
  bool _isLoading = false;
  String? _error;
  Schedule? _existingSchedule;
  
  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      _loadExistingSchedule();
    }
  }
  
  // 加载现有日程
  Future<void> _loadExistingSchedule() async {
    final provider = Provider.of<ScheduleProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final schedule = await provider.getScheduleById(widget.scheduleId!);
      
      if (schedule != null) {
        setState(() {
          _existingSchedule = schedule;
          _titleController.text = schedule.title;
          _locationController.text = schedule.location ?? '';
          _notesController.text = schedule.description ?? '';
          _selectedDate = schedule.startTime;
          _startTime = TimeOfDay(
            hour: schedule.startTime.hour,
            minute: schedule.startTime.minute,
          );
          _endTime = TimeOfDay(
            hour: schedule.endTime.hour,
            minute: schedule.endTime.minute,
          );
          _isAllDay = schedule.isAllDay;
          _reminder = schedule.reminder;
          _selectedCategory = schedule.category ?? '工作';
          
          // 更新分类选择状态
          for (var category in _categories) {
            category['selected'] = category['name'] == _selectedCategory;
          }
        });
      } else {
        setState(() {
          _error = '找不到指定的日程';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // 保存日程
  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ScheduleProvider>(context, listen: false);
      
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      try {
        // 构建开始和结束时间
        final startDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _isAllDay ? 0 : _startTime.hour,
          _isAllDay ? 0 : _startTime.minute,
        );
        
        final endDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _isAllDay ? 23 : _endTime.hour,
          _isAllDay ? 59 : _endTime.minute,
        );
        
        // 判断是创建还是更新
        if (_existingSchedule != null) {
          // 更新现有日程
          final updatedSchedule = Schedule(
            id: _existingSchedule!.id,
            title: _titleController.text,
            description: _notesController.text.isNotEmpty ? _notesController.text : null,
            startTime: startDateTime,
            endTime: endDateTime,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            isAllDay: _isAllDay,
            category: _selectedCategory,
            isRepeated: false,
            repeatType: null,
            reminder: _reminder,
            createdAt: _existingSchedule!.createdAt,
            updatedAt: DateTime.now(),
          );
          
          final success = await provider.updateSchedule(updatedSchedule);
          
          if (success && mounted) {
            Navigator.pop(context, true);
          } else {
            setState(() {
              _error = '更新日程失败';
              _isLoading = false;
            });
          }
        } else {
          // 创建新日程
          final schedule = await provider.createSchedule(
            title: _titleController.text,
            description: _notesController.text.isNotEmpty ? _notesController.text : null,
            startTime: startDateTime,
            endTime: endDateTime,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            isAllDay: _isAllDay,
            category: _selectedCategory,
            isRepeated: false,
            repeatType: null,
            reminder: _reminder,
          );
          
          if (schedule != null && mounted) {
            Navigator.pop(context, true);
          } else {
            setState(() {
              _error = '创建日程失败';
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  // 选择日期
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3ECABB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // 选择开始时间
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3ECABB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startTime = picked;
        // 如果开始时间晚于结束时间，自动调整结束时间
        if (_startTime.hour > _endTime.hour || 
            (_startTime.hour == _endTime.hour && _startTime.minute >= _endTime.minute)) {
          _endTime = TimeOfDay(
            hour: _startTime.hour + 1,
            minute: _startTime.minute,
          );
        }
      });
    }
  }
  
  // 选择结束时间
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3ECABB),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              // 使用统一的顶部导航栏
              UnifiedAppBar(
                title: _existingSchedule == null ? '添加日程' : '编辑日程',
                showHomeButton: false,
                showBackButton: true,
                actions: [
                  ElevatedButton(
                    onPressed: _saveSchedule,
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
              
              // 表单内容
              Expanded(
                child: _isLoading && _existingSchedule == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题输入
                              _buildTitleInput(),
                              const SizedBox(height: 20),
                              
                              // 日期选择
                              _buildDatePicker(),
                              const SizedBox(height: 20),
                              
                              // 全天选项
                              _buildAllDayOption(),
                              const SizedBox(height: 20),
                              
                              // 时间选择
                              if (!_isAllDay) _buildTimePicker(),
                              if (!_isAllDay) const SizedBox(height: 20),
                              
                              // 地点输入
                              _buildLocationInput(),
                              const SizedBox(height: 20),
                              
                              // 分类选择
                              _buildCategorySelector(),
                              const SizedBox(height: 20),
                              
                              // 提醒选项
                              _buildReminderOptions(),
                              const SizedBox(height: 20),
                              
                              // 备注输入
                              _buildNotesInput(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
          
          // 加载指示器
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            
          // 错误提示
          if (_error != null)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _error = null;
                          });
                        },
                        child: const Text('确定'),
                      ),
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
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日程标题',
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
            hintText: '请输入日程标题',
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
              return '请输入日程标题';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  // 构建日期部分
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日期',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
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
                  '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
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
  
  // 构建全天选项
  Widget _buildAllDayOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '全天',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Switch(
          value: _isAllDay,
          onChanged: (value) {
            setState(() {
              _isAllDay = value;
            });
          },
        ),
      ],
    );
  }
  
  // 构建时间部分
  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '开始时间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectStartTime(context),
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
                            Icons.access_time,
                            color: Color(0xFF3ECABB),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _startTime.format(context),
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '结束时间',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectEndTime(context),
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
                            Icons.access_time,
                            color: Color(0xFF3ECABB),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _endTime.format(context),
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
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // 构建地点部分
  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '地点',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: '请输入地点',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: Color(0xFF3ECABB),
              ),
              suffixIcon: Icon(
                Icons.map,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 构建日程类型部分
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '日程类型',
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
          children: _categories.map((category) {
            final bool isSelected = category['name'] == _selectedCategory;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['name'];
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
                      category['icon'],
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category['name'],
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
  
  // 构建提醒部分
  Widget _buildReminderOptions() {
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
  
  // 构建备注部分
  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '备注',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '添加备注...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
} 