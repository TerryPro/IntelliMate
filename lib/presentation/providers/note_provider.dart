import 'package:flutter/foundation.dart';
import 'package:intellimate/domain/entities/note.dart';
import 'package:intellimate/domain/usecases/note/create_note.dart';
import 'package:intellimate/domain/usecases/note/delete_note.dart';
import 'package:intellimate/domain/usecases/note/get_all_notes.dart';
import 'package:intellimate/domain/usecases/note/get_note_by_id.dart';
import 'package:intellimate/domain/usecases/note/search_notes.dart';
import 'package:intellimate/domain/usecases/note/update_note.dart';

class NoteProvider extends ChangeNotifier {
  final GetAllNotes getAllNotesUseCase;
  final GetNoteById getNoteByIdUseCase;
  final CreateNote createNoteUseCase;
  final UpdateNote updateNoteUseCase;
  final DeleteNote deleteNoteUseCase;
  final SearchNotes searchNotesUseCase;

  NoteProvider({
    required GetAllNotes getAllNotes,
    required GetNoteById getNoteById,
    required CreateNote createNote,
    required UpdateNote updateNote,
    required DeleteNote deleteNote,
    required SearchNotes searchNotes,
  })  : getAllNotesUseCase = getAllNotes,
        getNoteByIdUseCase = getNoteById,
        createNoteUseCase = createNote,
        updateNoteUseCase = updateNote,
        deleteNoteUseCase = deleteNote,
        searchNotesUseCase = searchNotes;

  // 状态变量
  List<Note> _notes = [];
  Note? _selectedNote;
  bool _isLoading = false;
  String? _error;

  // Getter
  List<Note> get notes => _notes;
  Note? get selectedNote => _selectedNote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取所有笔记
  Future<void> getAllNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getAllNotesUseCase.call();
      result.fold(
        onSuccess: (notes) => _notes = notes,
        onFailure: (error) => _error = error
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 根据ID获取笔记
  Future<Note?> getNoteById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getNoteByIdUseCase.call(id);
      Note? note;
      result.fold(
        onSuccess: (data) {
          _selectedNote = data;
          note = data;
        },
        onFailure: (error) {
          _error = error;
          note = null;
        }
      );
      return note;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建笔记
  Future<void> createNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await createNoteUseCase.call(
        title: note.title,
        content: note.content,
        tags: note.tags,
        category: note.category,
        isFavorite: note.isFavorite,
      );
      result.fold(
        onSuccess: (_) => getAllNotes(), // 重新加载笔记列表
        onFailure: (error) {
          _error = error;
          throw Exception(error);
        }
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // 向上传播错误以便UI处理
    }
  }

  // 更新笔记
  Future<void> updateNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await updateNoteUseCase.call(note);
      result.fold(
        onSuccess: (_) {
          // 更新本地缓存
          final index = _notes.indexWhere((n) => n.id == note.id);
          if (index != -1) {
            _notes[index] = note;
          }
          if (_selectedNote?.id == note.id) {
            _selectedNote = note;
          }
        },
        onFailure: (error) {
          _error = error;
          throw Exception(error);
        }
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await deleteNoteUseCase.call(id);
      result.fold(
        onSuccess: (_) {
          // 从本地缓存中移除
          _notes.removeWhere((note) => note.id == id);
          if (_selectedNote?.id == id) {
            _selectedNote = null;
          }
        },
        onFailure: (error) {
          _error = error;
          throw Exception(error);
        }
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 搜索笔记
  Future<void> searchNotes(String query) async {
    if (query.isEmpty) {
      return getAllNotes();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await searchNotesUseCase.call(query);
      result.fold(
        onSuccess: (notes) => _notes = notes,
        onFailure: (error) => _error = error
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 根据条件获取笔记
  Future<void> getNotesByCondition({
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 先获取所有笔记，然后在内存中筛选
      final result = await getAllNotesUseCase.call();
      
      result.fold(
        onFailure: (error) {
          _error = error;
        },
        onSuccess: (allNotes) {
          _notes = allNotes.where((note) {
            bool matches = true;
            
            if (category != null) {
              matches = matches && note.category == category;
            }
            
            if (isFavorite != null) {
              matches = matches && note.isFavorite == isFavorite;
            }
            
            if (tags != null && tags.isNotEmpty) {
              matches = matches && (note.tags != null && 
                tags.any((tag) => note.tags!.contains(tag)));
            }
            
            if (fromDate != null) {
              matches = matches && note.createdAt.isAfter(fromDate);
            }
            
            if (toDate != null) {
              matches = matches && note.createdAt.isBefore(toDate);
            }
            
            return matches;
          }).toList();
          
          // 排序
          if (orderBy != null) {
            _notes.sort((a, b) {
              int compare = 0;
              
              switch (orderBy) {
                case 'title':
                  compare = a.title.compareTo(b.title);
                  break;
                case 'created_at':
                  compare = a.createdAt.compareTo(b.createdAt);
                  break;
                case 'updated_at':
                  compare = a.updatedAt.compareTo(b.updatedAt);
                  break;
                default:
                  compare = a.createdAt.compareTo(b.createdAt);
              }
              
              return descending ? -compare : compare;
            });
          }
          
          // 应用limit和offset
          if (offset != null && offset > 0 && offset < _notes.length) {
            _notes = _notes.sublist(offset);
          }
          
          if (limit != null && limit > 0 && limit < _notes.length) {
            _notes = _notes.sublist(0, limit);
          }
        }
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 