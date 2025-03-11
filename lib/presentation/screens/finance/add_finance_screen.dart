import 'package:flutter/material.dart';
import 'package:intellimate/app/routes/app_routes.dart';
import 'package:intellimate/domain/entities/finance.dart';
import 'package:intl/intl.dart';
import 'package:intellimate/app/theme/app_colors.dart';

class AddFinanceScreen extends StatefulWidget {
  const AddFinanceScreen({super.key});

  @override
  State<AddFinanceScreen> createState() => _AddFinanceScreenState();
}

class _AddFinanceScreenState extends State<AddFinanceScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _type = 'expense'; // expense, income
  String _selectedCategory = '餐饮';
  DateTime _selectedDate = DateTime.now();
  String _selectedAccount = '现金';
  
  // 分类列表
  final Map<String, Map<String, dynamic>> _expenseCategories = {
    '餐饮': {
      'icon': Icons.restaurant,
      'color': Colors.red,
    },
    '交通': {
      'icon': Icons.directions_car,
      'color': Colors.blue,
    },
    '购物': {
      'icon': Icons.shopping_bag,
      'color': Colors.purple,
    },
    '住房': {
      'icon': Icons.home,
      'color': Colors.amber,
    },
    '医疗': {
      'icon': Icons.favorite,
      'color': Colors.green,
    },
    '娱乐': {
      'icon': Icons.sports_esports,
      'color': Colors.indigo,
    },
    '服饰': {
      'icon': Icons.checkroom,
      'color': Colors.pink,
    },
    '其他': {
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  };
  
  final Map<String, Map<String, dynamic>> _incomeCategories = {
    '工资': {
      'icon': Icons.attach_money,
      'color': Colors.green,
    },
    '奖金': {
      'icon': Icons.card_giftcard,
      'color': Colors.orange,
    },
    '投资': {
      'icon': Icons.trending_up,
      'color': Colors.blue,
    },
    '其他': {
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  };
  
  // 账户列表
  final List<String> _accounts = ['现金', '银行卡', '支付宝', '微信', '信用卡'];
  
  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  // 保存财务记录
  void _saveFinance() {
    // 验证金额
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入金额'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请输入有效金额'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // 创建财务记录
    final finance = Finance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: _type,
      category: _selectedCategory,
      description: _notesController.text.isNotEmpty ? _notesController.text : null,
      date: _selectedDate,
      paymentMethod: _selectedAccount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 返回上一页并传递新创建的财务记录
    Navigator.pop(context, finance);
  }
  
  // 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  // 选择账户
  void _selectAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择账户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _accounts.map((account) {
            return RadioListTile<String>(
              title: Text(account),
              value: account,
              groupValue: _selectedAccount,
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
  
  // 添加照片
  void _addPhoto() {
    // 这里应该调用图片选择器
    // 暂时只是显示一个提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('添加照片功能尚未实现'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // 自定义顶部导航栏
          _buildCustomAppBar(),
          
          // 主体内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 收支类型选择
                  _buildTypeSelector(),
                  
                  // 金额输入
                  _buildAmountInput(),
                  
                  // 分类选择
                  _buildCategorySelector(),
                  
                  // 日期选择
                  _buildDateSelector(),
                  
                  // 账户选择
                  _buildAccountSelector(),
                  
                  // 备注
                  _buildNotesInput(),
                  
                  // 添加照片
                  _buildPhotoUploader(),
                ],
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
        color: Color(0xFF3ECABB),
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
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
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
                  decoration: const BoxDecoration(
                    color: AppColors.whiteWithOpacity20,
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
                '添加收支',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _saveFinance,
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
    );
  }
  
  // 构建收支类型选择器
  Widget _buildTypeSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _type = 'expense';
                  // 切换到支出分类
                  if (!_expenseCategories.containsKey(_selectedCategory)) {
                    _selectedCategory = _expenseCategories.keys.first;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == 'expense' ? Colors.red : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '支出',
                  style: TextStyle(
                    color: _type == 'expense' ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _type = 'income';
                  // 切换到收入分类
                  if (!_incomeCategories.containsKey(_selectedCategory)) {
                    _selectedCategory = _incomeCategories.keys.first;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _type == 'income' ? Colors.green : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '收入',
                  style: TextStyle(
                    color: _type == 'income' ? Colors.white : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建金额输入
  Widget _buildAmountInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.blackWithOpacity05,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '金额',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '¥',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 构建分类选择器
  Widget _buildCategorySelector() {
    final categories = _type == 'expense' ? _expenseCategories : _incomeCategories;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '分类',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: categories.entries.map((entry) {
            final category = entry.key;
            final icon = entry.value['icon'] as IconData;
            final color = entry.value['color'] as Color;
            final isSelected = _selectedCategory == category;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.getColorWithOpacity(color, 0.1),
                      shape: BoxShape.circle,
                      border: isSelected 
                          ? Border.all(color: color, width: 2) 
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? color : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  // 构建日期选择器
  Widget _buildDateSelector() {
    final dateFormat = DateFormat('yyyy年MM月dd日');
    
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '日期',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackWithOpacity05,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF3ECABB),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateFormat.format(_selectedDate),
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建账户选择器
  Widget _buildAccountSelector() {
    return GestureDetector(
      onTap: _selectAccount,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                '账户',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackWithOpacity05,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.credit_card,
                    color: Color(0xFF3ECABB),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedAccount,
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建备注输入
  Widget _buildNotesInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '备注',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.blackWithOpacity05,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '添加备注...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建照片上传
  Widget _buildPhotoUploader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '添加照片',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          GestureDetector(
            onTap: _addPhoto,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.blackWithOpacity05,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEFBFA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF3ECABB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '添加收支凭证',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 