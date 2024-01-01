import 'package:json_annotation/json_annotation.dart';

import 'CopyCardDTO.dart';
import 'UserDTO.dart';
part 'QueueMembersDTO.g.dart';
@JsonSerializable(explicitToJson: true,includeIfNull: false)
class QueueMembersDTO {
  UserDTO userDTO;
  String? enterDate;
  String? takeDate;
  String? returnDate;
  String? statusDesc;
  String? status;


  QueueMembersDTO(this.userDTO, this.enterDate, this.takeDate, this.returnDate,
      this.statusDesc, this.status);

  factory QueueMembersDTO.fromJson(Map<String,dynamic> data) => _$QueueMembersDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$QueueMembersDTOToJson(this);
}
