import 'dart:convert';

import '../constants/transport_modes.dart';
import 'app_preferences.dart';

class HomeStop {
  const HomeStop({required this.name, required this.id, required this.mode});

  final String name;
  final String id;
  final TransportMode mode;

  Map<String, String> toJson() => {'name': name, 'id': id, 'mode': mode.id};

  static HomeStop? fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final id = json['id'];
    final mode = TransportMode.values
        .where((value) => value.id == json['mode'])
        .firstOrNull;
    if (name is! String ||
        name.isEmpty ||
        id is! String ||
        id.isEmpty ||
        mode == null) {
      return null;
    }
    return HomeStop(name: name, id: id, mode: mode);
  }
}

/// Stores a complete selection with one preference write.
class HomeStopService {
  const HomeStopService({this.readString, this.writeString, this.containsKey});

  static const preferenceKey = 'home_stop';
  final Future<String?> Function(String key)? readString;
  final Future<void> Function(String key, String value)? writeString;
  final Future<bool?> Function(String key)? containsKey;

  Future<HomeStop?> load() async {
    final read = readString ?? AppPreferences.getStringOrThrow;
    final encoded = await read(preferenceKey);
    if (encoded != null) {
      try {
        final json = jsonDecode(encoded);
        if (json is Map<String, dynamic>) return HomeStop.fromJson(json);
      } on FormatException {
        return null;
      }
      return null;
    }
    if (readString == null) {
      if (await AppPreferences.containsKeyOrThrow(preferenceKey)) return null;
    } else {
      final hasKey = containsKey;
      if (hasKey != null && await hasKey(preferenceKey) != false) return null;
    }
    // Legacy selections remain readable until a successful replacement save.
    return HomeStop.fromJson({
      'name': await read('home_stop_name'),
      'id': await read('home_stop_id'),
      'mode': await read('home_stop_mode'),
    });
  }

  Future<void> save(HomeStop stop) async {
    if (HomeStop.fromJson(stop.toJson()) == null) {
      throw ArgumentError('A home stop must have a name, ID, and mode.');
    }
    final write = writeString ?? AppPreferences.setStringOrThrow;
    await write(preferenceKey, jsonEncode(stop.toJson()));
  }
}
