import 'dart:convert';
import 'package:intellimate/domain/entities/photo.dart';

class PhotoModel extends Photo {
  PhotoModel({
    int? id,
    required String path,
    String? name,
    String? description,
    required DateTime dateCreated,
    required DateTime dateModified,
    bool isFavorite = false,
    String? albumId,
    required int size,
    String? location,
    Map<String, dynamic>? metadata,
  }) : super(
          id: id,
          path: path,
          name: name,
          description: description,
          dateCreated: dateCreated,
          dateModified: dateModified,
          isFavorite: isFavorite,
          albumId: albumId,
          size: size,
          location: location,
          metadata: metadata,
        );

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'],
      path: json['path'],
      name: json['name'],
      description: json['description'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(json['date_created']),
      dateModified: DateTime.fromMillisecondsSinceEpoch(json['date_modified']),
      isFavorite: json['is_favorite'] == 1,
      albumId: json['album_id'],
      size: json['size'],
      location: json['location'],
      metadata: json['metadata'] != null 
          ? jsonDecode(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'description': description,
      'date_created': dateCreated.millisecondsSinceEpoch,
      'date_modified': dateModified.millisecondsSinceEpoch,
      'is_favorite': isFavorite ? 1 : 0,
      'album_id': albumId,
      'size': size,
      'location': location,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory PhotoModel.fromEntity(Photo photo) {
    return PhotoModel(
      id: photo.id,
      path: photo.path,
      name: photo.name,
      description: photo.description,
      dateCreated: photo.dateCreated,
      dateModified: photo.dateModified,
      isFavorite: photo.isFavorite,
      albumId: photo.albumId,
      size: photo.size,
      location: photo.location,
      metadata: photo.metadata,
    );
  }
}

class PhotoAlbumModel extends PhotoAlbum {
  PhotoAlbumModel({
    required String id,
    required String name,
    String? coverPhotoPath,
    required DateTime dateCreated,
    required DateTime dateModified,
    int photoCount = 0,
    String? description,
  }) : super(
          id: id,
          name: name,
          coverPhotoPath: coverPhotoPath,
          dateCreated: dateCreated,
          dateModified: dateModified,
          photoCount: photoCount,
          description: description,
        );

  factory PhotoAlbumModel.fromJson(Map<String, dynamic> json) {
    return PhotoAlbumModel(
      id: json['id'],
      name: json['name'],
      coverPhotoPath: json['cover_photo_path'],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(json['date_created']),
      dateModified: DateTime.fromMillisecondsSinceEpoch(json['date_modified']),
      photoCount: json['photo_count'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover_photo_path': coverPhotoPath,
      'date_created': dateCreated.millisecondsSinceEpoch,
      'date_modified': dateModified.millisecondsSinceEpoch,
      'photo_count': photoCount,
      'description': description,
    };
  }

  factory PhotoAlbumModel.fromEntity(PhotoAlbum album) {
    return PhotoAlbumModel(
      id: album.id,
      name: album.name,
      coverPhotoPath: album.coverPhotoPath,
      dateCreated: album.dateCreated,
      dateModified: album.dateModified,
      photoCount: album.photoCount,
      description: album.description,
    );
  }

  PhotoAlbumModel copyWith({
    String? id,
    String? name,
    String? coverPhotoPath,
    DateTime? dateCreated,
    DateTime? dateModified,
    int? photoCount,
    String? description,
  }) {
    return PhotoAlbumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      photoCount: photoCount ?? this.photoCount,
      description: description ?? this.description,
    );
  }
} 