import 'data/models/note_model.dart';
import 'data/note_remote_data_source.dart';


class NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepository({required this.remoteDataSource});

  Future<List<NoteModel>> getAllNotes() async {
    try {
      final List<NoteModel> notes = await remoteDataSource.getAllNotes();
      return notes;
    } catch (e) {
      rethrow;
    }
  }
    
  
  Future<NoteModel> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final NoteModel note = await remoteDataSource.createNote(
        title: title,
        content: content,
      );
      return note;
    } catch (e) {
      rethrow;
    }
  }

  Future<NoteModel> updateNote({
    required int id,
    required String title,
    required String content,
  }) async {
    try {
      final NoteModel note = await remoteDataSource.updateNote(
        id: id,
        title: title,
        content: content,
      );
      return note;
    } catch (e) {
      rethrow;
    }
  }

      

  Future<NoteModel> getSpecificNote(int id) async {
    try {
      final NoteModel note = await remoteDataSource.getSpecificNote(id);
      return note;
    } catch (e) {
      rethrow;
    }
  }


   Future<String> deleteNote(int id) async {
    try {
      final String message = await remoteDataSource.deleteNote(id);
      return message;
    } catch (e) {
      rethrow;
    }
  }
}

  