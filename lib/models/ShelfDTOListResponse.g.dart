// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ShelfDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShelfDTOListResponse _$ShelfDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    ShelfDTOListResponse(
      (json['shelfDTOList'] as List<dynamic>)
          .map((e) => ShelfDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ShelfDTOListResponseToJson(
        ShelfDTOListResponse instance) =>
    <String, dynamic>{
      'shelfDTOList': instance.shelfDTOList.map((e) => e.toJson()).toList(),
    };
