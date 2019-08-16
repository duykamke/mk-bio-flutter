import 'package:json_annotation/json_annotation.dart';
part 'user_info.g.dart';

@JsonSerializable()
class UserInfo {
  final String subjectId;
  final String birthDate;
  final String gender;
  final String name;
  final String image;
  final double fap;
  UserInfo(
      {this.subjectId,
      this.birthDate,
      this.gender,
      this.name,
      this.image,
      this.fap,
      });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}
