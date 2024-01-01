// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QueueMembersDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueMembersDTO _$QueueMembersDTOFromJson(Map<String, dynamic> json) =>
    QueueMembersDTO(
      UserDTO.fromJson(json['userDTO'] as Map<String, dynamic>),
      json['enterDate'] as String?,
      json['takeDate'] as String?,
      json['returnDate'] as String?,
      json['statusDesc'] as String?,
      json['status'] as String?,
    );

Map<String, dynamic> _$QueueMembersDTOToJson(QueueMembersDTO instance) {
  final val = <String, dynamic>{
    'userDTO': instance.userDTO.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('enterDate', instance.enterDate);
  writeNotNull('takeDate', instance.takeDate);
  writeNotNull('returnDate', instance.returnDate);
  writeNotNull('statusDesc', instance.statusDesc);
  writeNotNull('status', instance.status);
  return val;
}
