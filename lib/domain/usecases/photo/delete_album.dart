import 'package:intellimate/domain/repositories/photo_repository.dart';

class DeleteAlbum {
  final PhotoRepository repository;

  DeleteAlbum(this.repository);

  Future<int> call(String id) async {
    return await repository.deleteAlbum(id);
  }
} 