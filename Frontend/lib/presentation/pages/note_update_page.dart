import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_note_app/features/notes/bloc/note_bloc.dart';
import 'package:new_note_app/features/notes/bloc/note_event.dart';
import 'package:new_note_app/features/notes/bloc/note_state.dart';
import 'package:new_note_app/features/notes/data/models/note_model.dart';

class NoteUpdatePage extends StatefulWidget {
  final NoteModel note;

  const NoteUpdatePage({Key? key, required this.note}) : super(key: key);

  @override
  State<NoteUpdatePage> createState() => _NoteUpdatePageState();
}

class _NoteUpdatePageState extends State<NoteUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  bool _isSaved = false; 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaved = true;
      });

      context.read<NoteBloc>().add(
            UpdateNote(
              id: widget.note.id,
              title: _titleController.text.trim(),
              content: _contentController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    double boxHeight = MediaQuery.of(context).size.height * 0.7;

    return Scaffold(
      appBar: AppBar(title: const Text("Update Note")),
      body: Center(
        child: SizedBox(
          height: boxHeight,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: BlocConsumer<NoteBloc, NoteState>(
                listener: (context, state) {
                  if (state is NoteSuccess) {
                    context.read<NoteBloc>().add(GetAllNotes());
                    Navigator.pop(context);
                  } else if (state is NoteFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                    setState(() {
                      _isSaved = false; 
                    });
                  }
                },
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: "Title",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Title cannot be empty";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contentController,
                              decoration: const InputDecoration(
                                labelText: "Content",
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 6,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Content cannot be empty";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaved ? null : _updateNote,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isSaved ? "Saved" : "Save Changes",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
