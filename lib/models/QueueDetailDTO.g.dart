// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QueueDetailDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueDetailDTO _$QueueDetailDTOFromJson(Map<String, dynamic> json) =>
    QueueDetailDTO(
      BookDTO.fromJson(json['bookDTO'] as Map<String, dynamic>),
      (json['members'] as List<dynamic>?)
          ?.map((e) => QueueMembersDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['status'] as String?,
      json['statusDesc'] as String?,
      json['holdFlag'] as bool?,
      json['holdDTO'] == null
          ? null
          : BookQueueHoldHistoryRecordDTO.fromJson(
              json['holdDTO'] as Map<String, dynamic>),
      json['startDate'] as String?,
    );

Map<String, dynamic> _$QueueDetailDTOToJson(QueueDetailDTO instance) {
  final val = <String, dynamic>{
    'bookDTO': instance.bookDTO.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('members', instance.members?.map((e) => e.toJson()).toList());
  writeNotNull('status', instance.status);
  writeNotNull('statusDesc', instance.statusDesc);
  writeNotNull('holdFlag', instance.holdFlag);
  writeNotNull('holdDTO', instance.holdDTO?.toJson());
  writeNotNull('startDate', instance.startDate);
  return val;
}
