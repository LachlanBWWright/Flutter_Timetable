part of '../transport_api_service_impl.dart';

class Hint {
  final String? infoText;

  Hint({this.infoText});

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(infoText: tryReadStringValue(json, 'infoText'));
  }
}

class Info {
  final String? content;
  final String? id;
  final String? priority;
  final String? subtitle;
  final Timestamps? timestamps;
  final String? url;
  final String? urlText;
  // version is expected to be an integer (API often returns numeric versions).
  // Keep it as `int?` and coerce safely from string when necessary.
  final int? version;

  Info({
    this.content,
    this.id,
    this.priority,
    this.subtitle,
    this.timestamps,
    this.url,
    this.urlText,
    this.version,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    final timestampsJson = tryReadJsonMap(json, 'timestamps');
    Timestamps? timestamps;
    if (timestampsJson != null) {
      timestamps = Timestamps.fromJson(timestampsJson);
    }
    return Info(
      content: tryReadStringValue(json, 'content'),
      id: tryReadStringValue(json, 'id'),
      priority: tryReadStringValue(json, 'priority'),
      subtitle: tryReadStringValue(json, 'subtitle'),
      timestamps: timestamps,
      url: tryReadStringValue(json, 'url'),
      urlText: tryReadStringValue(json, 'urlText'),
      version: _parseInfoVersion(tryReadMapValue(json, 'version')),
    );
  }
}

int? _parseInfoVersion(Object? rawVersion) {
  if (rawVersion == null) {
    return null;
  }
  if (rawVersion is int) {
    return rawVersion;
  }
  if (rawVersion is String) {
    final parsed = int.tryParse(rawVersion);
    if (parsed == null) {
      logger.w(
        'Info.fromJson: could not parse version string to int: "$rawVersion"',
      );
    }
    return parsed;
  }
  logger.w(
    'Info.fromJson: unexpected type for version: ${rawVersion.runtimeType}',
  );
  return null;
}

class Timestamps {
  final Validity? availability;
  final String? creation;
  final String? lastModification;
  final List<Validity>? validity;

  Timestamps({
    this.availability,
    this.creation,
    this.lastModification,
    this.validity,
  });

  factory Timestamps.fromJson(Map<String, dynamic> json) {
    final validityRaw = tryReadListValue(json, 'validity');
    final availabilityJson = tryReadJsonMap(json, 'availability');
    Validity? availability;
    if (availabilityJson != null) {
      availability = Validity.fromJson(availabilityJson);
    }
    return Timestamps(
      availability: availability,
      creation: tryReadStringValue(json, 'creation'),
      lastModification: tryReadStringValue(json, 'lastModification'),
      validity: _parseJsonList(validityRaw, Validity.fromJson),
    );
  }
}

class Validity {
  final String? from;
  final String? to;

  Validity({this.from, this.to});

  factory Validity.fromJson(Map<String, dynamic> json) {
    return Validity(
      from: tryReadStringValue(json, 'from'),
      to: tryReadStringValue(json, 'to'),
    );
  }
}
