import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intellimate/app/theme/app_colors.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/presentation/providers/daily_note_provider.dart';
import 'package:intellimate/presentation/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:intellimate/utils/app_logger.dart';

class DailyNoteDetailScreen extends StatefulWidget {
  final DailyNote dailyNote;

  const DailyNoteDetailScreen({Key? key, required this.dailyNote}) : super(key: key);

  @override
  _DailyNoteDetailScreenState createState() => _DailyNoteDetailScreenState();
}

class _DailyNoteDetailScreenState extends State<DailyNoteDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Daily Note'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageContent(),
            // ... rest of the existing code ...
          ],
        ),
      ),
    );
  }

  // 构建图片内容
  Widget _buildImageContent() {
    if (widget.dailyNote.images == null || widget.dailyNote.images!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Builder(
              builder: (context) {
                final imagePath = widget.dailyNote.images!.first;
                final imageFile = File(imagePath);
                
                // 检查文件是否存在
                try {
                  if (imageFile.existsSync()) {
                    return Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    );
                  } else {
                    AppLogger.log('图片文件不存在: $imagePath');
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  }
                } catch (e) {
                  AppLogger.log('加载图片失败: $e');
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
} 