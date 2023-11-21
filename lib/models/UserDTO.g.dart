// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDTO _$UserDTOFromJson(Map<String, dynamic> json) => UserDTO(
      json['role'] as String,
      json['roleStr'] as String,
      json['fullName'] as String,
      json['username'] as String,
      json['verified'] as bool,
      json['email'] as String,
    );

Map<String, dynamic> _$UserDTOToJson(UserDTO instance) => <String, dynamic>{
      'role': instance.role,
      'roleStr': instance.roleStr,
      'fullName': instance.fullName,
      'username': instance.username,
      'verified': instance.verified,
      'email': instance.email,
    };
