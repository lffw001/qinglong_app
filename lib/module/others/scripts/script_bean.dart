import 'package:json_conversion_annotation/json_conversion_annotation.dart';


@JsonConversion()
class ScriptBean {
  String? title;
  String? value;
  bool? disabled;
  List<ScriptChildren>? children;

  ScriptBean({this.title, this.value, this.disabled, this.children});

  ScriptBean.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    disabled = json['disabled'];
    if (json['children'] != null) {
      children = <ScriptChildren>[];
      json['children'].forEach((v) {
        children!.add(new ScriptChildren.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['disabled'] = this.disabled;
    if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static ScriptBean jsonConversion(Map<String, dynamic> json) {
    return ScriptBean.fromJson(json);
  }
}

class ScriptChildren {
  String? title;
  String? value;
  String? parent;

  ScriptChildren({this.title, this.value, this.parent});

  ScriptChildren.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
    parent = json['parent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['value'] = this.value;
    data['parent'] = this.parent;
    return data;
  }
}
