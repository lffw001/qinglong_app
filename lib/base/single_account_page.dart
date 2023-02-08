import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/http/url.dart';
import 'package:qinglong_app/base/multi_account_userinfo_viewmodel.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/appkey/appkey_viewmodel.dart';
import 'package:qinglong_app/module/config/config_detail_viewmodel.dart';
import 'package:qinglong_app/module/config/config_viewmodel.dart';
import 'package:qinglong_app/module/env/env_viewmodel.dart';
import 'package:qinglong_app/module/home/home_page.dart';
import 'package:qinglong_app/module/home/system_bean.dart';
import 'package:qinglong_app/module/login/login_page.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_viewmodel.dart';
import 'package:qinglong_app/module/subscribe/subscribe_viewmodel.dart';
import 'package:qinglong_app/module/task/task_viewmodel.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';
import 'package:qinglong_app/utils/utils.dart';

import 'routes.dart';



class SingleAccountPage extends StatefulWidget {
  final int index;

  const SingleAccountPage({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<SingleAccountPage> createState() => SingleAccountPageState();
}

class SingleAccountPageState extends State<SingleAccountPage> {
  late int index;

  late ChangeNotifierProviderFamily<ConfigViewModel, String?> configProvider;
  late ChangeNotifierProviderFamily<DependencyViewModel, String?> dependencyProvider;
  late ChangeNotifierProviderFamily<EnvViewModel, String?> envProvider;
  late ChangeNotifierProviderFamily<TaskViewModel, String?> taskProvider;
  late ChangeNotifierProviderFamily<SubscribeViewModel, String?> subscribeProvider;
  late ChangeNotifierProviderFamily<AppKeyViewModel, String?> appKeyProvider;
  late StateProviderFamily<int, String?> homeIndexProvider;
  late StateProviderFamily<String, String?> codeSearchProvider;

  @override
  void initState() {
    index = widget.index;
    findLoginInfo();
    super.initState();
    registerGlobalKey();
  }

  void registerProvider() {
    configProvider = ChangeNotifierProvider.family((ref, _) => ConfigViewModel(), name: getProviderName(context));
    dependencyProvider = ChangeNotifierProvider.family((ref, _) => DependencyViewModel(), name: getProviderName(context));
    envProvider = ChangeNotifierProvider.family((ref, _) => EnvViewModel(), name: getProviderName(context));
    taskProvider = ChangeNotifierProvider.family((ref, _) => TaskViewModel(), name: getProviderName(context));
    subscribeProvider = ChangeNotifierProvider.family((ref, _) => SubscribeViewModel(), name: getProviderName(context));
    appKeyProvider = ChangeNotifierProvider.family((ref, _) => AppKeyViewModel(), name: getProviderName(context));
    homeIndexProvider = StateProvider.family((ref, _) => 0, name: getProviderName(context));
    codeSearchProvider = StateProvider.family((ref, _) => "", name: getProviderName(context));
  }

  static StateProviderFamily<String, String?> ofCodeSearchProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.codeSearchProvider;
  }

  static StateProviderFamily<int, String?> ofHomeIndexProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.homeIndexProvider;
  }

