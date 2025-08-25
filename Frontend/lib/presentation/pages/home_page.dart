import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_note_app/features/notes/bloc/note_bloc.dart';
import 'package:new_note_app/features/notes/bloc/note_event.dart';
import 'package:new_note_app/features/notes/bloc/note_state.dart';
import 'package:new_note_app/presentation/pages/note_detail_page.dart';
import '../../../main.dart'; // for import routeObserver

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    // upload notes for the first opening time
    context.read<NoteBloc>().add(GetAllNotes());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // subscribe to RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // unsubscribe from RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // upload notes when coming back from NoteDetail
    context.read<NoteBloc>().add(GetAllNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App"),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NoteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NoteFailure) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is NoteSuccess) {
            final notes = state.notes;
            if (notes.isEmpty) {
              return const Center(child: Text("No notes found"));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: notes.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final noteColor = Colors
                      .primaries[index % Colors.primaries.length]
                      .shade200;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailPage(
                            noteId: note.id,
                            noteColor: noteColor,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: noteColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            note.createdAt != null
                                ? DateFormat.yMMMd().format(note.createdAt!)
                                : "",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddNoteBottomSheet(BuildContext context) {
    String title = '';
    String content = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Title"),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Content"),
                onChanged: (value) => content = value,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  context.read<NoteBloc>().add(
                        CreateNewNote(title: title, content: content),
                      );
                  Navigator.pop(context);
                },
                child: const Text("Add Note"),
              ),
            ],
          ),
        );
      },
    );
  }
}
