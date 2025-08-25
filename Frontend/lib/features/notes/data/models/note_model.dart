class NoteModel {
  final int id;
  final String title;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

factory NoteModel.fromJson(Map<String, dynamic> json) {
  return NoteModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
// this file defines a NoteModel class that represents a note in the system.
// It includes properties for note details, methods to convert to and from JSON,
// and a copyWith method for creating modified copies of the note object.