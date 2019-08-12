import 'package:json_annotation/json_annotation.dart';

part 'id_document.g.dart';

@JsonSerializable()
class IDDocumentClass {
  final String frontImage;
  final String backImage;
  final int type;
  IDDocumentClass({
    this.frontImage,
    this.backImage,
    this.type,
  });

  factory IDDocumentClass.fromJson(Map<String, dynamic> json) =>
      _$IDDocumentClassFromJson(json);
  Map<String, dynamic> toJson() => _$IDDocumentClassToJson(this);
}