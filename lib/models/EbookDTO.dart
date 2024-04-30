import 'package:json_annotation/json_annotation.dart';
part 'EbookDTO.g.dart';
@JsonSerializable(includeIfNull: false)
class EbookDTO {
  int? id;
  String? data;
  String? name;
  String? type;


  EbookDTO(
      this.id,
      this.data,
      this.name,
      this.type
      );


  factory EbookDTO.fromJson(Map<String,dynamic> data) => _$EbookDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$EbookDTOToJson(this);
}
