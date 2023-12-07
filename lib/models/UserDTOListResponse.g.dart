// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserDTOListResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDTOListResponse _$UserDTOListResponseFromJson(Map<String, dynamic> json) =>
    UserDTOListResponse(
      (json['userDTOList'] as List<dynamic>)
          .map((e) => UserDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['totalPage'] as int,
    );

Map<String, dynamic> _$UserDTOListResponseToJson(
        UserDTOListResponse instance) =>
    <String, dynamic>{
      'userDTOList': instance.userDTOList.map((e) => e.toJson()).toList(),
      'totalPage': instance.totalPage,
    };
