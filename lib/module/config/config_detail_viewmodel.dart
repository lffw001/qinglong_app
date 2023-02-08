import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/config/config_bean.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';

class ConfigDetailViewModel extends BaseViewModel {
  String? content;

  Future<void> loadData(BuildContext context, ConfigBean bean,
      [isLoading = true]) async {
    if (isLoading) {
      loading(notify: true);
    }
    HttpResponse<String> result =
        await SingleAccountPageState.ofApi(context).content(bean.value!);
    if (result.success && result.bean != null) {
      content = result.bean;
      success();
    } else {
      failed(result.message, notify: true);
    }
  }

  void reset() {
    content = null;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loading(notify: true);
    });
  }
}
