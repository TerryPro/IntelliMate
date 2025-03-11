import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';

class GetNoteById {
  final NoteRepository repository;

  GetNoteById(this.repository);

  Future<Note?> execute(String id) async {
    return await repository.getNoteById(id);
  }
} 