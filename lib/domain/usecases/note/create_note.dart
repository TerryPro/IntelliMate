import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';

class CreateNote {
  final NoteRepository repository;

  CreateNote(this.repository);

  Future<Note> execute(Note note) async {
    return await repository.createNote(note);
  }
} 