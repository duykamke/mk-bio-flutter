import 'package:json_annotation/json_annotation.dart';
import './id_document.dart';
part 'enrollment_form.g.dart';

@JsonSerializable()
class EnrollmentForm {
  final String idCard;
  final String birthDate;
  final String gender;
  final String name;
  final String faceImage;
  final IDDocumentClass idDocument;
  EnrollmentForm(
      {this.idCard,
      this.birthDate,
      this.gender,
      this.name,
      this.faceImage,
      this.idDocument});

  factory EnrollmentForm.fromJson(Map<String, dynamic> json) =>
      _$EnrollmentFormFromJson(json);
  Map<String, dynamic> toJson() => _$EnrollmentFormToJson(this);
}
