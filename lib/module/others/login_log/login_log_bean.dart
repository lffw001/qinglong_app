import 'package:json_conversion_annotation/json_conversion_annotation.dart';


@JsonConversion()
class LoginLogBean {
  int? timestamp;
  String? address;
  String? ip;
  String? platform;
  int? status; //0代表成功,1代表失败

  LoginLogBean(
      {this.timestamp, this.address, this.ip, this.platform, this.status});

  LoginLogBean.fromJson(Map<String, dynamic> json) {
    timestamp = int.tryParse(json['timestamp'].toString());
    address = json['address'];
    ip = json['ip'];
    platform = json['platform'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp'] = this.timestamp;
    data['address'] = this.address;
    data['ip'] = this.ip;
    data['platform'] = this.platform;
    data['status'] = this.status;
    return data;
  }

  static LoginLogBean jsonConversion(Map<String, dynamic> json) {
    return LoginLogBean.fromJson(json);
  }
}
