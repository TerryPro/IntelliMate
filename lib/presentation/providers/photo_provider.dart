import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/usecases/photo/get_all_photos.dart';
import 'package:intellimate/domain/usecases/photo/get_photos_by_album.dart';
import 'package:intellimate/domain/usecases/photo/get_all_albums.dart';
import 'package:intellimate/domain/usecases/photo/create_album.dart';
import 'package:intellimate/domain/usecases/photo/add_photo.dart';
import 'package:intellimate/domain/usecases/photo/import_photos.dart';
import 'package:intellimate/domain/usecases/photo/update_photo.dart';
import 'package:intellimate/domain/usecases/photo/delete_photo.dart';
import 'package:intellimate/domain/usecases/photo/toggle_favorite.dart';
import 'package:intellimate/domain/usecases/photo/update_album.dart';
import 'package:intellimate/domain/usecases/photo/delete_album.dart';
import 'package:intellimate/utils/app_logger.dart';

class PhotoProvider extends ChangeNotifier {
  final GetAllPhotos _getAllPhotos;
  final GetPhotosByAlbum _getPhotosByAlbum;
  final GetAllAlbums _getAllAlbums;
  final CreateAlbum _createAlbum;
  final AddPhoto _addPhoto;
  final ImportPhotos _importPhotos;
  final UpdatePhoto _updatePhoto;
  final DeletePhoto _deletePhoto;
  final ToggleFavorite _toggleFavorite;
  final UpdateAlbum _updateAlbum;
  final DeleteAlbum _deleteAlbum;
  
  PhotoProvider({
    required GetAllPhotos getAllPhotos,
    required GetPhotosByAlbum getPhotosByAlbum,
    required GetAllAlbums getAllAlbums,
    required CreateAlbum createAlbum,
    required AddPhoto addPhoto,
    required ImportPhotos importPhotos,
    required UpdatePhoto updatePhoto,
    required DeletePhoto deletePhoto,
    required ToggleFavorite toggleFavorite,
    required UpdateAlbum updateAlbum,
    required DeleteAlbum deleteAlbum,
  }) : _getAllPhotos = getAllPhotos,
       _getPhotosByAlbum = getPhotosByAlbum,
       _getAllAlbums = getAllAlbums,
       _createAlbum = createAlbum,
       _addPhoto = addPhoto,
       _importPhotos = importPhotos,
       _updatePhoto = updatePhoto,
       _deletePhoto = deletePhoto,
       _toggleFavorite = toggleFavorite,
       _updateAlbum = updateAlbum,
       _deleteAlbum = deleteAlbum;
  
  // 状态
  bool _isLoading = false;
  String? _error;
  List<Photo> _photos = [];
  List<PhotoAlbum> _albums = [];
  PhotoAlbum? _currentAlbum;
  List<Photo> _currentAlbumPhotos = [];
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Photo> get photos => _photos;
  List<PhotoAlbum> get albums => _albums;
  PhotoAlbum? get currentAlbum => _currentAlbum;
  List<Photo> get currentAlbumPhotos => _currentAlbumPhotos;
  
  // 加载所有照片
  Future<void> loadAllPhotos() async {
    _setLoading(true);
    try {
      _photos = await _getAllPhotos();
      _error = null;
    } catch (e) {
      _error = '加载照片失败: $e';
      AppLogger.log(_error!);
    } finally {
      _setLoading(false);
    }
  }
  
  // 加载所有相册
  Future<void> loadAllAlbums() async {
    _setLoading(true);
    try {
      _albums = await _getAllAlbums();
      _error = null;
    } catch (e) {
      _error = '加载相册失败: $e';
      AppLogger.log(_error!);
    } finally {
      _setLoading(false);
    }
  }
  
  // 加载相册中的照片
  Future<void> loadAlbumPhotos(String albumId) async {
    _setLoading(true);
    try {
      // 设置当前相册
      _currentAlbum = _albums.firstWhere((album) => album.id == albumId);
      // 加载相册中的照片
      _currentAlbumPhotos = await _getPhotosByAlbum(albumId);
      _error = null;
    } catch (e) {
      _error = '加载相册照片失败: $e';
      AppLogger.log(_error!);
    } finally {
      _setLoading(false);
    }
  }
  
