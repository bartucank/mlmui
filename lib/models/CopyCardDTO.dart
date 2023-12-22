import 'package:json_annotation/json_annotation.dart';
part 'CopyCardDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class CopyCardDTO {
  double balance;
  String nfcCode;

  CopyCardDTO(this.balance, this.nfcCode);


  factory CopyCardDTO.fromJson(Map<String,dynamic> data) => _$CopyCardDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$CopyCardDTOToJson(this);
}
