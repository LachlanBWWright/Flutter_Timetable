part of '../transport_api_service_impl.dart';

class SystemMessages {
  final List<ResponseMessage> responseMessages;

  const SystemMessages({this.responseMessages = const []});

  factory SystemMessages.fromJson(Object json) {
    // If json is a List, treat it as the list of messages directly
    if (json is List) {
      return SystemMessages(
        responseMessages: json
            .whereType<Map<String, dynamic>>()
            .map(ResponseMessage.fromJson)
            .whereType<ResponseMessage>()
            .toList(),
      );
    }
    if (json is Map<String, dynamic>) {
      if (json.containsKey('responseMessages')) {
        final responseMessagesRaw = tryReadListValue(json, 'responseMessages');
        return SystemMessages(
          responseMessages: _parseJsonList(
            responseMessagesRaw,
            ResponseMessage.fromJson,
          ),
        );
      } else {
        return SystemMessages(
          responseMessages: [ResponseMessage.fromJson(json)],
        );
      }
    }
    return const SystemMessages(responseMessages: []);
  }
}

class ResponseMessage {
  final int? code;
  final String? error;
  final String? module;
  final String? type;
  // Some API responses include 'text' and 'subType' instead of 'error'/'type'.
  // Keep these fields to preserve the raw values and provide backward-compatible
  // fallback when 'error' or 'type' are missing.
  final String? text;
  final String? subType;

  ResponseMessage({
    this.code,
    this.error,
    this.module,
    this.type,
    this.text,
    this.subType,
  });

  factory ResponseMessage.fromJson(Map<String, dynamic> json) {
    final rawText = tryReadStringValue(json, 'text');
    final rawError = tryReadStringValue(json, 'error');
    return ResponseMessage(
      code: tryParseIntValue(tryReadMapValue(json, 'code')),
      error: _firstNonNull(rawError, rawText),
      module: tryReadStringValue(json, 'module'),
      type: tryReadStringValue(json, 'type'),
      text: rawText,
      subType: tryReadStringValue(json, 'subType'),
    );
  }
}
