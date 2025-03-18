import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';
import 'package:intellimate/domain/core/result.dart';
import 'package:intellimate/data/models/daily_note_model.dart';

class CreateDailyNote {
  final DailyNoteRepository repository;

  CreateDailyNote(this.repository);

  Future<Result<DailyNoteModel>> call({
    required String content,
    required DateTime date,
    String? mood,
    String? weather,
    bool isPrivate = false,
    List<String>? images,
    List<String>? codeSnippets,
    List<String>? tags,
  }) async {
    try {
      return await repository.createDailyNote(
        content: content,
        date: date,
        mood: mood,
        weather: weather,
        isPrivate: isPrivate,
        images: images,
        codeSnippets: codeSnippets,
        tags: tags,
      );
    } catch (e) {
      return Result.failure("创建日常点滴失败: $e");
    }
  }
} 