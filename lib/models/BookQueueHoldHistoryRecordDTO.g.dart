// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BookQueueHoldHistoryRecordDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookQueueHoldHistoryRecordDTO _$BookQueueHoldHistoryRecordDTOFromJson(
        Map<String, dynamic> json) =>
    BookQueueHoldHistoryRecordDTO(
      json['userId'] as int?,
      json['endDate'] as String?,
    );

Map<String, dynamic> _$BookQueueHoldHistoryRecordDTOToJson(
    BookQueueHoldHistoryRecordDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('endDate', instance.endDate);
  return val;
}
