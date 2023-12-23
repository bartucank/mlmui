import 'package:json_annotation/json_annotation.dart';
part 'ReceiptHistoryDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class ReceiptHistoryDTO {
  int? id;
  int? userId;
  int? imgId;
  bool? approved;
  double? balance;


  ReceiptHistoryDTO(
      this.id, this.userId, this.imgId, this.approved, this.balance);



  factory ReceiptHistoryDTO.fromJson(Map<String,dynamic> data) => _$ReceiptHistoryDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$ReceiptHistoryDTOToJson(this);
}
