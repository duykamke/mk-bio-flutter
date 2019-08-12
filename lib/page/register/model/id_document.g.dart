part of 'id_document.dart';

IDDocumentClass _$IDDocumentClassFromJson(Map<String, dynamic> json) {
  return IDDocumentClass(
    frontImage: json['frontImage'] as String,
    backImage: json['backImage'] as String,
    type: json['type'] as int,
  );
}

Map<String, dynamic> _$IDDocumentClassToJson(IDDocumentClass instance) =>
    <String, dynamic>{
      'frontImage': instance.frontImage,
      'backImage': instance.backImage,
      'type': instance.type,
    };
