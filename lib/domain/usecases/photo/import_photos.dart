import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/repositories/photo_repository.dart';

class ImportPhotos {
  final PhotoRepository repository;

  ImportPhotos(this.repository);

  Future<List<Photo>> call(List<String> paths) async {
    return await repository.importPhotos(paths);
  }
} 