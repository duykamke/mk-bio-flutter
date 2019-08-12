part of 'enrollment_form.dart';

EnrollmentForm _$EnrollmentFormFromJson(Map<String, dynamic> json) {
  return EnrollmentForm(
      idCard: json['idCard'] as String,
      birtDate: json['birtDate'] as String,
      gender: json['name'] as String,
      name: json['name'] as String,
      faceImage: json['faceImage'] as String,
      idDocument: json['idDocument'] == null
          ? null
          : IDDocumentClass.fromJson(
              json['idDocument'] as Map<String, dynamic>));
}

Map<String, dynamic> _$EnrollmentFormToJson(EnrollmentForm instance) =>
    <String, dynamic>{
      'idCard': instance.idCard,
      'birtDate': instance.birtDate,
      'gender': instance.gender,
      'name': instance.name,
      'faceImage': instance.faceImage,
      'idDocument': instance.idDocument.toJson(),
    };
