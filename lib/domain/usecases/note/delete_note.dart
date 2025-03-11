import 'package:intellimate/domain/repositories/note_repository.dart';

class DeleteNote {
  final NoteRepository repository;

  DeleteNote(this.repository);

  Future<bool> execute(String id) async {
    return await repository.deleteNote(id);
  }
} 