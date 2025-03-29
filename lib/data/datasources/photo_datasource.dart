import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intellimate/data/datasources/database_helper.dart';
import 'package:intellimate/data/models/photo_model.dart';
import 'package:intellimate/utils/app_logger.dart';

class PhotoDataSource {
  final DatabaseHelper _databaseHelper;
  final _uuid = Uuid();

  PhotoDataSource(this._databaseHelper);

  // 获取所有照片
  Future<List<PhotoModel>> getAllPhotos() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tablePhoto,
        orderBy: 'date_created DESC',
      );

      return List.generate(maps.length, (i) {
        return PhotoModel.fromJson(maps[i]);
      });
    } catch (e) {
      AppLogger.log('获取所有照片失败: $e');
      return [];
    }
  }

  // 根据相册ID获取照片
  Future<List<PhotoModel>> getPhotosByAlbum(String albumId) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT p.* FROM ${DatabaseHelper.tablePhoto} p
        INNER JOIN ${DatabaseHelper.tablePhotoAlbumMap} map
        ON p.id = map.photo_id
        WHERE map.album_id = ?
        ORDER BY p.date_created DESC
      ''', [albumId]);

      return List.generate(maps.length, (i) {
        return PhotoModel.fromJson(maps[i]);
      });
    } catch (e) {
      AppLogger.log('获取相册照片失败: $e');
      return [];
    }
  }

  // 搜索照片
  Future<List<PhotoModel>> searchPhotos(String query) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tablePhoto,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date_created DESC',
      );

      return List.generate(maps.length, (i) {
        return PhotoModel.fromJson(maps[i]);
      });
    } catch (e) {
      AppLogger.log('搜索照片失败: $e');
      return [];
    }
  }

  // 根据ID获取照片
  Future<PhotoModel?> getPhotoById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tablePhoto,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return PhotoModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      AppLogger.log('获取照片详情失败: $e');
      return null;
    }
  }

  // 添加照片
  Future<int> addPhoto(PhotoModel photo) async {
    try {
      final db = await _databaseHelper.database;
      final photoJson = photo.toJson();
      // 移除ID，让数据库自动生成
      photoJson.remove('id');
      final id = await db.insert(DatabaseHelper.tablePhoto, photoJson);
      
      // 如果有相册ID，则添加到相册映射表
      if (photo.albumId != null) {
        await db.insert(DatabaseHelper.tablePhotoAlbumMap, {
          'photo_id': id,
          'album_id': photo.albumId,
          'date_added': DateTime.now().millisecondsSinceEpoch,
        });
        
        // 更新相册的照片数量
        await _updateAlbumPhotoCount(photo.albumId!);
      }
      
      return id;
    } catch (e) {
      AppLogger.log('添加照片失败: $e');
      return -1;
    }
  }

  // 批量导入照片
  Future<List<PhotoModel>> importPhotos(List<String> paths) async {
    final List<PhotoModel> importedPhotos = [];
    
    for (final photoPath in paths) {
      try {
        final file = File(photoPath);
        if (await file.exists()) {
          final fileStats = await file.stat();
          final fileName = path.basename(photoPath);
          
          final photo = PhotoModel(
            path: photoPath,
            name: fileName,
            dateCreated: fileStats.changed,
            dateModified: fileStats.modified,
            size: fileStats.size,
          );
          
          final id = await addPhoto(photo);
          if (id > 0) {
            importedPhotos.add(photo.copyWith(id: id) as PhotoModel);
          }
        }
      } catch (e) {
        AppLogger.log('导入照片 $photoPath 失败: $e');
      }
    }
    
    return importedPhotos;
  }

  // 更新照片
  Future<int> updatePhoto(PhotoModel photo) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        DatabaseHelper.tablePhoto,
        photo.toJson(),
        where: 'id = ?',
        whereArgs: [photo.id],
      );
    } catch (e) {
      AppLogger.log('更新照片失败: $e');
      return 0;
    }
  }

  // 删除照片
  Future<int> deletePhoto(int id) async {
    try {
      final db = await _databaseHelper.database;
      
      // 先获取照片信息
      final photo = await getPhotoById(id);
      
      // 删除照片
      final result = await db.delete(
        DatabaseHelper.tablePhoto,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      // 如果照片属于某个相册，更新相册的照片数量
      if (photo?.albumId != null) {
        await _updateAlbumPhotoCount(photo!.albumId!);
      }
      
      return result;
    } catch (e) {
      AppLogger.log('删除照片失败: $e');
      return 0;
    }
  }

  // 设置/取消收藏照片
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        DatabaseHelper.tablePhoto,
        {'is_favorite': isFavorite ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.log('设置收藏状态失败: $e');
      return 0;
    }
  }

  // 获取收藏的照片
  Future<List<PhotoModel>> getFavoritePhotos() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tablePhoto,
        where: 'is_favorite = 1',
        orderBy: 'date_created DESC',
      );

      return List.generate(maps.length, (i) {
        return PhotoModel.fromJson(maps[i]);
      });
    } catch (e) {
      AppLogger.log('获取收藏照片失败: $e');
      return [];
    }
  }

  // 获取所有相册
  Future<List<PhotoAlbumModel>> getAllAlbums() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tablePhotoAlbum,
        orderBy: 'date_created DESC',
      );

      return List.generate(maps.length, (i) {
        return PhotoAlbumModel.fromJson(maps[i]);
      });
    } catch (e) {
      AppLogger.log('获取所有相册失败: $e');
      return [];
    }
  }

  // 根据ID获取相册
  Future<PhotoAlbumModel?> getAlbumById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseHelper.tablePhotoAlbum,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return PhotoAlbumModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      AppLogger.log('获取相册详情失败: $e');
      return null;
    }
  }

  // 创建相册
  Future<String> createAlbum(PhotoAlbumModel album) async {
    try {
      final db = await _databaseHelper.database;
      final albumId = album.id.isEmpty ? _uuid.v4() : album.id;
      
      final albumWithId = album.copyWith(
        id: albumId,
        dateCreated: DateTime.now(),
        dateModified: DateTime.now(),
      );
      
      await db.insert(DatabaseHelper.tablePhotoAlbum, albumWithId.toJson());
      return albumId;
    } catch (e) {
      AppLogger.log('创建相册失败: $e');
      return '';
    }
  }

  // 更新相册
  Future<int> updateAlbum(PhotoAlbumModel album) async {
    try {
      AppLogger.log('updateAlbum: ${album}');
      final db = await _databaseHelper.database;
      final albumWithUpdatedTime = album.copyWith(
        dateModified: DateTime.now(),
      );
      
      AppLogger.log('albumWithUpdatedTime: ${albumWithUpdatedTime}');
      
      return await db.update(
        DatabaseHelper.tablePhotoAlbum,
        albumWithUpdatedTime.toJson(),
        where: 'id = ?',
        whereArgs: [album.id],
      );
    } catch (e) {
      AppLogger.log('更新相册失败: $e');
      return 0;
    }
  }

  // 删除相册
  Future<int> deleteAlbum(String id) async {
    try {
      final db = await _databaseHelper.database;
      return await db.delete(
        DatabaseHelper.tablePhotoAlbum,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      AppLogger.log('删除相册失败: $e');
      return 0;
    }
  }

  // 添加照片到相册
  Future<int> addPhotoToAlbum(int photoId, String albumId) async {
    try {
      final db = await _databaseHelper.database;
      
      // 检查映射是否已存在
      final existingMaps = await db.query(
        DatabaseHelper.tablePhotoAlbumMap,
        where: 'photo_id = ? AND album_id = ?',
        whereArgs: [photoId, albumId],
      );
      
      if (existingMaps.isEmpty) {
        await db.insert(DatabaseHelper.tablePhotoAlbumMap, {
          'photo_id': photoId,
          'album_id': albumId,
          'date_added': DateTime.now().millisecondsSinceEpoch,
        });
        
        // 更新相册的照片数量
        await _updateAlbumPhotoCount(albumId);
        return 1;
      }
      return 0;
    } catch (e) {
      AppLogger.log('添加照片到相册失败: $e');
      return 0;
    }
  }

  // 从相册中移除照片
  Future<int> removePhotoFromAlbum(int photoId, String albumId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.delete(
        DatabaseHelper.tablePhotoAlbumMap,
        where: 'photo_id = ? AND album_id = ?',
        whereArgs: [photoId, albumId],
      );
      
      // 更新相册的照片数量
      await _updateAlbumPhotoCount(albumId);
      return result;
    } catch (e) {
      AppLogger.log('从相册移除照片失败: $e');
      return 0;
    }
  }

  // 获取相册中的照片数量
  Future<int> getPhotoCountByAlbum(String albumId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM ${DatabaseHelper.tablePhotoAlbumMap} 
        WHERE album_id = ?
      ''', [albumId]);
      
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      AppLogger.log('获取相册照片数量失败: $e');
      return 0;
    }
  }

  // 更新相册照片数量
  Future<void> _updateAlbumPhotoCount(String albumId) async {
    try {
      final photoCount = await getPhotoCountByAlbum(albumId);
      final db = await _databaseHelper.database;
      
      await db.update(
        DatabaseHelper.tablePhotoAlbum,
        {'photo_count': photoCount},
        where: 'id = ?',
        whereArgs: [albumId],
      );
    } catch (e) {
      AppLogger.log('更新相册照片数量失败: $e');
    }
  }
} 