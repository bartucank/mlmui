import 'package:json_annotation/json_annotation.dart';
import 'package:mlmui/models/BookDTO.dart';
import 'ReceiptHistoryDTO.dart';
import 'UserDTO.dart';
part 'ReceiptHistoryDTOListResponse.g.dart';
@JsonSerializable(explicitToJson: true,includeIfNull: false)
class ReceiptHistoryDTOListResponse {
  List<ReceiptHistoryDTO> receiptHistoryDTOList;


  ReceiptHistoryDTOListResponse(this.receiptHistoryDTOList);

  factory ReceiptHistoryDTOListResponse.fromJson(Map<String,dynamic> data) => _$ReceiptHistoryDTOListResponseFromJson(data);

  Map<String,dynamic> toJson()=>_$ReceiptHistoryDTOListResponseToJson(this);
}
