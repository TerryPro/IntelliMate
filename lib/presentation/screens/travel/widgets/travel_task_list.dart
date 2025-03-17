import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intellimate/presentation/providers/travel_provider.dart';
import 'package:intl/intl.dart';

class TravelTaskList extends StatelessWidget {
  final String travelId;
  final List<TravelTask> tasks;

  const TravelTaskList({
    super.key,
    required this.travelId,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(context, task);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无行程安排',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加行程安排',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TravelTask task) {
    final dateFormat = DateFormat('MM.dd HH:mm');
    
    return Dismissible(
      key: Key(task.id!),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => _deleteTask(context, task),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Icon(
            task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.isCompleted ? Colors.green : Colors.grey,
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Text(task.description!),
              Text(
                '${dateFormat.format(task.startTime)} - ${dateFormat.format(task.endTime)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditTaskDialog(context, task),
              ),
              IconButton(
                icon: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
                onPressed: () => _toggleTaskStatus(context, task),
              ),
            ],
          ),
          onTap: () => _showTaskDetails(context, task),
        ),
      ),
    );
  }

  Future<void> _deleteTask(BuildContext context, TravelTask task) async {
    final travelProvider = Provider.of<TravelProvider>(context, listen: false);
    try {
      await travelProvider.deleteTask(travelId, task.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已删除')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Future<void> _toggleTaskStatus(BuildContext context, TravelTask task) async {
    final travelProvider = Provider.of<TravelProvider>(context, listen: false);
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await travelProvider.updateTask(travelId, updatedTask);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }

  void _showTaskDetails(BuildContext context, TravelTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _TaskDetailsSheet(task: task),
    );
  }

  Future<void> _showEditTaskDialog(BuildContext context, TravelTask task) async {
    final result = await showDialog<TravelTask>(
      context: context,
      builder: (context) => _TaskEditDialog(task: task),
    );

    if (result != null && context.mounted) {
      final travelProvider = Provider.of<TravelProvider>(context, listen: false);
      try {
        await travelProvider.updateTask(travelId, result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失败: $e')),
          );
        }
      }
    }
  }
}

class _TaskDetailsSheet extends StatelessWidget {
  final TravelTask task;

  const _TaskDetailsSheet({required this.task});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isCompleted ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const Text(
              '描述',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(task.description!),
            const SizedBox(height: 16),
          ],
          const Text(
            '时间',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('开始：${dateFormat.format(task.startTime)}'),
          Text('结束：${dateFormat.format(task.endTime)}'),
          const SizedBox(height: 16),
          if (task.location != null && task.location!.isNotEmpty) ...[
            const Text(
              '地点',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(task.location!),
          ],
        ],
      ),
    );
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