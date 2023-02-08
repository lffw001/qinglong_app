import 'package:json_conversion_annotation/json_conversion_annotation.dart';

@JsonConversion()
class LoginBean {
  String? token;
  String? lastip;
  String? lastaddr;
  int? lastlogon;
  int? retries;
  String? platform;

  LoginBean(
      {this.token,
      this.lastip,
      this.lastaddr,
      this.lastlogon,
      this.retries,
      this.platform});

  LoginBean.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    lastip = json['lastip'];
    lastaddr = json['lastaddr'];
    lastlogon = int.tryParse(json['lastlogon'].toString());
    retries = json['retries'];
    platform = json['platform'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['lastip'] = this.lastip;
    data['lastaddr'] = this.lastaddr;
    data['lastlogon'] = this.lastlogon;
    data['retries'] = this.retries;
    data['platform'] = this.platform;
    return data;
  }

  static LoginBean jsonConversion(Map<String, dynamic> json) {
    return LoginBean.fromJson(json);
  }
}
