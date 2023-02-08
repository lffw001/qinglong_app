import 'package:json_conversion_annotation/json_conversion_annotation.dart';



@JsonConversion()
class LogDelBean {
  int? id;
  String? type;
  Info? info;
  String? createdAt;
  String? updatedAt;
  int? frequency;

  LogDelBean({
    this.id,
    this.type,
    this.info,
    this.createdAt,
    this.updatedAt,
    this.frequency,
  });

  LogDelBean.fromJson(Map<String, dynamic> json) {
    frequency = json['frequency'];
    id = json['id'];
    type = json['type'];
    info = json['info'] != null ? new Info.fromJson(json['info']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['frequency'] = this.frequency;
    data['id'] = this.id;

    data['type'] = this.type;
    if (this.info != null) {
      data['info'] = this.info!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }

  static LogDelBean jsonConversion(Map<String, dynamic> json) {
    return LogDelBean.fromJson(json);
  }
}

class Data {}

class Info {
  int? frequency;

  Info({this.frequency});

  Info.fromJson(Map<String, dynamic> json) {
    frequency = json['frequency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['frequency'] = this.frequency;
    return data;
  }
}
