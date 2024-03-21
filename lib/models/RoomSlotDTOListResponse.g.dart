// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RoomSlotDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomSlotDTOListResponse _$RoomSlotDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    RoomSlotDTOListResponse(
      (json['roomSlotDTOList'] as List<dynamic>)
          .map((e) => RoomSlotDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoomSlotDTOListResponseToJson(
        RoomSlotDTOListResponse instance) =>
    <String, dynamic>{
      'roomSlotDTOList':
          instance.roomSlotDTOList.map((e) => e.toJson()).toList(),
    };
