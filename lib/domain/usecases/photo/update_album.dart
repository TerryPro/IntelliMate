import 'package:intellimate/domain/repositories/photo_repository.dart';
import 'package:intellimate/domain/entities/photo.dart';

class UpdateAlbum {
  final PhotoRepository repository;

  UpdateAlbum(this.repository);

  Future<int> call(PhotoAlbum album) async {
    return await repository.updateAlbum(album);
  }
} 