  // 创建新相册
  Future<String?> createNewAlbum(String name, {String? description}) async {
    _setLoading(true);
    try {
      final uuid = Uuid();
      final newAlbumId = uuid.v4();
      final album = PhotoAlbum(
        id: newAlbumId,
        name: name,
        description: description,
        dateCreated: DateTime.now(),
        dateModified: DateTime.now(),
        photoCount: 0,
      );
      
      final albumId = await _createAlbum(album);
      if (albumId.isNotEmpty) {
        // 获取最新的所有相册，确保UI更新
        await loadAllAlbums();
        return albumId;
      }
      return null;
    } catch (e) {
      _error = '创建相册失败: $e';
      AppLogger.log(_error!);
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // 从相机拍摄照片
  Future<Photo?> takePhoto({String? albumId}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        // 将照片保存到指定目录 files/photos
        final appDir = await getApplicationDocumentsDirectory();
        final photosDir = Directory('${appDir.path}/files/photos');
        
        // 确保目录存在
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }
        
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        final savedImage = await File(image.path).copy('${photosDir.path}/$fileName');
        
        // 获取照片信息
        final fileStats = await savedImage.stat();
        
        // 创建照片对象
        final photo = Photo(
          path: savedImage.path,
          name: fileName,
          dateCreated: DateTime.now(),
          dateModified: DateTime.now(),
          size: fileStats.size,
          albumId: albumId,
        );
        
        // 保存到数据库
        final id = await _addPhoto(photo);
        if (id > 0) {
          final newPhoto = photo.copyWith(id: id);
          // 重新加载照片列表以确保UI更新
          await loadAllPhotos();
          // 如果属于特定相册，也更新相册中的照片
          if (albumId != null && albumId == _currentAlbum?.id) {
            await loadAlbumPhotos(albumId);
          }
          return newPhoto;
        }
      }
      return null;
    } catch (e) {
      _error = '拍照失败: $e';
      AppLogger.log(_error!);
      return null;
    }
  }
  
  // 从相册选择照片
  Future<List<Photo>> pickPhotos({String? albumId}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        // 将照片保存到指定目录 files/photos
        final appDir = await getApplicationDocumentsDirectory();
        final photosDir = Directory('${appDir.path}/files/photos');
        
        // 确保目录存在
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }
        
        final List<String> savedPaths = [];
        
        // 保存所有选中的照片到指定目录
        for (final image in images) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
          final savedImage = await File(image.path).copy('${photosDir.path}/$fileName');
          savedPaths.add(savedImage.path);
        }
        
        // 导入照片
        final importedPhotos = await _importPhotos(savedPaths);
        
        // 重新加载照片列表以确保UI更新
        await loadAllPhotos();
        
        // 如果属于特定相册，也更新相册中的照片
        if (albumId != null && albumId == _currentAlbum?.id) {
          await loadAlbumPhotos(albumId);
        }
        
        return importedPhotos;
      }
      return [];
    } catch (e) {
      _error = '选择照片失败: $e';
      AppLogger.log(_error!);
      return [];
    }
  }
  
  // 更新照片信息
  Future<bool> updatePhoto(Photo photo) async {
    _setLoading(true);
    try {
      final result = await _updatePhoto(photo);
      if (result > 0) {
        // 更新本地列表
        final index = _photos.indexWhere((p) => p.id == photo.id);
        if (index != -1) {
          _photos[index] = photo;
        }
        
        // 如果是当前相册的照片，也更新相册照片列表
        if (_currentAlbum != null && photo.albumId == _currentAlbum!.id) {
          final albumIndex = _currentAlbumPhotos.indexWhere((p) => p.id == photo.id);
          if (albumIndex != -1) {
            _currentAlbumPhotos[albumIndex] = photo;
          }
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = '更新照片失败: $e';
      AppLogger.log(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 删除照片
  Future<bool> deletePhoto(int photoId) async {
    _setLoading(true);
    try {
      // 使用真实的删除照片用例
      final result = await _deletePhoto(photoId);
      if (result > 0) {
        // 重新加载照片列表
        await loadAllPhotos();
        
        // 如果是当前相册的照片，也重新加载相册照片
        if (_currentAlbum != null) {
          await loadAlbumPhotos(_currentAlbum!.id);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = '删除照片失败: $e';
      AppLogger.log(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 切换照片收藏状态
  Future<bool> togglePhotoFavorite(int photoId, bool isFavorite) async {
    try {
      // 使用真实的收藏照片用例
      final result = await _toggleFavorite(photoId, isFavorite);
      if (result > 0) {
        // 重新加载照片列表
        await loadAllPhotos();
        
        // 如果是当前相册的照片，也重新加载相册照片
        if (_currentAlbum != null) {
          await loadAlbumPhotos(_currentAlbum!.id);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      _error = '更新收藏状态失败: $e';
      AppLogger.log(_error!);
      return false;
    }
  }
  
  // 更新相册
  Future<bool> updateAlbum(PhotoAlbum album) async {
    _setLoading(true);
    try {
      // 使用真实的更新相册用例
      final result = await _updateAlbum(album);
      if (result > 0) {
        // 更新列表中的相册
        final index = _albums.indexWhere((a) => a.id == album.id);
        if (index != -1) {
          _albums[index] = album;
        }
        
        // 如果是当前相册，也更新当前相册
        if (_currentAlbum != null && _currentAlbum!.id == album.id) {
          _currentAlbum = album;
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = '更新相册失败: $e';
      AppLogger.log(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 删除相册
  Future<bool> deleteAlbum(String albumId) async {
    _setLoading(true);
    try {
      // 使用真实的删除相册用例
      final result = await _deleteAlbum(albumId);
      if (result > 0) {
        // 从列表中移除
        _albums.removeWhere((album) => album.id == albumId);
        
        // 如果是当前相册，清空当前相册
        if (_currentAlbum != null && _currentAlbum!.id == albumId) {
          _currentAlbum = null;
          _currentAlbumPhotos = [];
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = '删除相册失败: $e';
      AppLogger.log(_error!);
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 