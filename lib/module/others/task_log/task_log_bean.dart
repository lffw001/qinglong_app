import 'package:json_conversion_annotation/json_conversion_annotation.dart';


@JsonConversion()
class TaskLogBean {
  String? name;
  bool? isDir;
  List<String>? files;
  List<Children>? children;

  TaskLogBean({this.name, this.files});

  TaskLogBean.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? json['title'];
    isDir = json['isDir'] ?? (json['type'] == "directory");

    files = json['files']?.cast<String>();
    if (json['children'] != null) {
      children = <Children>[];
      json['children'].forEach((v) {
        children!.add(Children.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['files'] = this.files;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static TaskLogBean jsonConversion(Map<String, dynamic> json) {
    return TaskLogBean.fromJson(json);
  }
}

class Children {
  String? title;
  String? value;
  String? type;
  String? key;
  String? parent;

  Children({this.title, this.value, this.type, this.key, this.parent});

  Children.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    type = json['type'];
    key = json['key'];
    parent = json['parent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['type'] = this.type;
    data['key'] = this.key;
    data['parent'] = this.parent;
    return data;
  }
}
