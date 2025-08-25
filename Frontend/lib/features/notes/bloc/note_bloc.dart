import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_note_app/features/notes/data/models/note_model.dart';
import 'note_event.dart';
import 'note_state.dart';
import '../note_repository.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository noteRepository;

  NoteBloc({required this.noteRepository}) : super(NoteInitial()) {
    on<GetAllNotes>((event, emit) async {
      emit(NoteLoading());
      try {
        final notes = await noteRepository.getAllNotes();
        emit(NoteSuccess(notes: notes));
      } catch (e) {
        emit(NoteFailure(message: e.toString()));
      }
    });
       
// create note
on<CreateNewNote>((event, emit) async {
  emit(NoteLoading());
  try {
    await noteRepository.createNote(
      title: event.title,
      content: event.content,
    );

    //all list taken from backend after note created
    final updatedNotes = await noteRepository.getAllNotes();
    emit(NoteSuccess(notes: updatedNotes));

  } catch (e) {
    emit(NoteFailure(message: e.toString()));
  }
});

on<GetSpecificNote>((event, emit) async {
  emit(NoteLoading());
  try {
    final NoteModel note = await noteRepository.getSpecificNote(event.id);
    emit(SingleNoteSuccess(note: note));
  } catch (e) {
    emit(NoteFailure(message: e.toString()));
  }
});

on<UpdateNote>((event, emit) async {
  emit(NoteLoading());
  try {
    await noteRepository.updateNote(
      id: event.id,
      title: event.title,
      content: event.content,
    );
    // note taken again after updated
    final updatedNote = await noteRepository.getSpecificNote(event.id);
    emit(SingleNoteSuccess(note: updatedNote));
  } catch (e) {
    emit(NoteFailure(message: e.toString()));
  }
});

on<DeleteNote>((event, emit) async {
  emit(NoteLoading());
  try {
    final message = await noteRepository.deleteNote(event.id);
    emit(NoteDeletedSuccess(message: message));
  } catch (e) {
    emit(NoteFailure(message: e.toString()));
  }
});  
}}