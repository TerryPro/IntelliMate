import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intellimate/utils/app_logger.dart';


class PermissionHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  /// 请求外部存储权限
  static Future<bool> requestStoragePermission() async {
    // Android 13+ (API 33) 需要使用新的媒体权限
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSDKVersion();
      AppLogger.log('Android SDK 版本: $sdkVersion');
      
      if (sdkVersion >= 33) {
        // 请求Android 13+的媒体权限
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        final audio = await Permission.audio.request();
        
        // 所有权限都需要授权
        return photos.isGranted && videos.isGranted && audio.isGranted;
      }
    }
    
    // 检查是否已有权限
    final status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    }
    
    // 请求权限
    final result = await Permission.storage.request();
    return result.isGranted;
  }
  
  /// 检查是否有外部存储权限
  static Future<bool> hasStoragePermission() async {
    // Android 13+ (API 33) 需要检查媒体权限
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSDKVersion();
      if (sdkVersion >= 33) {
        return await Permission.photos.isGranted && 
               await Permission.videos.isGranted && 
               await Permission.audio.isGranted;
      }
    }
    
    return await Permission.storage.isGranted;
  }
  
  /// 获取Android SDK版本号
  static Future<int> _getAndroidSDKVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      }
    } catch (e) {
      AppLogger.log('获取Android SDK版本失败: $e');
    }
    return 29; // 默认为Android 10
  }
} 