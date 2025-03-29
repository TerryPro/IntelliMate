import 'package:intellimate/domain/repositories/photo_repository.dart';
import 'package:intellimate/domain/entities/photo.dart';

class GetAllAlbums {
  final PhotoRepository repository;

  GetAllAlbums(this.repository);

  Future<List<PhotoAlbum>> call() async {
    return await repository.getAllAlbums();
  }
} 