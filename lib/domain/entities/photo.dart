class Photo {
  final int? id;
  final String path;
  final String? name;
  final String? description;
  final DateTime dateCreated;
  final DateTime dateModified;
  final bool isFavorite;
  final String? albumId;
  final int size; // 文件大小，单位为字节
  final String? location;
  final Map<String, dynamic>? metadata;

  Photo({
    this.id,
    required this.path,
    this.name,
    this.description,
    required this.dateCreated,
    required this.dateModified,
    this.isFavorite = false,
    this.albumId,
    required this.size,
    this.location,
    this.metadata,
  });

  Photo copyWith({
    int? id,
    String? path,
    String? name,
    String? description,
    DateTime? dateCreated,
    DateTime? dateModified,
    bool? isFavorite,
    String? albumId,
    int? size,
    String? location,
    Map<String, dynamic>? metadata,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      description: description ?? this.description,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      isFavorite: isFavorite ?? this.isFavorite,
      albumId: albumId ?? this.albumId,
      size: size ?? this.size,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PhotoAlbum {
  final String id;
  final String name;
  final String? coverPhotoPath;
  final DateTime dateCreated;
  final DateTime dateModified;
  final int photoCount;
  final String? description;

  PhotoAlbum({
    required this.id,
    required this.name,
    this.coverPhotoPath,
    required this.dateCreated,
    required this.dateModified,
    this.photoCount = 0,
    this.description,
  });

  PhotoAlbum copyWith({
    String? id,
    String? name,
    String? coverPhotoPath,
    DateTime? dateCreated,
    DateTime? dateModified,
    int? photoCount,
    String? description,
  }) {
    return PhotoAlbum(
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