// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserNamesDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNamesDTOListResponse _$UserNamesDTOListResponseFromJson(
        Map<String, dynamic> json) =>
    UserNamesDTOListResponse(
      (json['dtoList'] as List<dynamic>)
          .map((e) => UserNamesDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserNamesDTOListResponseToJson(
        UserNamesDTOListResponse instance) =>
    <String, dynamic>{
      'dtoList': instance.dtoList.map((e) => e.toJson()).toList(),
    };
