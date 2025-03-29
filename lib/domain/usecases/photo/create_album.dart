import 'package:intellimate/domain/repositories/photo_repository.dart';
import 'package:intellimate/domain/entities/photo.dart';

class CreateAlbum {
  final PhotoRepository repository;

  CreateAlbum(this.repository);

  Future<String> call(PhotoAlbum album) async {
    return await repository.createAlbum(album);
  }
} 