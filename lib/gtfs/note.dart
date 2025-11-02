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

  /// Expected CSV header for notes.txt
  static List<String> expectedCsvHeader() => ['note_id', 'note_text'];

  static void validateCsvHeader(List<String> header) {
    final expected = expectedCsvHeader();
    for (var i = 0; i < expected.length; i++) {
      if (i >= header.length || header[i] != expected[i]) {
        throw FormatException(
            'notes.txt header mismatch at column ${i + 1}: expected "${expected[i]}" but found "${i < header.length ? header[i] : '<missing>'}"');
      }
    }
  }
}
