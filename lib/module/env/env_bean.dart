import 'package:json_conversion_annotation/json_conversion_annotation.dart';

@JsonConversion()
class EnvBean {
  String? name;
  String? value;
  String? remarks;
  int? status;
  String? sId;
  String? _id;
  int? id;
  int? created;
  String? timestamp;
  String? updatedAt;
  String? createdAt;

  EnvBean(
      {this.value,
      this.sId,
      this.created,
      this.status,
      this.timestamp,
      this.name,
      this.remarks});

  get nId => _id;

  EnvBean.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
    remarks = json['remarks'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    status = json['status'];
    id = json['id'];
    _id = json['_id'];
    sId = json.containsKey('_id')
        ? json['_id'].toString()
        : (json.containsKey('id') ? json['id'].toString() : "");
    created = int.tryParse(json['created'].toString());
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['value'] = this.value;
    data['remarks'] = this.remarks;
    data['status'] = this.status;
    data['_id'] = this._id;
    data['id'] = this.id;
    data['created'] = this.created;
    data['timestamp'] = this.timestamp;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }

  static EnvBean jsonConversion(Map<String, dynamic> json) {
    return EnvBean.fromJson(json);
  }
}
