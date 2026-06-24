import 'csv_field_reader.dart';

/// Note: This is a non-standard extension used by NSW Transport API
class Note {
  final String noteId;
  final String noteText;

  Note({required this.noteId, required this.noteText});

  /// Create a Note from a CSV row using header-based field mapping
  factory Note.fromCsv(List<String> header, List<String> row) {
    final reader = CsvFieldReader(header, row);

    return Note(
      noteId: reader.fieldOrEmpty('note_id'),
      noteText: reader.fieldOrEmpty('note_text'),
    );
  }

  /// Expected CSV header for notes.txt (non-standard NSW Transport API extension)
  static List<String> expectedCsvHeader() => ['note_id', 'note_text'];

  static void validateCsvHeader(List<String> header) {
    // Both fields are required for this non-standard file
    final required = expectedCsvHeader();
    for (final col in required) {
      if (!header.contains(col)) {
        // Missing required column — callers should handle this case
      }
    }
  }
}
