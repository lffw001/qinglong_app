import 'package:json_conversion_annotation/json_conversion_annotation.dart';


@JsonConversion()
class UserBean {
  String? username;
  bool? twoFactorActivated;
  String? avatar;

  UserBean({
    this.username,
    this.twoFactorActivated,
    this.avatar,
  });

  UserBean.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    avatar = json['avatar'];
    twoFactorActivated = json['twoFactorActivated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['username'] = this.username;
    data['avatar'] = this.avatar;
    data['twoFactorActivated'] = this.twoFactorActivated;
    return data;
  }

  static UserBean jsonConversion(Map<String, dynamic> json) {
    return UserBean.fromJson(json);
  }
}
