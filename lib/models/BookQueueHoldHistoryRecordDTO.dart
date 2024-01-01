import 'package:json_annotation/json_annotation.dart';

import 'CopyCardDTO.dart';
import 'UserDTO.dart';
part 'BookQueueHoldHistoryRecordDTO.g.dart';
@JsonSerializable(explicitToJson: true,includeIfNull: false)
class BookQueueHoldHistoryRecordDTO {
  int? userId;
  String? endDate;


  BookQueueHoldHistoryRecordDTO(this.userId, this.endDate);

  factory BookQueueHoldHistoryRecordDTO.fromJson(Map<String,dynamic> data) => _$BookQueueHoldHistoryRecordDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$BookQueueHoldHistoryRecordDTOToJson(this);
}
