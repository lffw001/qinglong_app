import 'package:json_conversion_annotation/json_conversion_annotation.dart';

@JsonConversion()
class ConfigBean {
  String? title;
  String? value;

  ConfigBean({this.title, this.value});

  ConfigBean.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    return data;
  }

  static ConfigBean jsonConversion(Map<String, dynamic> json) {
    return ConfigBean.fromJson(json);
  }
}
