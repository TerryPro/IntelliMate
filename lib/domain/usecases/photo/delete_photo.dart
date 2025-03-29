import 'package:intellimate/domain/repositories/photo_repository.dart';

class DeletePhoto {
  final PhotoRepository repository;

  DeletePhoto(this.repository);

  Future<int> call(int id) async {
    return await repository.deletePhoto(id);
  }
} 