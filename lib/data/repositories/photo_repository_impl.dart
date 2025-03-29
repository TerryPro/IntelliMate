import 'package:intellimate/data/datasources/photo_datasource.dart';
import 'package:intellimate/data/models/photo_model.dart';
import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/repositories/photo_repository.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoDataSource _photoDataSource;

  PhotoRepositoryImpl(this._photoDataSource);

  @override
  Future<List<Photo>> getAllPhotos() async {
    return await _photoDataSource.getAllPhotos();
  }

  @override
  Future<List<Photo>> getPhotosByAlbum(String albumId) async {
    return await _photoDataSource.getPhotosByAlbum(albumId);
  }

  @override
  Future<List<Photo>> searchPhotos(String query) async {
    return await _photoDataSource.searchPhotos(query);
  }

  @override
  Future<Photo?> getPhotoById(int id) async {
    return await _photoDataSource.getPhotoById(id);
  }

  @override
  Future<int> addPhoto(Photo photo) async {
    return await _photoDataSource.addPhoto(PhotoModel.fromEntity(photo));
  }

  @override
  Future<int> updatePhoto(Photo photo) async {
    return await _photoDataSource.updatePhoto(PhotoModel.fromEntity(photo));
  }

  @override
  Future<int> deletePhoto(int id) async {
    return await _photoDataSource.deletePhoto(id);
  }

  @override
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    return await _photoDataSource.toggleFavorite(id, isFavorite);
  }

  @override
  Future<List<Photo>> getFavoritePhotos() async {
    return await _photoDataSource.getFavoritePhotos();
  }

  @override
  Future<List<PhotoAlbum>> getAllAlbums() async {
    return await _photoDataSource.getAllAlbums();
  }

  @override
  Future<PhotoAlbum?> getAlbumById(String id) async {
    return await _photoDataSource.getAlbumById(id);
  }

  @override
  Future<String> createAlbum(PhotoAlbum album) async {
    return await _photoDataSource.createAlbum(PhotoAlbumModel.fromEntity(album));
  }

  @override
  Future<int> updateAlbum(PhotoAlbum album) async {
    return await _photoDataSource.updateAlbum(PhotoAlbumModel.fromEntity(album));
  }

  @override
  Future<int> deleteAlbum(String id) async {
    return await _photoDataSource.deleteAlbum(id);
  }

  @override
  Future<int> addPhotoToAlbum(int photoId, String albumId) async {
    return await _photoDataSource.addPhotoToAlbum(photoId, albumId);
  }

  @override
  Future<int> removePhotoFromAlbum(int photoId, String albumId) async {
    return await _photoDataSource.removePhotoFromAlbum(photoId, albumId);
  }

  @override
  Future<int> getPhotoCountByAlbum(String albumId) async {
    return await _photoDataSource.getPhotoCountByAlbum(albumId);
  }

  @override
  Future<List<Photo>> importPhotos(List<String> paths) async {
    return await _photoDataSource.importPhotos(paths);
  }

  @override
  Future<bool> exportPhotos(List<int> photoIds, String destinationPath) async {
    // 尚未实现导出功能，本期可以先不实现
    return false;
  }
} 