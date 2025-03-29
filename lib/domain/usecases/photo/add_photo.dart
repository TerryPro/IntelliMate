import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/repositories/photo_repository.dart';

class AddPhoto {
  final PhotoRepository repository;

  AddPhoto(this.repository);

  Future<int> call(Photo photo) async {
    return await repository.addPhoto(photo);
  }
} 