import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intellimate/presentation/providers/travel_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddTravelScreen extends StatefulWidget {
  final Travel? travel; // 如果为null，则是添加模式；否则是编辑模式

  const AddTravelScreen({super.key, this.travel});

  @override
  State<AddTravelScreen> createState() => _AddTravelScreenState();
}

class _AddTravelScreenState extends State<AddTravelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placesController = TextEditingController();
  final _peopleCountController = TextEditingController(text: '1');
  final _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TravelStatus _status = TravelStatus.planning;

  bool _isLoading = false;

  // 是否是编辑模式
  bool get _isEditMode => widget.travel != null;

  @override
  void initState() {
    super.initState();

    // 如果是编辑模式，初始化数据
    if (_isEditMode) {
      _titleController.text = widget.travel!.title;
      _descriptionController.text = widget.travel!.description ?? '';
      _placesController.text = widget.travel!.places.join(',');
      _peopleCountController.text = widget.travel!.peopleCount.toString();
      _budgetController.text = widget.travel!.budget.toString();
      _startDate = widget.travel!.startDate;
      _endDate = widget.travel!.endDate;
      _status = widget.travel!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _placesController.dispose();
    _peopleCountController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // 保存旅行
  Future<void> _saveTravel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final travelProvider =
          Provider.of<TravelProvider>(context, listen: false);
      final now = DateTime.now();

      if (_isEditMode) {
        // 更新现有旅行
        final updatedTravel = widget.travel!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          places:
              _placesController.text.split(',').map((e) => e.trim()).toList(),
          startDate: _startDate,
          endDate: _endDate,
          peopleCount: int.tryParse(_peopleCountController.text) ?? 1,
          budget: double.tryParse(_budgetController.text) ?? 0,
          status: _status,
          updatedAt: now,
        );

        await travelProvider.updateTravel(updatedTravel);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('旅行更新成功')),
          );
          Navigator.pop(context, true);
        }
      } else {
        // 创建新旅行
        final newTravel = Travel(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          places:
              _placesController.text.split(',').map((e) => e.trim()).toList(),
          startDate: _startDate,
          endDate: _endDate,
          peopleCount: int.tryParse(_peopleCountController.text) ?? 1,
          budget: double.tryParse(_budgetController.text) ?? 0,
          status: _status,
          createdAt: now,
          updatedAt: now,
        );

        final id = await travelProvider.addTravel(newTravel);

        if (mounted) {
          if (id != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('旅行创建成功')),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('旅行创建失败')),
            );
          }
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

  // 选择日期
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime(2000) : _startDate,
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // 如果开始日期晚于结束日期，则更新结束日期
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
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
                title: _isEditMode ? '编辑旅行' : '添加旅行',
                showHomeButton: false,
                showBackButton: true,
                actions: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTravel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3ECABB),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题输入
                        _buildTitleInput(),

                        const SizedBox(height: 20),

                        // 描述输入
                        _buildDescriptionInput(),

                        const SizedBox(height: 20),

                        // 地点输入
                        _buildPlacesInput(),

                        const SizedBox(height: 20),

                        // 日期选择
                        _buildDateSelector(),

                        const SizedBox(height: 20),

                        // 人数输入
                        _buildPeopleCountInput(),

                        const SizedBox(height: 20),

                        // 预算输入
                        _buildBudgetInput(),

                        const SizedBox(height: 20),

                        // 状态选择
                        _buildStatusSelector(),
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
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
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
        labelText: '旅行标题',
        hintText: '例如：北京之行',
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
          return '请输入旅行标题';
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
        labelText: '旅行描述（可选）',
        hintText: '简要描述旅行目的和计划',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
    );
  }

  // 构建地点输入
  Widget _buildPlacesInput() {
    return TextFormField(
      controller: _placesController,
      decoration: InputDecoration(
        labelText: '地点列表',
        hintText: '例如：北京,天安门,故宫',
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
          return '请输入地点列表';
        }
        return null;
      },
    );
  }

  // 构建日期选择器
  Widget _buildDateSelector() {
    final dateFormat = DateFormat('yyyy年MM月dd日');

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
            '旅行日期',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('开始日期：'),
              TextButton(
                onPressed: () => _selectDate(context, true),
                child: Text(dateFormat.format(_startDate)),
              ),
            ],
          ),
          Row(
            children: [
              const Text('结束日期：'),
              TextButton(
                onPressed: () => _selectDate(context, false),
                child: Text(dateFormat.format(_endDate)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '旅行天数：${_endDate.difference(_startDate).inDays + 1}天',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 构建人数输入
  Widget _buildPeopleCountInput() {
    return TextFormField(
      controller: _peopleCountController,
      decoration: InputDecoration(
        labelText: '人数',
        hintText: '例如：2',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入人数';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return '请输入有效的人数';
        }
        return null;
      },
    );
  }

  // 构建预算输入
  Widget _buildBudgetInput() {
    return TextFormField(
      controller: _budgetController,
      decoration: InputDecoration(
        labelText: '预算',
        hintText: '例如：5000',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
        prefixText: '¥ ',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入预算';
        }
        if (double.tryParse(value) == null || double.parse(value) < 0) {
          return '请输入有效的预算';
        }
        return null;
      },
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
            '旅行状态',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TravelStatus>(
            value: _status,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            items: TravelStatus.values.map((status) {
              String statusText;
              Color statusColor;

              switch (status) {
                case TravelStatus.planning:
                  statusText = '计划中';
                  statusColor = Colors.blue;
                  break;
                case TravelStatus.ongoing:
                  statusText = '进行中';
                  statusColor = Colors.green;
                  break;
                case TravelStatus.completed:
                  statusText = '已完成';
                  statusColor = Colors.grey;
                  break;
              }

              return DropdownMenuItem<TravelStatus>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(statusText),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _status = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
