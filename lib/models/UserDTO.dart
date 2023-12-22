import 'package:json_annotation/json_annotation.dart';

import 'CopyCardDTO.dart';
part 'UserDTO.g.dart';
@JsonSerializable(explicitToJson: true)
class UserDTO {
  String role;
  String roleStr;
  String fullName;
  String username;

  bool verified;
  String email;
  double? debt;
  CopyCardDTO? copyCardDTO;


  UserDTO(this.role, this.roleStr, this.fullName, this.username,
      this.verified, this.email);

  factory UserDTO.fromJson(Map<String,dynamic> data) => _$UserDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$UserDTOToJson(this);
}
