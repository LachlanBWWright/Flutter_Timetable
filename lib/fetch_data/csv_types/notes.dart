/// Dart class for GTFS notes.txt
class Note {
  final String noteId;
  final String noteText;

  Note({
    required this.noteId,
    required this.noteText,
  });

  factory Note.fromCsvRow(List<String> row) => Note(
        noteId: row[0],
        noteText: row[1],
      );

  List<String> toCsvRow() => [noteId, noteText];
}
