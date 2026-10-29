import 'dart:io';

const _sourcePath = 'lib/nsw/swaggers/trip_planner.yaml';
const _outputPath = 'lib/nsw/swaggers/generated/trip_planner.yaml';

void main() {
  final source = File(_sourcePath).readAsStringSync();
  var normalized = source;

  const systemMessagesOriginal = '''            systemMessages:
                description: Includes system messages that may be relevant to this
                    particular request.
                properties:
                    responseMessages:
                        description: Contains zero or more messages.
                        items:
                            \$ref: '#/definitions/TripRequestResponseMessage'
                        type: array
                type: object''';
  const systemMessagesNormalized = '''            systemMessages:
                description: Includes system messages that may be relevant to this
                    particular request.
                items:
                    \$ref: '#/definitions/TripRequestResponseMessage'
                type: array''';

  const vehicleAccessOriginal = '''                    vehicleAccess:
                        description: This value is not currently in use.
                        items:
                            type: string
                        type: array''';
  const vehicleAccessNormalized = '''                    vehicleAccess:
                        description: This value is not currently in use.
                        items:
                            type: object
                        type: array''';

  const distanceOriginal = '''                    distance:
                        description: This is the distance in metres to this location
                            from the search location.
                        type: string''';
  const distanceNormalized = '''                    distance:
                        description: This is the distance in metres to this location
                            from the search location.
                        type: number''';

  final footpathAreaType = RegExp(
    r'(            area:\n                description: This is an internal value used to group stops together\.\n                type:) integer',
  );
  final footpathPlatformType = RegExp(
    r"(            platform:\n                description: 'If available, this is a platform number[\s\S]*?\n                type:) integer",
  );

  if (source.split(systemMessagesOriginal).length != 2) {
    throw StateError('Unexpected systemMessages shape in $_sourcePath');
  }
  if (source.split(vehicleAccessOriginal).length != 2) {
    throw StateError('Unexpected vehicleAccess shape in $_sourcePath');
  }
  if (source.split(distanceOriginal).length != 2) {
    throw StateError('Unexpected coordinate distance shape in $_sourcePath');
  }
  if (footpathAreaType.allMatches(source).length != 1) {
    throw StateError('Unexpected footpath area shape in $_sourcePath');
  }
  if (footpathPlatformType.allMatches(source).length != 1) {
    throw StateError('Unexpected footpath platform shape in $_sourcePath');
  }

  normalized = normalized.replaceFirst(
    systemMessagesOriginal,
    systemMessagesNormalized,
  );
  normalized = normalized.replaceFirst(
    vehicleAccessOriginal,
    vehicleAccessNormalized,
  );
  normalized = normalized.replaceFirst(distanceOriginal, distanceNormalized);
  normalized = normalized.replaceFirstMapped(
    footpathAreaType,
    (match) => '${match.group(1)} string',
  );
  normalized = normalized.replaceFirstMapped(
    footpathPlatformType,
    (match) => '${match.group(1)} string',
  );

  final output = File(_outputPath)..createSync(recursive: true);
  output.writeAsStringSync(normalized);
  stdout.writeln('Wrote $_outputPath');
}
