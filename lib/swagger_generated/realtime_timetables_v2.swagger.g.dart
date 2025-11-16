// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_timetables_v2.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDetails _$ErrorDetailsFromJson(Map<String, dynamic> json) => ErrorDetails(
      transactionId: json['TransactionId'] as String,
      errorDateTime: json['ErrorDateTime'] as String,
      message: json['Message'] as String,
      requestedUrl: json['RequestedUrl'] as String,
      requestedMethod: json['RequestedMethod'] as String,
    );

Map<String, dynamic> _$ErrorDetailsToJson(ErrorDetails instance) =>
    <String, dynamic>{
      'TransactionId': instance.transactionId,
      'ErrorDateTime': instance.errorDateTime,
      'Message': instance.message,
      'RequestedUrl': instance.requestedUrl,
      'RequestedMethod': instance.requestedMethod,
    };
