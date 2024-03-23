// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RoomSlotDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomSlotDTO _$RoomSlotDTOFromJson(Map<String, dynamic> json) => RoomSlotDTO(
      json['id'] as int?,
      json['startHour'] as String?,
      json['endHour'] as String?,
      json['day'] as String?,
      json['available'] as bool?,
      json['dayInt'] as int?,
    );

Map<String, dynamic> _$RoomSlotDTOToJson(RoomSlotDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('startHour', instance.startHour);
  writeNotNull('endHour', instance.endHour);
  writeNotNull('day', instance.day);
  writeNotNull('available', instance.available);
  writeNotNull('dayInt', instance.dayInt);
  return val;
}
