import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/repositories/photo_repository.dart';

class GetPhotosByAlbum {
  final PhotoRepository repository;

  GetPhotosByAlbum(this.repository);

  Future<List<Photo>> call(String albumId) async {
    return await repository.getPhotosByAlbum(albumId);
  }
} 