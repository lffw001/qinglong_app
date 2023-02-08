import 'package:json_conversion_annotation/json_conversion_annotation.dart';
import 'package:qinglong_app/module/task/task_bean.dart';

import '../../main.dart';

@JsonConversion()
class TaskBean2 {
  List<TaskBean>? data;

  TaskBean2({this.data});

  TaskBean2.fromJson(Map<String, dynamic> json) {
    try {
      if (json['data'] != null) {
        data = <TaskBean>[];
        json['data'].forEach((v) {
          data!.add(TaskBean.fromJson(v));
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  static TaskBean2 jsonConversion(Map<String, dynamic> json) {
    return TaskBean2.fromJson(json);
  }
}
