import 'package:intellimate/data/datasources/note_datasource.dart';
import 'package:intellimate/data/models/note_model.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteDataSource dataSource;

  NoteRepositoryImpl({required this.dataSource});

  @override
  Future<List<Note>> getAllNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await dataSource.getAllNotes(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }

  @override
  Future<Note?> getNoteById(String id) async {
    return await dataSource.getNoteById(id);
  }

  @override
  Future<Note> createNote(Note note) async {
    print('NoteRepository: 开始创建笔记');
    try {
      final noteModel = NoteModel.fromEntity(note);
      print('NoteRepository: 实体转换为模型成功, 标题: ${noteModel.title}');
      final result = await dataSource.createNote(noteModel);
      print('NoteRepository: 数据源创建笔记成功, ID: ${result.id}');
      return result;
    } catch (e) {
      print('NoteRepository: 创建笔记失败: $e');
      rethrow;
    }
  }

  @override
  Future<bool> updateNote(Note note) async {
    final noteModel = NoteModel.fromEntity(note);
    final result = await dataSource.updateNote(noteModel);
    return result > 0;
  }

  @override
  Future<bool> deleteNote(String id) async {
    final result = await dataSource.deleteNote(id);
    return result > 0;
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    return await dataSource.searchNotes(query);
  }

  @override
  Future<List<Note>> getFavoriteNotes() async {
    return await dataSource.getFavoriteNotes();
  }

  @override
  Future<List<Note>> getNotesByCategory(String category) async {
    return await dataSource.getNotesByCategory(category);
  }

  @override
  Future<List<Note>> getNotesByCondition({
    String? category,
    bool? isFavorite,
    List<String>? tags,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await dataSource.getNotesByCondition(
      category: category,
      isFavorite: isFavorite,
      tags: tags,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 