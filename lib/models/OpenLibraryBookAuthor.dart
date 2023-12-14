import 'package:json_annotation/json_annotation.dart';
part 'OpenLibraryBookAuthor.g.dart';
@JsonSerializable(includeIfNull: false)
class OpenLibraryBookAuthor {
  String? key;
  OpenLibraryBookAuthor(this.key);

  factory OpenLibraryBookAuthor.fromJson(Map<String,dynamic> data) => _$OpenLibraryBookAuthorFromJson(data);

  Map<String,dynamic> toJson()=>_$OpenLibraryBookAuthorToJson(this);
}

