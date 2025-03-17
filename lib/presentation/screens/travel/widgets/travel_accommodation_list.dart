import 'package:flutter/material.dart';
import 'package:intellimate/domain/entities/travel.dart';
import 'package:intl/intl.dart';

class TravelAccommodationList extends StatelessWidget {
  final String travelId;
  final List<TravelAccommodation> accommodations;

  const TravelAccommodationList({
    super.key,
    required this.travelId,
    required this.accommodations,
  });

  @override
  Widget build(BuildContext context) {
    if (accommodations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: accommodations.length,
      itemBuilder: (context, index) {
        final accommodation = accommodations[index];
        return _buildAccommodationItem(context, accommodation);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无住宿信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加住宿信息',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationItem(
      BuildContext context, TravelAccommodation accommodation) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final nights =
        accommodation.checkOutDate.difference(accommodation.checkInDate).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    accommodation.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '¥${accommodation.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (accommodation.address != null &&
                accommodation.address!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      accommodation.address!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${dateFormat.format(accommodation.checkInDate)} - ${dateFormat.format(accommodation.checkOutDate)} ($nights晚)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (accommodation.phone != null &&
                accommodation.phone!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    accommodation.phone!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (accommodation.bookingNumber != null &&
                accommodation.bookingNumber!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.confirmation_number,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '预订号: ${accommodation.bookingNumber}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (accommodation.notes != null &&
                accommodation.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '备注:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                accommodation.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () =>
                      _showEditAccommodationDialog(context, accommodation),
                  tooltip: '编辑',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () =>
                      _showDeleteConfirmDialog(context, accommodation),
                  tooltip: '删除',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditAccommodationDialog(
      BuildContext context, TravelAccommodation accommodation) async {
    final result = await showDialog<TravelAccommodation>(
      context: context,
      builder: (context) =>
          _AccommodationEditDialog(accommodation: accommodation),
    );

    if (result != null && context.mounted) {
      // TODO: 实现更新住宿信息的功能
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('编辑住宿信息功能正在开发中')),
      );
    }
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, TravelAccommodation accommodation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除住宿信息'),
        content: Text('确定要删除"${accommodation.name}"吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // TODO: 实现删除住宿信息的功能
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除住宿信息功能正在开发中')),
      );
    }
  }
}

class _AccommodationEditDialog extends StatefulWidget {
  final TravelAccommodation accommodation;

  const _AccommodationEditDialog({required this.accommodation});

  @override
  State<_AccommodationEditDialog> createState() =>
      _AccommodationEditDialogState();
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
    _addressController =
        TextEditingController(text: widget.accommodation.address);
    _phoneController = TextEditingController(text: widget.accommodation.phone);
    _priceController =
        TextEditingController(text: widget.accommodation.price.toString());
    _bookingNumberController =
        TextEditingController(text: widget.accommodation.bookingNumber);
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

            if (_priceController.text.isEmpty ||
                double.tryParse(_priceController.text) == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入有效的价格')),
              );
              return;
            }

            final updatedAccommodation = widget.accommodation.copyWith(
              name: _nameController.text,
              address: _addressController.text.isEmpty
                  ? null
                  : _addressController.text,
              phone:
                  _phoneController.text.isEmpty ? null : _phoneController.text,
              checkInDate: _checkInDate,
              checkOutDate: _checkOutDate,
              price: double.parse(_priceController.text),
              bookingNumber: _bookingNumberController.text.isEmpty
                  ? null
                  : _bookingNumberController.text,
              notes:
                  _notesController.text.isEmpty ? null : _notesController.text,
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
