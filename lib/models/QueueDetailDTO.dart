import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'BookQueueHoldHistoryRecordDTO.dart';
import 'QueueMembersDTO.dart';
import 'UserDTO.dart';
import 'UserNamesDTO.dart';
part 'QueueDetailDTO.g.dart';
@JsonSerializable(explicitToJson: true,includeIfNull: false)
class QueueDetailDTO {
  BookDTO bookDTO;
  List<QueueMembersDTO>? members;
  String? status;
  String? statusDesc;
  bool? holdFlag;
  BookQueueHoldHistoryRecordDTO? holdDTO;
  String? startDate;


  QueueDetailDTO(this.bookDTO, this.members, this.status, this.statusDesc,
      this.holdFlag, this.holdDTO, this.startDate);

  factory QueueDetailDTO.fromJson(Map<String,dynamic> data) => _$QueueDetailDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$QueueDetailDTOToJson(this);
}
