import 'package:json_conversion_annotation/json_conversion_annotation.dart';


@JsonConversion()
class DependencyBean {
  String? sId;
  String? mustId;
  int? id;
  int? created;
  String? createdAt;
  int? status;
  int? type;
  String? timestamp;
  String? name;
  List<String>? log;
  String? remark;

  DependencyBean(
      {this.sId,
      this.created,
      this.status,
      this.type,
      this.timestamp,
      this.name,
      this.log,
      this.remark});

  DependencyBean.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    id = json['id'];
    mustId = sId ?? (id?.toString() ?? "");
    created = int.tryParse(json['created'].toString());
    createdAt = json['createdAt'];
    status = json['status'];
    type = json['type'];
    timestamp = json['timestamp'].toString();
    name = json['name'];
    log = json['log'].cast<String>();
    remark = json['remark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['created'] = this.created;
    data['status'] = this.status;
    data['type'] = this.type;
    data['timestamp'] = this.timestamp;
    data['name'] = this.name;
    data['log'] = this.log;
    data['remark'] = this.remark;
    return data;
  }

  static DependencyBean jsonConversion(Map<String, dynamic> json) {
    return DependencyBean.fromJson(json);
  }
}
