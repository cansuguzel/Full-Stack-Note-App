import 'package:equatable/equatable.dart';
import '../data/models/note_model.dart';

abstract class NoteState extends Equatable {
  const NoteState();

  @override
  List<Object?> get props => [];
}

// initial state
class NoteInitial extends NoteState {}

// loading state
class NoteLoading extends NoteState {}

// success state
class NoteSuccess extends NoteState {
   final List<NoteModel> notes;

  const NoteSuccess({required this.notes});

  @override
  List<Object?> get props => [notes];
}

class SingleNoteSuccess extends NoteState {
  final NoteModel note;

  const SingleNoteSuccess({required this.note});

  @override
  List<Object?> get props => [note];
}

//failure state
class NoteFailure extends NoteState {
  final String message;

  const NoteFailure({required this.message});

  @override
  List<Object?> get props => [message];

}

class NoteDeletedSuccess extends NoteState {
  final String message;

  const NoteDeletedSuccess({required this.message});

  @override
  List<Object?> get props => [message];
  
}