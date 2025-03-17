import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intellimate/presentation/screens/travel/add_travel_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/presentation/providers/travel_provider.dart';
import 'package:intellimate/presentation/screens/travel/widgets/travel_task_list.dart';
import 'package:intellimate/presentation/screens/travel/widgets/travel_accommodation_list.dart';

class TravelDetailScreen extends StatefulWidget {
  final Travel travel;
  
  const TravelDetailScreen({
    super.key,
    required this.travel,
  });

  @override
  State<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends State<TravelDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // 标签列表
  final List<String> _tabs = ['行程', '住宿', '交通', '花费', '照片', '笔记'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部封面和信息
          _buildHeader(),
          
          // 标签栏
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
          
          // 标签内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItineraryTab(),
                _buildAccommodationTab(),
                _buildTransportationTab(),
                _buildExpenseTab(),
                _buildPhotosTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
      
      // 浮动按钮
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // 根据当前标签添加不同的内容
          _showAddOptions(context);
        },
      ),
    );
  }
  
  // 构建顶部封面和信息
  Widget _buildHeader() {
    // 格式化日期
    final dateFormat = DateFormat('yyyy.MM.dd');
    final startDateStr = dateFormat.format(widget.travel.startDate);
    final endDateStr = dateFormat.format(widget.travel.endDate);
    
    // 计算旅行天数
    final duration = widget.travel.endDate.difference(widget.travel.startDate).inDays + 1;
    final durationText = '$duration天${duration > 1 ? '${duration - 1}晚' : ''}';
    
    // 根据旅行状态设置标签颜色和文本
    Color statusColor;
    String statusText;
    
    switch (widget.travel.status) {
      case TravelStatus.planning:
        statusColor = Colors.amber;
        statusText = '计划中';
        break;
      case TravelStatus.ongoing:
        statusColor = Colors.green;
        statusText = '进行中';
        break;
      case TravelStatus.completed:
        statusColor = Colors.blue;
        statusText = '已完成';
        break;
    }
    
    return Stack(
      children: [
        // 背景图片
        Image.network(
          _getTravelImage(),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 60,
              ),
            );
          },
        ),
        
        // 渐变遮罩
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.getColorWithOpacity(Colors.black, 0.3),
                AppColors.blackWithOpacity50,
              ],
            ),
          ),
        ),
        
        // 返回按钮和更多选项
        Positioned(
          top: MediaQuery.of(context).padding.top,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 返回按钮
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                
                // 更多选项
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editTravel();
                    } else if (value == 'delete') {
                      _showDeleteConfirmation();
                    } else if (value == 'share') {
                      // 分享功能
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('分享功能开发中')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('编辑旅行'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除旅行'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, color: Colors.green),
                          SizedBox(width: 8),
                          Text('分享旅行'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // 旅行信息
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 旅行标题
              Text(
                widget.travel.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 旅行日期和天数
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$startDateStr - $endDateStr',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    durationText,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 目的地
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.travel.places.join(' - '),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // 获取旅行图片
  String _getTravelImage() {
    // 根据旅行目的地或状态返回不同的图片
    switch (widget.travel.status) {
      case TravelStatus.ongoing:
        return 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05';
      case TravelStatus.completed:
        return 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b';
      case TravelStatus.planning:
        return 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e';
    }
  }
  
  // 构建行程标签页
  Widget _buildItineraryTab() {
    if (widget.travel.tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.route,
        title: '暂无行程安排',
        message: '点击下方按钮添加行程安排',
      );
    }
    
    return TravelTaskList(
      travelId: widget.travel.id!,
      tasks: widget.travel.tasks,
    );
  }
  
  // 构建住宿标签页
  Widget _buildAccommodationTab() {
    if (widget.travel.accommodations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.hotel,
        title: '暂无住宿信息',
        message: '点击下方按钮添加住宿信息',
      );
    }
    
    return TravelAccommodationList(
      travelId: widget.travel.id!,
      accommodations: widget.travel.accommodations,
    );
  }
  
  // 构建交通标签页
  Widget _buildTransportationTab() {
    // TODO: 实现交通标签页
    return _buildEmptyState(
      icon: Icons.directions_car,
      title: '暂无交通信息',
      message: '点击下方按钮添加交通信息',
    );
  }
  
  // 构建花费标签页
  Widget _buildExpenseTab() {
    // TODO: 实现花费标签页
    return _buildEmptyState(
      icon: Icons.attach_money,
      title: '暂无花费记录',
      message: '点击下方按钮添加花费记录',
    );
  }
  
  // 构建照片标签页
  Widget _buildPhotosTab() {
    // TODO: 实现照片标签页
    return _buildEmptyState(
      icon: Icons.photo_library,
      title: '暂无照片',
      message: '点击下方按钮添加照片',
    );
  }
  
  // 构建笔记标签页
  Widget _buildNotesTab() {
    // TODO: 实现笔记标签页
    return _buildEmptyState(
      icon: Icons.note,
      title: '暂无旅行笔记',
      message: '点击下方按钮添加旅行笔记',
    );
  }
  
  // 构建空状态
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // 显示添加选项
  void _showAddOptions(BuildContext context) {
    final currentTab = _tabs[_tabController.index];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '添加$currentTab',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(),
              if (currentTab == '行程') _buildAddTaskOption(),
              if (currentTab == '住宿') _buildAddAccommodationOption(),
              if (currentTab == '交通') _buildAddTransportationOption(),
              if (currentTab == '花费') _buildAddExpenseOption(),
              if (currentTab == '照片') _buildAddPhotoOption(),
              if (currentTab == '笔记') _buildAddNoteOption(),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAddTaskOption() {
    return ListTile(
      leading: const Icon(Icons.add_task, color: AppColors.primary),
      title: const Text('添加行程安排'),
      onTap: () {
        Navigator.pop(context);
        _showAddTaskDialog();
      },
    );
  }

  Future<void> _showAddTaskDialog() async {
    final now = DateTime.now();
    final task = TravelTask(
      title: '',
      startTime: now,
      endTime: now.add(const Duration(hours: 1)),
      createdAt: now,
      updatedAt: now,
    );

    final result = await showDialog<TravelTask>(
      context: context,
      builder: (context) => _TaskEditDialog(task: task),
    );

    if (result != null && mounted) {
      final travelProvider = Provider.of<TravelProvider>(context, listen: false);
      try {
        await travelProvider.addTask(widget.travel.id!, result);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加失败: $e')),
          );
        }
      }
    }
  }

  Widget _buildAddAccommodationOption() {
    return ListTile(
      leading: const Icon(Icons.hotel, color: AppColors.primary),
      title: const Text('添加住宿信息'),
      onTap: () {
        Navigator.pop(context);
        _showAddAccommodationDialog();
      },
    );
  }

  Future<void> _showAddAccommodationDialog() async {
    final now = DateTime.now();
    final accommodation = TravelAccommodation(
      name: '',
      checkInDate: widget.travel.startDate,
      checkOutDate: widget.travel.startDate.add(const Duration(days: 1)),
      price: 0,
      createdAt: now,
      updatedAt: now,
    );

    final result = await showDialog<TravelAccommodation>(
      context: context,
      builder: (context) => _AccommodationEditDialog(accommodation: accommodation),
    );

    if (result != null && mounted) {
      // TODO: 实现添加住宿信息的功能
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('添加住宿信息功能正在开发中')),
      );
    }
  }

  Widget _buildAddTransportationOption() {
    return ListTile(
      leading: const Icon(Icons.directions_car, color: AppColors.primary),
      title: const Text('添加交通信息'),
      onTap: () {
        Navigator.pop(context);
        // TODO: 实现添加交通信息功能
      },
    );
  }

  Widget _buildAddExpenseOption() {
    return ListTile(
      leading: const Icon(Icons.attach_money, color: AppColors.primary),
      title: const Text('添加花费记录'),
      onTap: () {
        Navigator.pop(context);
        // TODO: 实现添加花费记录功能
      },
    );
  }

  Widget _buildAddPhotoOption() {
    return ListTile(
      leading: const Icon(Icons.photo_camera, color: AppColors.primary),
      title: const Text('添加照片'),
      onTap: () {
        Navigator.pop(context);
        // TODO: 实现添加照片功能
      },
    );
  }

  Widget _buildAddNoteOption() {
    return ListTile(
      leading: const Icon(Icons.note_add, color: AppColors.primary),
      title: const Text('添加笔记'),
      onTap: () {
        Navigator.pop(context);
        // TODO: 实现添加笔记功能
      },
    );
  }

  // 编辑旅行
  void _editTravel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTravelScreen(travel: widget.travel),
      ),
    ).then((result) {
      // 如果返回结果为true，表示编辑成功，刷新数据
      if (result == true) {
        // 刷新旅行数据
        final travelProvider = Provider.of<TravelProvider>(context, listen: false);
        travelProvider.loadAllTravels();
        
        // 获取更新后的旅行数据
        travelProvider.getTravel(widget.travel.id!).then((updatedTravel) {
          if (updatedTravel != null && mounted) {
            // 返回到上一页并传递更新后的数据
            Navigator.pop(context, true);
          }
        });
      }
    });
  }
  
  // 显示删除确认对话框
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除旅行'),
        content: const Text('确定要删除这个旅行吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTravel();
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
  
  // 删除旅行
  void _deleteTravel() async {
    try {
      final travelProvider = Provider.of<TravelProvider>(context, listen: false);
      final result = await travelProvider.deleteTravel(widget.travel.id!);
      
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('旅行已删除')),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}

class _AccommodationEditDialog extends StatefulWidget {
  final TravelAccommodation accommodation;

  const _AccommodationEditDialog({required this.accommodation});

  @override
  State<_AccommodationEditDialog> createState() => _AccommodationEditDialogState();
}

class _AccommodationEditDialogState extends State<_AccommodationEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _priceController;
  late TextEditingController _bookingNumberController;
  late TextEditingController _notesController;
  late DateTime _checkInDate;
  late DateTime _checkOutDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.accommodation.name);
    _addressController = TextEditingController(text: widget.accommodation.address);
    _phoneController = TextEditingController(text: widget.accommodation.phone);
    _priceController = TextEditingController(text: widget.accommodation.price.toString());
    _bookingNumberController = TextEditingController(text: widget.accommodation.bookingNumber);
    _notesController = TextEditingController(text: widget.accommodation.notes);
    _checkInDate = widget.accommodation.checkInDate;
    _checkOutDate = widget.accommodation.checkOutDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _bookingNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑住宿信息'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '住宿名称',
                hintText: '例如：XX酒店',
              ),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '地址',
                hintText: '输入住宿地址',
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '联系电话',
                hintText: '输入联系电话',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('入住日期：'),
                TextButton(
                  onPressed: () => _selectDate(context, true),
                  child: Text(DateFormat('yyyy-MM-dd').format(_checkInDate)),
                ),
              ],
            ),
            Row(
              children: [
                const Text('退房日期：'),
                TextButton(
                  onPressed: () => _selectDate(context, false),
                  child: Text(DateFormat('yyyy-MM-dd').format(_checkOutDate)),
                ),
              ],
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: '价格',
                hintText: '输入住宿价格',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _bookingNumberController,
              decoration: const InputDecoration(
                labelText: '预订号',
                hintText: '输入预订号（可选）',
              ),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '输入备注信息（可选）',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('住宿名称不能为空')),
              );
              return;
            }
            
            if (_priceController.text.isEmpty || double.tryParse(_priceController.text) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入有效的价格')),
              );
              return;
            }
            
            final updatedAccommodation = widget.accommodation.copyWith(
              name: _nameController.text,
              address: _addressController.text.isEmpty ? null : _addressController.text,
              phone: _phoneController.text.isEmpty ? null : _phoneController.text,
              checkInDate: _checkInDate,
              checkOutDate: _checkOutDate,
              price: double.parse(_priceController.text),
              bookingNumber: _bookingNumberController.text.isEmpty ? null : _bookingNumberController.text,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
              updatedAt: DateTime.now(),
            );
            
            Navigator.pop(context, updatedAccommodation);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final initialDate = isCheckIn ? _checkInDate : _checkOutDate;
    final firstDate = isCheckIn ? DateTime(2000) : _checkInDate;
    
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = date;
          if (_checkOutDate.isBefore(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = date;
        }
      });
    }
  }
}

