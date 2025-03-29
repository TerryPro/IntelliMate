import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/repositories/photo_repository.dart';

class GetAllPhotos {
  final PhotoRepository repository;

  GetAllPhotos(this.repository);

  Future<List<Photo>> call() async {
    return await repository.getAllPhotos();
  }
} 