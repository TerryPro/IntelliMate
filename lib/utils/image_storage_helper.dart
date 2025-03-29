import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intellimate/utils/app_logger.dart';

/// 图片存储帮助类
class ImageStorageHelper {
  static final ImageStorageHelper _instance = ImageStorageHelper._internal();
  static ImageStorageHelper get instance => _instance;

  ImageStorageHelper._internal();

  /// 获取日常点滴图片目录
  Future<Directory> getDailyNotesImageDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dailyNotesDir = Directory('${appDir.path}/daily_notes');
    
    // 确保目录存在
    if (!await dailyNotesDir.exists()) {
      await dailyNotesDir.create(recursive: true);
    }
    
    return dailyNotesDir;
  }

  /// 保存图片到日常点滴目录
  /// 返回保存后的图片路径
  Future<String> saveDailyNoteImage(File imageFile) async {
    try {
      final dailyNotesDir = await getDailyNotesImageDirectory();
      
      // 生成唯一文件名
      final uuid = const Uuid().v4();
      final fileExtension = path.extension(imageFile.path);
      final fileName = 'daily_note_${uuid}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      
      // 完整的文件保存路径
      final savedPath = path.join(dailyNotesDir.path, fileName);
      
      // 复制图片文件
      final savedFile = await imageFile.copy(savedPath);
      
      return savedFile.path;
    } catch (e) {
      // 发生错误时返回原图路径
      AppLogger.log('保存图片到daily_notes目录失败: $e');
      return imageFile.path;
    }
  }

  /// 删除日常点滴图片
  Future<bool> deleteDailyNoteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      
      // 检查文件是否在daily_notes目录下
      final dailyNotesDir = await getDailyNotesImageDirectory();
      if (!imagePath.startsWith(dailyNotesDir.path)) {
        // 不在daily_notes目录下，可能是临时文件，直接返回
        return false;
      }
      
      // 如果文件存在则删除
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      AppLogger.log('删除日常点滴图片失败: $e');
      return false;
    }
  }

  /// 清理过期的日常点滴图片（可选）
  Future<int> cleanupOldImages({Duration? olderThan}) async {
    try {
      final dailyNotesDir = await getDailyNotesImageDirectory();
      final now = DateTime.now();
      final duration = olderThan ?? const Duration(days: 30); // 默认30天
      
      // 列出目录中的所有文件
      final List<FileSystemEntity> files = await dailyNotesDir.list().toList();
      int deletedCount = 0;
      
      // 检查每个文件
      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          final fileAge = now.difference(stat.modified);
          
          // 如果文件过期，则删除
          if (fileAge > duration) {
            await file.delete();
            deletedCount++;
          }
        }
      }
      
      return deletedCount;
    } catch (e) {
      AppLogger.log('清理旧图片失败: $e');
      return 0;
    }
  }
} 