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
    print('NoteProvider: 开始获取所有笔记');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getAllNotesUseCase.execute();
      _notes = result;
      print('NoteProvider: 获取到 ${_notes.length} 条笔记');
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 获取笔记失败: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 根据ID获取笔记
  Future<Note?> getNoteById(String id) async {
    print('NoteProvider: 开始获取笔记，ID: $id');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getNoteByIdUseCase.execute(id);
      _selectedNote = result;
      print('NoteProvider: 获取到笔记: ${_selectedNote?.title}');
      return result;
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 获取笔记失败: $_error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建笔记
  Future<void> createNote(Note note) async {
    print('NoteProvider: 开始创建笔记: ${note.title}');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await createNoteUseCase.execute(note);
      print('NoteProvider: 笔记创建成功');
      await getAllNotes(); // 重新加载笔记列表
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 笔记创建失败: $_error');
      _isLoading = false;
      notifyListeners();
      throw e; // 向上传播错误以便UI处理
    }
  }

  // 更新笔记
  Future<void> updateNote(Note note) async {
    print('NoteProvider: 开始更新笔记，ID: ${note.id}');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await updateNoteUseCase.execute(note);
      // 更新本地缓存
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = note;
      }
      if (_selectedNote?.id == note.id) {
        _selectedNote = note;
      }
      print('NoteProvider: 笔记更新成功');
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 笔记更新失败: $_error');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    print('NoteProvider: 开始删除笔记，ID: $id');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await deleteNoteUseCase.execute(id);
      // 从本地缓存中移除
      _notes.removeWhere((note) => note.id == id);
      if (_selectedNote?.id == id) {
        _selectedNote = null;
      }
      print('NoteProvider: 笔记删除成功');
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 笔记删除失败: $_error');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 搜索笔记
  Future<void> searchNotes(String query) async {
    print('NoteProvider: 开始搜索笔记，关键词: $query');
    if (query.isEmpty) {
      return getAllNotes();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await searchNotesUseCase.execute(query);
      _notes = result;
      print('NoteProvider: 搜索到 ${_notes.length} 条笔记');
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 搜索失败: $_error');
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
    print('NoteProvider: 开始按条件获取笔记');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 使用getAllNotesUseCase，然后在内存中过滤
      final allNotes = await getAllNotesUseCase.execute();
      
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
      
      print('NoteProvider: 按条件获取到 ${_notes.length} 条笔记');
    } catch (e) {
      _error = e.toString();
      print('NoteProvider: 按条件获取笔记失败: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 