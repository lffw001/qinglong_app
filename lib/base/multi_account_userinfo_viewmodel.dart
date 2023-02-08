import 'dart:convert';
import 'dart:io';

import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

import 'sp_const.dart';
import 'userinfo_viewmodel.dart';

class MultiAccountUserInfoViewModel {
  static int maxAccount = 1; //1代表普通用户, 5代表付费用户

  List<TokenBean> tokenBeans = [];
  List<UserInfoBean> historyAccounts = [];

  static void payedVIP(int type) {
    if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeSVIP) return;

    SpUtil.putInt(spVIP, type);

    int count = 1;
    if (type == typeNormal) {
      count = 1;
    } else if (type == typeVIP) {
      count = 3;
    } else if (type == typeSVIP) {
      count = 5;
    }
    SpUtil.putInt(spAccountCount, count);
  }

  static void updateMaxAccount(int count) {

    SpUtil.putInt(spAccountCount, count);
  }

  MultiAccountUserInfoViewModel() {
    try {
      List<dynamic>? tempTokenList = jsonDecode(SpUtil.getString(spTokenBeanList, defValue: '[]'));

      if (tempTokenList != null && tempTokenList.isNotEmpty) {
        for (Map<String, dynamic> value in tempTokenList) {
          //把token里的空数据拿掉
          var bean = TokenBean.fromJson(value);
          if (bean.host == null && bean.token == null) continue;
          tokenBeans.add(TokenBean.fromJson(value));
        }
      }

      List<dynamic>? tempList = jsonDecode(SpUtil.getString(spLoginHistory, defValue: '[]'));

      if (tempList != null && tempList.isNotEmpty) {
        for (Map<String, dynamic> value in tempList) {
          historyAccounts.add(UserInfoBean.fromJson(value));
        }
      }
    } catch (e) {
      e.toString().toast2();
    }
  }

  void initVipState() {
    int vipType = SpUtil.getInt(spVIP, defValue: typeNormal);

    if (vipType == typeNormal) {
      maxAccount = 1;
    } else if (vipType == typeVIP) {
      maxAccount = 3;
    } else {
      maxAccount = SpUtil.getInt(spAccountCount, defValue: 5);
    }
  }

  void save2HistoryAccount(UserInfoBean userInfoBean) {
    //如果已经存在host，那就更新

    historyAccounts.removeWhere((element) => element.host == userInfoBean.host);

    historyAccounts.insert(
      0,
      userInfoBean,
    );

    SpUtil.putString(spLoginHistory, jsonEncode(historyAccounts));
  }

  void removeHistoryAccount(String? host) {
    if (host == null || host.isEmpty) return;

    historyAccounts.removeWhere((element) => element.host == host);

    SpUtil.putString(spLoginHistory, jsonEncode(historyAccounts));
  }

  void updateToken(int index, String? host, String? token, bool useSecretLogined, String? alias) {
    if (host == null) return;

    if (MultiAccountUserInfoViewModel.maxAccount == 1) {
      tokenBeans.clear();
      tokenBeans.add(
        TokenBean(
          token: token,
          host: host,
          useSecretLogined: useSecretLogined,
          alias: alias,
        ),
      );
    } else {
      if (tokenBeans.length <= index) {
        tokenBeans.add(
          TokenBean(
            token: token,
            host: host,
            useSecretLogined: useSecretLogined,
            alias: alias,
          ),
        );
      } else {
        tokenBeans[index].token = token;
        tokenBeans[index].useSecretLogined = useSecretLogined;
        tokenBeans[index].alias = alias;
        tokenBeans[index].host = host;
      }
    }
    SpUtil.putString(spTokenBeanList, jsonEncode(tokenBeans));
  }

  void removeTokenBean(int index) {
    tokenBeans[index].token = null;
    tokenBeans[index].host = null;
    tokenBeans[index].alias = null;
    tokenBeans[index].useSecretLogined = false;
    SpUtil.putString(spTokenBeanList, jsonEncode(tokenBeans));
  }

  void resetTokenBeans(List<TokenBean> bean) {
    SpUtil.putString(spTokenBeanList, jsonEncode(bean));
    tokenBeans.clear();
    tokenBeans.addAll(bean);
  }
}
