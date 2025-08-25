import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_note_app/features/notes/bloc/note_bloc.dart';
import 'package:new_note_app/features/notes/bloc/note_event.dart';
import 'package:new_note_app/features/notes/bloc/note_state.dart';
import 'package:new_note_app/presentation/pages/note_update_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;
  final Color noteColor;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
    required this.noteColor,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  @override
  void initState() {
    super.initState();
    // take note when the pages opened
    context.read<NoteBloc>().add(GetSpecificNote(id: widget.noteId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Note Detail")),
      body: BlocListener<NoteBloc, NoteState>(
        listener: (context, state) {
          // if note is deleted successfully
          if (state is NoteDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context); // go back to the list
          }

          // if there is an error
          if (state is NoteFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: BlocBuilder<NoteBloc, NoteState>(
          builder: (context, state) {
            if (state is NoteLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NoteFailure) {
              return Center(child: Text("Error: ${state.message}"));
            } else if (state is SingleNoteSuccess) {
              return _buildNoteDetail(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNoteDetail(BuildContext context, SingleNoteSuccess state) {
    final note = state.note;
    double boxHeight = MediaQuery.of(context).size.height * 0.7;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: boxHeight,
            decoration: BoxDecoration(
              color: widget.noteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color.fromARGB(255, 52, 52, 52),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          note.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color.fromARGB(221, 35, 35, 35),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Row(
                    children: [
                      _buildCircleIconButton(
                        icon: Icons.edit,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteUpdatePage(note: note),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildCircleIconButton(
                        icon: Icons.delete,
                        onPressed: () => _confirmDelete(context, widget.noteId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              note.createdAt != null
                  ? "Created: ${DateFormat.yMMMd().format(note.createdAt!)}"
                  : "",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.read<NoteBloc>().add(DeleteNote(id: id));
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
