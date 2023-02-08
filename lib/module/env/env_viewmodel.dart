import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';

class EnvViewModel extends BaseViewModel {
  static const String allStr = "全部";
  static const String disabledStr = "已禁用";
  static const String enabledStr = "已启用";
  List<EnvBean> list = [];
  List<EnvBean> disabledList = [];
  List<EnvBean> enabledList = [];

  @override
  void retry(BuildContext context, {bool showLoading = true}) {
    loadData(context, showLoading);
  }

  Future<void> loadData(BuildContext context, [isLoading = true]) async {
    if (isLoading && list.isEmpty) {
      loading(notify: true);
    }

    HttpResponse<List<EnvBean>> result =
        await SingleAccountPageState.ofApi(context).envs("");

    if (result.success && result.bean != null) {
      list.clear();
      list.addAll(result.bean!);
      disabledList.clear();
      disabledList
          .addAll(list.where((element) => element.status == 1).toList());
      enabledList.clear();
      enabledList.addAll(list.where((element) => element.status == 0).toList());
      notifyICloud(context, list);
      success();
    } else {
      list.clear();
      disabledList.clear();
      enabledList.clear();
      failed(result.message, notify: true);
    }
  }

  void notifyICloud(BuildContext context, List<EnvBean> list) {
    getIt<ICloudUtils>(
            instanceName:
                SingleAccountPageState.of(context)?.index.toString() ?? "0")
        .asyncEnv(list);
  }

  Future<void> delEnvs(BuildContext context, List<String> id) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).delEnvs(id);
    if (result.success) {
      "删除成功".toast();
      loadData(context, false);
    } else {
      failed(result.message, notify: true);
    }
  }

  Future<void> delEnv(BuildContext context, String id) async {
    HttpResponse<NullResponse> result =
        await SingleAccountPageState.ofApi(context).delEnv(id);
    if (result.success) {
      "删除成功".toast();
      loadData(context, false);
    } else {
      failed(result.message, notify: true);
    }
  }

  void updateEnv(BuildContext context, EnvBean result) {
    loadData(context, false);
  }

  Future<void> enableEnv(
      BuildContext context, List<String> sId, int status) async {
    if (status == 1) {
      HttpResponse<NullResponse> response =
          await SingleAccountPageState.ofApi(context).enableEnv(sId);

      if (response.success) {
        "启用成功".toast();
        loadData(context, false);
      } else {
        failToast(response.message, notify: true);
      }
    } else {
      HttpResponse<NullResponse> response =
          await SingleAccountPageState.ofApi(context).disableEnv(sId);

      if (response.success) {
        "禁用成功".toast();
        loadData(context, false);
      } else {
        failToast(response.message, notify: true);
      }
    }
  }

  void update(
      BuildContext context, String id, int newIndex, int oldIndex) async {
    await SingleAccountPageState.ofApi(context).moveEnv(id, oldIndex, newIndex);
    loadData(context, false);
  }
}
