import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/config/config_bean.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

class ConfigViewModel extends BaseViewModel {
  List<ConfigBean> list = [];

  @override
  void retry(BuildContext context, {bool showLoading = true}) {
    loadData(context, showLoading);
  }

  Future<void> loadData(BuildContext context, [isLoading = true]) async {
    if (isLoading && list.isEmpty) {
      loading(notify: true);
    }

    HttpResponse<List<ConfigBean>> result =
        await SingleAccountPageState.ofApi(context).files();

    if (result.success && result.bean != null) {
      list.clear();
      list.addAll(result.bean!);
      backUpAllConfigFiles(context);
      success();
    } else {
      list.clear();
      failed(result.message, notify: true);
    }
  }

  void backUpAllConfigFiles(BuildContext context) async {

    var icloudUtils = getIt<ICloudUtils>(
        instanceName:
            (SingleAccountPageState.of(context)?.index ?? 0).toString());
    for (ConfigBean c in list) {
      HttpResponse<String> result =
          await SingleAccountPageState.ofApi(context).content(
        c.title ?? c.value ?? "",
      );
      if (result.success && result.bean != null) {
        String content = result.bean ?? "";
        await icloudUtils.asyncConfig(c.title, content);
      }
    }
  }
}
