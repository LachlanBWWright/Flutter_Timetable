class Note {
  final String noteId;
  final String noteText;

  Note({
    required this.noteId,
    required this.noteText,
  });

  factory Note.fromCsv(List<String> row) => Note(
        noteId: row[0],
        noteText: row[1],
      );
}
