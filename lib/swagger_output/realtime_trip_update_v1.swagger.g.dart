// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_trip_update_v1.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetails _$ErrorDetailsFromJson(Map<String, dynamic> json) => ErrorDetails(
      errorDateTime: json['ErrorDateTime'] as String,
      message: json['Message'] as String,
      requestedMethod: json['RequestedMethod'] as String,
      requestedUrl: json['RequestedUrl'] as String,
      transactionId: json['TransactionId'] as String,
    );

Map<String, dynamic> _$ErrorDetailsToJson(ErrorDetails instance) =>
    <String, dynamic>{
      'ErrorDateTime': instance.errorDateTime,
      'Message': instance.message,
      'RequestedMethod': instance.requestedMethod,
      'RequestedUrl': instance.requestedUrl,
      'TransactionId': instance.transactionId,
    };
