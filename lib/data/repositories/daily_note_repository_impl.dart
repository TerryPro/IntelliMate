import 'package:intellimate/data/datasources/daily_note_datasource.dart';
import 'package:intellimate/data/models/daily_note_model.dart';
import 'package:intellimate/domain/entities/daily_note.dart';
import 'package:intellimate/domain/repositories/daily_note_repository.dart';

class DailyNoteRepositoryImpl implements DailyNoteRepository {
  final DailyNoteDataSource _dataSource;

  DailyNoteRepositoryImpl(this._dataSource);

  @override
  Future<List<DailyNote>> getAllDailyNotes({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await _dataSource.getAllDailyNotes(
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }

  @override
  Future<DailyNote?> getDailyNoteById(String id) async {
    return await _dataSource.getDailyNoteById(id);
  }

  @override
  Future<DailyNote> createDailyNote(DailyNote dailyNote) async {
    final dailyNoteModel = DailyNoteModel.fromEntity(dailyNote);
    return await _dataSource.createDailyNote(dailyNoteModel);
  }

  @override
  Future<bool> updateDailyNote(DailyNote dailyNote) async {
    final dailyNoteModel = DailyNoteModel.fromEntity(dailyNote);
    final result = await _dataSource.updateDailyNote(dailyNoteModel);
    return result > 0;
  }

  @override
  Future<bool> deleteDailyNote(String id) async {
    final result = await _dataSource.deleteDailyNote(id);
    return result > 0;
  }

  @override
  Future<List<DailyNote>> searchDailyNotes(String query) async {
    return await _dataSource.searchDailyNotes(query);
  }

  @override
  Future<List<DailyNote>> getPrivateDailyNotes() async {
    return await _dataSource.getPrivateDailyNotes();
  }

  @override
  Future<List<DailyNote>> getDailyNotesWithCodeSnippets() async {
    return await _dataSource.getDailyNotesWithCodeSnippets();
  }

  @override
  Future<List<DailyNote>> getDailyNotesByCondition({
    String? mood,
    String? weather,
    bool? isPrivate,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = true,
  }) async {
    return await _dataSource.getDailyNotesByCondition(
      mood: mood,
      weather: weather,
      isPrivate: isPrivate,
      fromDate: fromDate,
      toDate: toDate,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      descending: descending,
    );
  }
} 