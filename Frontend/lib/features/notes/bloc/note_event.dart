import 'package:equatable/equatable.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class CreateNewNote extends NoteEvent {
  final String title;
  final String content;

  const CreateNewNote({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class GetAllNotes extends NoteEvent {}

class GetSpecificNote extends NoteEvent {
  final int id;

  const GetSpecificNote({required this.id});

  @override
  List<Object?> get props => [id];
}

class UpdateNote extends NoteEvent {
  final int id;
  final String title;
  final String content;

  const UpdateNote({
    required this.id,
    required this.title,
    required this.content,
  });

  @override
  List<Object?> get props => [id, title, content];
}

class DeleteNote extends NoteEvent {
  final int id;

  const DeleteNote({required this.id});

  @override
  List<Object?> get props => [id];
}