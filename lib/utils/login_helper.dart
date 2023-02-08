import 'package:flutter/cupertino.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/module/login/login_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../main.dart';

class LoginHelper {
  static int success = 0;
  static int failed = 1;
  static int twiceLogin = 2;

  final String host;
  final String userName;
  final String password;
  final String? alias;
  final bool rememberPassword;

  LoginHelper(
    this.host,
    this.userName,
    this.password,
    this.rememberPassword,
    this.alias,
  );

  Future<int> login(BuildContext context) async {
    SingleAccountPageState.ofHttp(context)?.clear();
    SingleAccountPageState.ofHttp(context)?.host = host;

    SingleAccountPageState.ofUserInfo(context).updateHost(host);
    HttpResponse<LoginBean> response;

    if (loginByUserName()) {
      response =
          await SingleAccountPageState.ofApi(context).login(userName, password);
    } else {
      response = await SingleAccountPageState.ofApi(context)
          .loginByClientId(userName, password);
    }
    if (response.success) {
      loginSuccess(context, response, userName, password);
      return success;
    } else if (loginByUserName() && response.code == 401) {
      //可能用户使用的是老版本qinglong
      HttpResponse<LoginBean> oldResponse =
          await SingleAccountPageState.ofApi(context)
              .loginOld(userName, password);
      if (oldResponse.success) {
        loginSuccess(context, oldResponse, userName, password);
        return success;
      } else {
        (oldResponse.message ?? "请检查网络情况").toast();
        if (oldResponse.code == 420) {
          return twiceLogin;
        } else {
          return failed;
        }
      }
    } else {
      (response.message ?? "请检查网络情况").toast();
      //420代表需要2步验证
      if (response.code == 420) {
        return twiceLogin;
      } else {
        return failed;
      }
    }
  }

  Future<int> loginTwice(BuildContext context, String code) async {
    HttpResponse<LoginBean> response =
        await SingleAccountPageState.ofApi(context)
            .loginTwo(userName, password, code);
    if (response.success) {
      loginSuccess(context, response, userName, password);
      return success;
    } else {
      (response.message ?? "请检查网络情况").toast();
      return failed;
    }
  }

  void loginSuccess(BuildContext context, HttpResponse<LoginBean> response,
      String userName, String password) {
    SingleAccountPageState.ofUserInfo(context).updateToken(
        SingleAccountPageState.of(context)?.index ?? 0,
        host,
        response.bean?.token ?? "",
        false,
        alias);
    if (rememberPassword) {
      SingleAccountPageState.ofUserInfo(context)
          .updateUserName(host, userName, password, !loginByUserName(), alias);
    } else {
      SingleAccountPageState.ofUserInfo(context)
          .updateUserName(host, "", "", !loginByUserName(), alias);
    }
  }

  bool loginByUserName() {
    return true;
  }
}
