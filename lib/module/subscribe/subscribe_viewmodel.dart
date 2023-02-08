import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';

class SubscribeViewModel extends BaseViewModel {
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
        await SingleAccountPageState.ofApi(context).subscribes();

    if (result.success && result.bean != null) {
      list.clear();

      List<dynamic>? tempList = jsonDecode(result.bean ?? "[]");

      if (tempList != null && tempList.isNotEmpty) {
        for (int i = 0; i < tempList.length; i++) {
          list.add(tempList[i] as Map<String, dynamic>);
        }
      }
      if (list.isNotEmpty) {
        notifyICloud(context, result.bean ?? "");
      }

      success();
    } else {
      list.clear();
      if (result.code == 404) {
        failed("当前版本不支持订阅管理,如有需要请先将服务器更新到青龙最新版", notify: true);
      } else {
        failed(result.message, notify: true);
      }
    }
  }

  void notifyICloud(BuildContext context, String content) {
    getIt<ICloudUtils>(
            instanceName:
                SingleAccountPageState.of(context)?.index.toString() ?? "0")
        .asyncSubscribe(content);
  }

  Future<void> runCrons(BuildContext context, int cron) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).startSubscribes([cron]);
    if (result.success) {
      loadData(context, false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  Future<void> stopCrons(BuildContext context, int cron) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).stopSubscribes([cron]);
    if (result.success) {
      loadData(context, false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  Future<void> delSubscribe(BuildContext context, int id) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).delSubscribe(id);
    if (result.success) {
      "删除成功".toast();
      loadData(context, false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  Future<void> enableSubscribe(
      BuildContext context, int sId, int isDisabled) async {
    if (isDisabled == 0) {
      HttpResponse<NullResponse> response =
          await SingleAccountPageState.ofApi(context).disableSubscribe(sId);

      if (response.success) {
        "禁用成功".toast();
        loadData(context, false);
      } else {
        failToast(response.message, notify: true);
      }
    } else {
      HttpResponse<NullResponse> response =
          await SingleAccountPageState.ofApi(context).enableSubscribe(sId);

      if (response.success) {
        "启用成功".toast();
        loadData(context, false);
      } else {
        failToast(response.message, notify: true);
      }
    }
  }
}
