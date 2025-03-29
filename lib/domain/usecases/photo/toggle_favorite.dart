import 'package:intellimate/domain/repositories/photo_repository.dart';

class ToggleFavorite {
  final PhotoRepository repository;

  ToggleFavorite(this.repository);

  Future<int> call(int id, bool isFavorite) async {
    return await repository.toggleFavorite(id, isFavorite);
  }
} 