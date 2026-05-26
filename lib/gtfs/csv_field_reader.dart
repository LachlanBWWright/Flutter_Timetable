class CsvFieldReader {
  const CsvFieldReader(this.header, this.row);

  final List<String> header;
  final List<String> row;

  String? fieldOrNull(String fieldName) {
    try {
      final index = header.indexOf(fieldName);
      if (index < 0) {
        return null;
      }

      final value = row.skip(index).firstOrNull;
      if (value == null || value.isEmpty) {
        return null;
      }
      return value;
    } catch (_) {
      return null;
    }
  }

  String fieldOrEmpty(String fieldName) {
    return fieldOrNull(fieldName) ?? '';
  }

  double doubleField(String fieldName, {double defaultValue = 0.0}) {
    final value = fieldOrNull(fieldName);
    if (value == null) {
      return defaultValue;
    }
    return double.tryParse(value) ?? defaultValue;
  }

  int intField(String fieldName, {int defaultValue = 0}) {
    final value = fieldOrNull(fieldName);
    if (value == null) {
      return defaultValue;
    }
    return int.tryParse(value) ?? defaultValue;
  }
}