class _TaskEditDialog extends StatefulWidget {
  final TravelTask task;

  const _TaskEditDialog({required this.task});

  @override
  State<_TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<_TaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _startTime;
  late DateTime _endTime;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _locationController = TextEditingController(text: widget.task.location);
    _startTime = widget.task.startTime;
    _endTime = widget.task.endTime;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑任务'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '输入任务标题',
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                hintText: '输入任务描述',
              ),
              maxLines: 3,
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '地点',
                hintText: '输入任务地点',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('开始时间：'),
                TextButton(
                  onPressed: () => _selectDateTime(context, true),
                  child: Text(DateFormat('MM-dd HH:mm').format(_startTime)),
                ),
              ],
            ),
            Row(
              children: [
                const Text('结束时间：'),
                TextButton(
                  onPressed: () => _selectDateTime(context, false),
                  child: Text(DateFormat('MM-dd HH:mm').format(_endTime)),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value!;
                    });
                  },
                ),
                const Text('已完成'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('标题不能为空')),
              );
              return;
            }
            
            final updatedTask = widget.task.copyWith(
              title: _titleController.text,
              description: _descriptionController.text,
              location: _locationController.text,
              startTime: _startTime,
              endTime: _endTime,
              isCompleted: _isCompleted,
            );
            
            Navigator.pop(context, updatedTask);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final currentDate = isStart ? _startTime : _endTime;
    
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );
      
      if (time != null) {
        setState(() {
          final newDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
          
          if (isStart) {
            _startTime = newDateTime;
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            if (newDateTime.isBefore(_startTime)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('结束时间不能早于开始时间')),
              );
              return;
            }
            _endTime = newDateTime;
          }
        });
      }
    }
  }
} 