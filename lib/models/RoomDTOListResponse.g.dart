// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RoomDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomDTOListResponse _$RoomDTOListResponseFromJson(Map<String, dynamic> json) =>
    RoomDTOListResponse(
      (json['roomDTOList'] as List<dynamic>)
          .map((e) => RoomDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoomDTOListResponseToJson(
        RoomDTOListResponse instance) =>
    <String, dynamic>{
      'roomDTOList': instance.roomDTOList.map((e) => e.toJson()).toList(),
    };
