import 'package:intellimate/domain/usecases/daily_note/create_daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/delete_daily_note.dart';
import 'package:intellimate/domain/usecases/daily_note/get_all_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_note_by_id.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_notes_by_condition.dart';
import 'package:intellimate/domain/usecases/daily_note/get_daily_notes_with_code_snippets.dart';
import 'package:intellimate/domain/usecases/daily_note/get_private_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/search_daily_notes.dart';
import 'package:intellimate/domain/usecases/daily_note/update_daily_note.dart';

class DailyNoteUseCases {
  final CreateDailyNote createDailyNote;
  final DeleteDailyNote deleteDailyNote;
  final GetAllDailyNotes getAllDailyNotes;
  final GetDailyNoteById getDailyNoteById;
  final GetDailyNotesByCondition getDailyNotesByCondition;
  final GetDailyNotesWithCodeSnippets getDailyNotesWithCodeSnippets;
  final GetPrivateDailyNotes getPrivateDailyNotes;
  final SearchDailyNotes searchDailyNotes;
  final UpdateDailyNote updateDailyNote;

  DailyNoteUseCases({
    required this.createDailyNote,
    required this.deleteDailyNote,
    required this.getAllDailyNotes,
    required this.getDailyNoteById,
    required this.getDailyNotesByCondition,
    required this.getDailyNotesWithCodeSnippets,
    required this.getPrivateDailyNotes,
    required this.searchDailyNotes,
    required this.updateDailyNote,
  });
} 