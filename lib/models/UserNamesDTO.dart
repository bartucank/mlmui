import 'package:json_annotation/json_annotation.dart';

import 'CopyCardDTO.dart';
part 'UserNamesDTO.g.dart';
@JsonSerializable(explicitToJson: true)
class UserNamesDTO {
  String? displayName;
  int? id;


  UserNamesDTO(this.displayName, this.id);

  factory UserNamesDTO.fromJson(Map<String,dynamic> data) => _$UserNamesDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$UserNamesDTOToJson(this);
}
