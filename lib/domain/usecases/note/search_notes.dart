import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';

class SearchNotes {
  final NoteRepository repository;

  SearchNotes(this.repository);

  Future<List<Note>> execute(String query) async {
    return await repository.searchNotes(query);
  }
} 