import 'package:json_annotation/json_annotation.dart';
part 'ShelfDTO.g.dart';
@JsonSerializable()
class ShelfDTO {
  int id;
  String floor;

  ShelfDTO(
      this.id,

      this.floor);


  factory ShelfDTO.fromJson(Map<String,dynamic> data) => _$ShelfDTOFromJson(data);

  Map<String,dynamic> toJson()=>_$ShelfDTOToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ShelfDTO && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
