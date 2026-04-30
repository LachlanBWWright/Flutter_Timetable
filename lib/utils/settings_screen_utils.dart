import 'package:flutter/material.dart';

String apiKeyUsageText({
  required bool hasUserApiKey,
  required bool hasBuiltInApiKey,
}) {
  if (hasUserApiKey) {
    return 'Using your custom API key.';
  }
  if (hasBuiltInApiKey) {
    return 'Using the built-in API key.';
  }
  return 'No API key configured.';
}

Color apiKeyUsageColor({
  required bool hasUserApiKey,
  required bool hasBuiltInApiKey,
}) {
  if (hasUserApiKey) {
    return Colors.green;
  }
  if (hasBuiltInApiKey) {
    return Colors.grey;
  }
  return Colors.orange;
}

bool isPositiveApiKeyStatus(String status) {
  final lower = status.toLowerCase();
  return lower.contains('success') ||
      lower.contains('saved') ||
      lower.contains('removed');
}

String formatUpdateSummary({
  required int stopsUpdated,
  required int realtimeFeedsUpdated,
}) {
  return 'Stops updated: $stopsUpdated • Realtime feeds updated: $realtimeFeedsUpdated';
}
