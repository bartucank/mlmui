// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RoomDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDTO _$RoomDTOFromJson(Map<String, dynamic> json) => RoomDTO(
      json['id'] as int?,
      json['imageId'] as int?,
      json['name'] as String?,
    );

Map<String, dynamic> _$RoomDTOToJson(RoomDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('imageId', instance.imageId);
  writeNotNull('name', instance.name);
  return val;
}
