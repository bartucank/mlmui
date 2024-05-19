// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ShelfDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShelfDTO _$ShelfDTOFromJson(Map<String, dynamic> json) => ShelfDTO(
      json['id'] as int,
      json['floor'] as String,
      json['bookCount'] as int?,
    );

Map<String, dynamic> _$ShelfDTOToJson(ShelfDTO instance) => <String, dynamic>{
      'id': instance.id,
      'floor': instance.floor,
      'bookCount': instance.bookCount,
    };
