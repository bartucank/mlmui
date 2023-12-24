import 'package:json_annotation/json_annotation.dart';
import 'UserDTO.dart';
import 'UserNamesDTO.dart';
part 'UserNamesDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true)
class UserNamesDTOListResponse {
  List<UserNamesDTO> dtoList;


  UserNamesDTOListResponse(this.dtoList);

  factory UserNamesDTOListResponse.fromJson(Map<String,dynamic> data) => _$UserNamesDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$UserNamesDTOListResponseToJson(this);
}
