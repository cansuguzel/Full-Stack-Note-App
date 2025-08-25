import 'package:dio/dio.dart';
import 'package:new_note_app/core/secure_storage.dart';
import 'package:new_note_app/features/notes/data/models/note_model.dart';

class NoteRemoteDataSource {
  final Dio dio;
  final SecureStorage secureStorage;

  // Pass token when constructing NoteRemoteDataSource
  NoteRemoteDataSource({required this.dio, required this.secureStorage});

  Future<List<NoteModel>> getAllNotes() async {
    try {
      final response = await dio.get(
        '/notes/',
      );
      // Parse response data as a list of NoteModel
      final List<dynamic> notesJson = response.data as List<dynamic>;
      return notesJson.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<NoteModel> createNote({
    required String title,
    required String content,
  }) async {
    try {
      final response = await dio.post(
        '/notes/',
        data: {
          'title': title,
          'content': content,
        }, 
      );

      final noteJson = response.data['note'];
      final note = NoteModel.fromJson(noteJson);
      return note;

    } on DioException catch (e) {
      print('CREATE NOTE REQUEST FAILED: ${e.message}');
      rethrow;
    }
  }

  Future<NoteModel> updateNote({
    required int id,
    required String title,
    required String content,
  }) async {
    try {
      final response = await dio.put(
        '/notes/$id',
        data: {
          'title': title,
          'content': content,
        },
      );
      final noteJson = response.data['note'];
      final note = NoteModel.fromJson(noteJson);
      return note;

    } on DioException catch (e) {
      print('CREATE NOTE REQUEST FAILED: ${e.message}');
      rethrow;
    }
  }

  Future<NoteModel> getSpecificNote(int id) async {
    try {
      final response = await dio.get(
        '/notes/$id',
      );

      return NoteModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

    Future<String> deleteNote(int id) async {
    try {
      final response = await dio.delete(
        '/notes/$id',
      );

      return response.data['message'];
    } catch (e) {
      rethrow;
    }
  }
}
