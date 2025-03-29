import 'package:intellimate/domain/entities/photo.dart';

abstract class PhotoRepository {
  // 照片管理
  Future<List<Photo>> getAllPhotos();
  Future<List<Photo>> getPhotosByAlbum(String albumId);
  Future<List<Photo>> searchPhotos(String query);
  Future<Photo?> getPhotoById(int id);
  Future<int> addPhoto(Photo photo);
  Future<int> updatePhoto(Photo photo);
  Future<int> deletePhoto(int id);
  Future<int> toggleFavorite(int id, bool isFavorite);
  Future<List<Photo>> getFavoritePhotos();
  
  // 相册管理
  Future<List<PhotoAlbum>> getAllAlbums();
  Future<PhotoAlbum?> getAlbumById(String id);
  Future<String> createAlbum(PhotoAlbum album);
  Future<int> updateAlbum(PhotoAlbum album);
  Future<int> deleteAlbum(String id);
  Future<int> addPhotoToAlbum(int photoId, String albumId);
  Future<int> removePhotoFromAlbum(int photoId, String albumId);
  Future<int> getPhotoCountByAlbum(String albumId);
  
  // 导入导出
  Future<List<Photo>> importPhotos(List<String> paths);
  Future<bool> exportPhotos(List<int> photoIds, String destinationPath);
} 