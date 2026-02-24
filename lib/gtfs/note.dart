/// Note: This is a non-standard extension used by NSW Transport API
class Note {
  final String noteId;
  final String noteText;

  Note({required this.noteId, required this.noteText});

  /// Create a Note from a CSV row using header-based field mapping
  factory Note.fromCsv(List<String> header, List<String> row) {
    String getField(String fieldName, {String defaultValue = ''}) {
      final index = header.indexOf(fieldName);
      if (index == -1 || index >= row.length) return defaultValue;
      final value = row[index];
      return value.isEmpty ? defaultValue : value;
    }

    return Note(noteId: getField('note_id'), noteText: getField('note_text'));
  }

  /// Expected CSV header for notes.txt (non-standard NSW Transport API extension)
  static List<String> expectedCsvHeader() => ['note_id', 'note_text'];

  static void validateCsvHeader(List<String> header) {
    // Both fields are required for this non-standard file
    final required = expectedCsvHeader();
    for (final col in required) {
      if (!header.contains(col)) {
        throw FormatException('notes.txt missing required column "$col"');
      }
    }
  }
}
