import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';

class GetAllNotes {
  final NoteRepository repository;

  GetAllNotes(this.repository);

  Future<List<Note>> execute({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await repository.getAllNotes(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 