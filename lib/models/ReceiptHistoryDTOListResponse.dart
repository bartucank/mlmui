import 'package:json_annotation/json_annotation.dart';
import 'ReceiptHistoryDTO.dart';
import 'UserDTO.dart';
part 'ReceiptHistoryDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true,includeIfNull: false)
class ReceiptHistoryDTOListResponse {
  List<ReceiptHistoryDTO> receiptHistoryDTOList;
  int totalPage;
  int totalResult;

  ReceiptHistoryDTOListResponse(this.receiptHistoryDTOList,this.totalPage,this.totalResult);

  factory ReceiptHistoryDTOListResponse.fromJson(Map<String,dynamic> data) => _$ReceiptHistoryDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$ReceiptHistoryDTOListResponseToJson(this);
}