  static ChangeNotifierProviderFamily<SubscribeViewModel, String?> ofSubscribeProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.subscribeProvider;
  }

  static ChangeNotifierProviderFamily<TaskViewModel, String?> ofTaskProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.taskProvider;
  }

  static ChangeNotifierProviderFamily<AppKeyViewModel, String?> ofAppKeyProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.appKeyProvider;
  }

  static ChangeNotifierProviderFamily<EnvViewModel, String?> ofEnvProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.envProvider;
  }

  static ChangeNotifierProviderFamily<ConfigViewModel, String?> ofConfigProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.configProvider;
  }

  static ChangeNotifierProviderFamily<DependencyViewModel, String?> ofDependencyProvider(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>()!.dependencyProvider;
  }

  static SingleAccountPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<SingleAccountPageState>();
  }

  static UserInfoViewModel ofUserInfo(BuildContext context) {
    int? index = context.findAncestorStateOfType<SingleAccountPageState>()?.index;

    if (index == null) return UserInfoViewModel();

    return getIt<UserInfoViewModel>(instanceName: index.toString());
  }

  static Http? ofHttp(BuildContext context) {
    int? index = context.findAncestorStateOfType<SingleAccountPageState>()?.index;

    if (index == null) return null;

    return getIt<Http>(instanceName: index.toString());
  }

  static Api ofApi(BuildContext context) {
    int? index = context.findAncestorStateOfType<SingleAccountPageState>()?.index;

    if (index == null) return Api(0);

    return Api(index);
  }

  GlobalKey<NavigatorState> navigator = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Navigator(
        key: navigator,
        restorationScopeId: index.toString(),
        onGenerateRoute: (setting) {
          return Routes.generateRoute(setting);
        },
        reportsRouteUpdateToEngine: true,
        initialRoute: ofUserInfo(context).isLogined() ? Routes.routeHomePage : Routes.routeLogin,
      );
    });
  }

  void findLoginInfo() {
    registerProvider();
    if (getIt<MultiAccountUserInfoViewModel>().tokenBeans.isNotEmpty && getIt<MultiAccountUserInfoViewModel>().tokenBeans.length > widget.index) {
      var bean = getIt<MultiAccountUserInfoViewModel>().tokenBeans[index];
      UserInfoBean history = getIt<MultiAccountUserInfoViewModel>().historyAccounts.firstWhere((element) => element.host == bean.host, orElse: () {
        return UserInfoBean();
      });
      UserInfoViewModel userInfoViewModel = UserInfoViewModel(
        token: bean.token,
        useSecret: bean.useSecretLogined,
        host: bean.host,
        name: history.userName,
        password: history.password,
        alias: history.alias,
      );

      getIt.registerSingleton(
        userInfoViewModel,
        instanceName: widget.index.toString(),
      );
    } else if (getIt<MultiAccountUserInfoViewModel>().historyAccounts.isNotEmpty &&
        getIt<MultiAccountUserInfoViewModel>().historyAccounts.length > widget.index) {
      var history = getIt<MultiAccountUserInfoViewModel>().historyAccounts[index];
      UserInfoViewModel userInfoViewModel = UserInfoViewModel(
        host: history.host,
        useSecret: history.useSecretLogined,
        name: history.userName,
        password: history.password,
        alias: history.alias,
      );
      getIt.registerSingleton(
        userInfoViewModel,
        instanceName: widget.index.toString(),
      );
    } else {
      getIt.registerSingleton(
        UserInfoViewModel(),
        instanceName: widget.index.toString(),
      );
    }
    getIt.registerSingleton(Url(widget.index), instanceName: widget.index.toString());
  }

  void registerSystemBean(String version, bool autoGet) {
    if (getIt.isRegistered<SystemBean>(instanceName: widget.index.toString())) {
      getIt.unregister<SystemBean>(instanceName: widget.index.toString());
    }
    getIt.registerSingleton(
        SystemBean(
          version: version,
          fromAutoGet: autoGet,
        ),
        instanceName: widget.index.toString());
  }

  void registerHttp(String host) {
    if (getIt.isRegistered<Http>(instanceName: widget.index.toString())) {
      getIt.unregister<Http>(instanceName: widget.index.toString());
    }
    getIt.registerSingleton(
        Http(
          host,
          widget.index,
        ),
        instanceName: widget.index.toString());
  }

  void registerGlobalKey() {
    if (getIt.isRegistered<GlobalKey<NavigatorState>>(instanceName: widget.index.toString())) {
      getIt.unregister<GlobalKey<NavigatorState>>(instanceName: widget.index.toString());
    }
    getIt.registerSingleton<GlobalKey<NavigatorState>>(navigator, instanceName: widget.index.toString());
  }

  void registerICloud() {
    if (getIt.isRegistered<ICloudUtils>(instanceName: widget.index.toString())) {
      getIt.unregister<ICloudUtils>(instanceName: widget.index.toString());
    }
    getIt.registerSingleton<ICloudUtils>(ICloudUtils(widget.index), instanceName: widget.index.toString());
  }
}
