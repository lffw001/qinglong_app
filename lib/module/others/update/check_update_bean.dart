import 'package:json_conversion_annotation/json_conversion_annotation.dart';



@JsonConversion()
class CheckUpdateBean {
  bool? hasNewVersion;
  String? lastVersion;
  String? lastLog;

  CheckUpdateBean({this.hasNewVersion, this.lastVersion, this.lastLog});

  CheckUpdateBean.fromJson(Map<String, dynamic> json) {
    hasNewVersion = json['hasNewVersion'];
    lastVersion = json['lastVersion'];
    lastLog = json['lastLog'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hasNewVersion'] = this.hasNewVersion;
    data['lastVersion'] = this.lastVersion;
    data['lastLog'] = this.lastLog;
    return data;
  }

  static CheckUpdateBean jsonConversion(Map<String, dynamic> json) {
    return CheckUpdateBean.fromJson(json);
  }
}
