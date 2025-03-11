import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/memo.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/presentation/providers/memo_provider.dart';
import 'package:intellimate/presentation/widgets/common/empty_state.dart';
import 'package:intellimate/presentation/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

class MemoScreen extends StatefulWidget {
  const MemoScreen({Key? key}) : super(key: key);

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '工作', '学习', '生活', '其他'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    setState(() {
      _isLoading = true;
    });

    final memoProvider = Provider.of<MemoProvider>(context, listen: false);
    
    if (_selectedCategory == '全部') {
      await memoProvider.getAllMemos();
    } else {
      await memoProvider.getMemosByCategory(_selectedCategory);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备忘录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('搜索功能即将上线')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _buildMemoList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add_memo');
          if (result == true) {
            _loadMemos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  _loadMemos();
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemoList() {
    final memoProvider = Provider.of<MemoProvider>(context);
    final memos = memoProvider.memos;
    
    if (memos.isEmpty) {
      return EmptyState(
        icon: Icons.note_alt_outlined,
        message: '没有备忘录',
        subMessage: '点击下方按钮添加新的备忘录',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: memos.length,
      itemBuilder: (context, index) {
        return _buildMemoItem(memos[index]);
      },
    );
  }

  Widget _buildMemoItem(Memo memo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context, 
            '/edit_memo',
            arguments: memo.id,
          );
          if (result == true) {
            _loadMemos();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      memo.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriorityIndicator(memo.priority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                memo.content,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(memo.category ?? '默认'),
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _formatDate(memo.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(String priority) {
    Color color;
    IconData icon;
    
    switch (priority) {
      case '高':
        color = Colors.red;
        icon = Icons.priority_high;
        break;
      case '中':
        color = Colors.orange;
        icon = Icons.flag;
        break;
      case '低':
      default:
        color = Colors.green;
        icon = Icons.low_priority;
        break;
    }
    
    return Icon(icon, color: color);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 