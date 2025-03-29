import 'package:intellimate/domain/entities/photo.dart';
import 'package:intellimate/domain/repositories/photo_repository.dart';

class UpdatePhoto {
  final PhotoRepository repository;

  UpdatePhoto(this.repository);

  Future<int> call(Photo photo) async {
    return await repository.updatePhoto(photo);
  }
} 