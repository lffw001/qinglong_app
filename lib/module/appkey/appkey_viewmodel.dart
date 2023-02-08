import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';

class AppKeyViewModel extends BaseViewModel {
  List<Map<String, dynamic>> list = [];

  @override
  void retry(BuildContext context, {bool showLoading = true}) {
    loadData(context, showLoading);
  }

  Future<void> loadData(BuildContext context, [isLoading = true]) async {
    if (isLoading && list.isEmpty) {
      loading(notify: true);
    }

    HttpResponse<String> result =
        await SingleAccountPageState.ofApi(context).appKeys();

    if (result.success && result.bean != null) {
      list.clear();

      List<dynamic>? tempList = jsonDecode(result.bean ?? "[]");

      if (tempList != null && tempList.isNotEmpty) {
        for (int i = 0; i < tempList.length; i++) {
          list.add(tempList[i] as Map<String, dynamic>);
        }
        success();
      } else {
        empty(notify: true);
      }
    } else {
      list.clear();
      if (result.code == 404) {
        failed(result.message, notify: true);
      } else {
        failed(result.message, notify: true);
      }
    }
  }

  Future<void> delAppKey(BuildContext context, dynamic id) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).deleteAppKey([id]);
    if (result.success) {
      "删除成功".toast();
      loadData(context, false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  Future<void> resetAppKey(BuildContext context, dynamic id) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).resetAppKey(id);
    if (result.success) {
      "重置成功".toast();
      loadData(context, false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  static List<String> getScopeNames(List<dynamic>? scopeKeys) {
    //"crons","envs","configs","scripts","logs","dependencies","system"
    //配置文件脚本管理环境变量任务日志
    Map<String, String> keyMaps = {
      "crons": "定时任务",
      "envs": "环境变量",
      "configs": "配置文件",
      "scripts": "脚本管理",
      "logs": "任务日志",
      "dependencies": "依赖管理",
      "system": "系统信息",
    };

    List<String> result = [];

    if (scopeKeys == null) return [];
    result.addAll(scopeKeys.map((e) => keyMaps[e.toString()] ?? "").toList());

    return result;
  }

  static List<String> getScopeKeys(List<String> scopeNames) {
    //"crons","envs","configs","scripts","logs","dependencies","system"
    //配置文件脚本管理环境变量任务日志
    Map<String, String> keyMaps = {
      "定时任务": "crons",
      "环境变量": "envs",
      "配置文件": "configs",
      "脚本管理": "scripts",
      "任务日志": "logs",
      "依赖管理": "dependencies",
      "系统信息": "system",
    };

    List<String> result = [];

    result.addAll(scopeNames.map((e) => keyMaps[e.toString()] ?? "").toList());

    return result;
  }
}
