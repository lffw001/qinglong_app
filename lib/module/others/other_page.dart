import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/module/in_app_purchase_page.dart';
import 'package:qinglong_app/module/others/change_account_page.dart';
import 'package:qinglong_app/module/others/sort_account_page.dart';
import 'package:qinglong_app/module/others/text_size_page.dart';
import 'package:qinglong_app/module/others/update_password_page.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:path/path.dart' as ints;

import '../../main.dart';
import '../appkey/appkey_page.dart';
import '../home/system_bean.dart';
import '../poet_page.dart';
import '../push_setting_page.dart';
import '../scan_page.dart';
import '../task/task_page.dart';
import '../update_max_account_page.dart';

class OtherPage extends ConsumerStatefulWidget {
  const OtherPage({Key? key}) : super(key: key);

  @override
  OtherPageState createState() => OtherPageState();
}

class OtherPageState extends ConsumerState<OtherPage>
    with LazyLoadState<OtherPage> {
  var toggleValue = false;
  String? userIcon;
  String userName = "青龙客户端";
  var desc = "欢迎使用青龙客户端".obs;
  Map<String, dynamic> poetData = {};

  @override
  void initState() {
    super.initState();
    delLogsByExperiedDate();
  }

  final ScrollController _scrollController = ScrollController();
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey();

  Future<void> move2Top() async {
    if (_scrollController.offset !=
        _scrollController.position.minScrollExtent) {
      await scrollToTop();
    } else {
      if (refreshKey.currentState?.mounted ?? false) {
        await refreshKey.currentState?.show();
      }
    }
  }

  Future<void> scrollToTop() async {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ref.watch(themeProvider).themeColor.bg2Color(),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () async {
          await loadPoet();
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(
              bottom: kBottomNavigationBarHeight + 50,
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  decoration: BoxDecoration(
                    image: (ref.watch(themeProvider).themeMode == modeDark)
                        ? null
                        : const DecorationImage(
                            image:
                                AssetImage('assets/images/icon_other_bg.png'),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: kToolbarHeight + 25,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (SpUtil.getInt(spVIP, defValue: typeNormal) ==
                              typeNormal) {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => const InAppPurchasePage(
                                  fromDirectly: true,
                                ),
                              ),
                            );
                            return;
                          } else {
                            if (SpUtil.getBool(spSingleInstance,
                                defValue: false)) {
                              return;
                            }
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        const ChangeAccountPage(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 15,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (userIcon != null && userIcon!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: userIcon!,
                                      width: 60,
                                      height: 60,
                                      placeholder: (_, __) {
                                        return Image.asset(
                                          getImageByVIPLogo(),
                                          width: 60,
                                          height: 60,
                                        );
                                      },
                                      errorWidget: (_, __, ___) {
                                        return Image.asset(
                                          getImageByVIPLogo(),
                                          width: 60,
                                          height: 60,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      getImageByVIPLogo(),
                                      width: 60,
                                      height: 60,
                                    ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          (SingleAccountPageState.ofUserInfo(
                                                              context)
                                                          .alias ==
                                                      null ||
                                                  SingleAccountPageState
                                                          .ofUserInfo(context)
                                                      .alias!
                                                      .isEmpty)
                                              ? userName
                                              : SingleAccountPageState
                                                      .ofUserInfo(context)
                                                  .alias!,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: ref
                                                .watch(themeProvider)
                                                .themeColor
                                                .titleColor(),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        fit: FlexFit.loose,
                                      ),

                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Obx(
                                    () => GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (poetData.isEmpty) return;
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) => PoetPage(
                                              data: poetData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        desc.value,
                                        style: TextStyle(
                                          color: ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .descColor(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: ref
                              .watch(themeProvider)
                              .themeColor
                              .settingBordorColor(),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      if (getIt<SystemBean>(
                                              instanceName:
                                                  (SingleAccountPageState.of(
                                                                  context)
                                                              ?.index ??
                                                          0)
                                                      .toString())
                                          .isUpperVersion2_13_0()) {
                                        Navigator.of(context).pushNamed(
                                          Routes.routeSubscribeList,
                                        );
                                      } else {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                const TaskPage(
                                              onlyShowPullRepo: true,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/images/icon_subsctibe.png",
                                            width: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            getIt<SystemBean>(
                                                        instanceName:
                                                            (SingleAccountPageState.of(
                                                                            context)
                                                                        ?.index ??
                                                                    0)
                                                                .toString())
                                                    .isUpperVersion2_13_0()
                                                ? "订阅管理"
                                                : "拉库管理",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: ref
                                                  .watch(themeProvider)
                                                  .themeColor
                                                  .titleColor(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        Routes.routeScript,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/images/icon_s.png",
                                            width: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "脚本管理",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: ref
                                                  .watch(themeProvider)
                                                  .themeColor
                                                  .titleColor(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        Routes.routeDependency,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "assets/images/icon_d.png",
                                            width: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "依赖管理",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: ref
                                                  .watch(themeProvider)
                                                  .themeColor
                                                  .titleColor(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    top: 20,
                  ),
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        CupertinoPageRoute(
                          builder: (context) => const InAppPurchasePage(
                            fromDirectly: true,
                          ),
                        ),
                      )
                          .then((value) {
                        setState(() {});
                      });
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: ref
                            .watch(themeProvider)
                            .themeColor
                            .settingBordorColor(),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 15,
                          right: 15,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "APP功能介绍",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ref
                                    .watch(themeProvider)
                                    .themeColor
                                    .titleColor(),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ref
                        .watch(themeProvider)
                        .themeColor
                        .settingBordorColor(),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "多帐号设置",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: ref
                              .watch(themeProvider)
                              .themeColor
                              .titleColor(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildOtherFun2(
                                "多账号数", CupertinoIcons.infinite, () {
                              if (SpUtil.getBool(spSingleInstance,
                                  defValue: false)) {
                                '请先进入 系统设置 关闭单实例模式'.toast();
                                return;
                              }

                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const UpdateMaxAccountPage(),
                                ),
                              );
                            }),
                          ),
                          const Spacer(),
                          const Spacer(),
                          const Spacer(),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ref
                        .watch(themeProvider)
                        .themeColor
                        .settingBordorColor(),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "高级功能",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: ref
                              .watch(themeProvider)
                              .themeColor
                              .titleColor(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildOtherFun2(
                                "扫描依赖", CupertinoIcons.doc_text_search, () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const ScanPage(),
                                ),
                              );
                            }),
                          ),
                          Expanded(
                            child: buildOtherFun2(
                              "字体大小",
                              CupertinoIcons.textformat_size,
                              () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          const TextSizePage()),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: buildOtherFun2(
                                "文件备份", CupertinoIcons.cloud_upload, () {
                              Navigator.of(context)
                                  .pushNamed(Routes.routeICloud);
                            }),
                          ),
                          Expanded(
                            child: SpUtil.getBool(spSingleInstance,
                                    defValue: false)
                                ? const SizedBox.shrink()
                                : buildOtherFun2(
                                    "账号排序", CupertinoIcons.arrow_swap, () {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            const SortAccountPage(),
                                      ),
                                    );
                                  }),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ref
                        .watch(themeProvider)
                        .themeColor
                        .settingBordorColor(),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "基础功能",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              ref.watch(themeProvider).themeColor.titleColor(),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildOtherFun(
                                "任务日志", "assets/images/icon_task_log.png", () {
                              Navigator.of(context).pushNamed(
                                Routes.routeTaskLog,
                              );
                            }),
                          ),
                          Expanded(
                            child: buildOtherFun(
                                "登录日志", "assets/images/icon_login_icon.png",
                                () {
                              if (SingleAccountPageState.ofUserInfo(context)
                                  .useSecretLogined) {
                                "使用client_id方式登录无法获取登录日志".toast();
                              } else {
                                Navigator.of(context).pushNamed(
                                  Routes.routeLoginLog,
                                );
                              }
                            }),
                          ),
                          Expanded(
                            child: buildOtherFun2(
                              "应用设置",
                              CupertinoIcons.gear_alt,
                              () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) => const AppKeyPage()));
                              },
                            ),
                          ),
                          Expanded(
                            child: buildOtherFun2(
                              "通知设置",
                              CupertinoIcons.envelope,
                              () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) =>
                                        const PushSettingPage()));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: buildOtherFun2(
                                "修改密码", CupertinoIcons.lock_shield, () {
                              if (SingleAccountPageState.ofUserInfo(context)
                                  .useSecretLogined) {
                                "使用client_id方式登录无法修改密码".toast();
                              } else {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) =>
                                        const UpdatePasswordPage()));
                              }
                            }),
                          ),
                          Expanded(
                            child: buildOtherFun2(
                                "日志设置", CupertinoIcons.gobackward_30, () {
                              _delLog(context);
                            }),
                          ),
                          Expanded(
                            child: buildOtherFun(
                              "系统设置",
                              "assets/images/icon_safety.png",
                              () {
                                Navigator.of(context).pushNamed(
                                  Routes.routeSetting,
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: buildOtherFun(
                              "关于软件",
                              "assets/images/icon_about.png",
                              () {
                                Navigator.of(context).pushNamed(
                                  Routes.routeAbout,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: kBottomNavigationBarHeight +
                      MediaQuery.of(context).viewPadding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _delLog(BuildContext context) async {
    var response = await SingleAccountPageState.ofApi(context).logDel();
    String day = "";

    if (response.success) {
      if (response.bean != null && response.bean?.frequency != null) {
        day = response.bean!.frequency!.toString();
      } else {
        day = response.bean?.info?.frequency.toString() ?? "";
      }
    }

    TextEditingController controller = TextEditingController(text: day);
    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          "日志删除频率:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("每"),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ref
                                .watch(themeProvider)
                                .themeColor
                                .title2Color(),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ref
                                .watch(themeProvider)
                                .themeColor
                                .title2Color(),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      autofocus: false,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("天"),
                ],
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "取消",
              style: TextStyle(
                color: Color(0xff999999),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              "确定",
              style: TextStyle(
                color: ref.watch(themeProvider).primaryColor,
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              commitLogDel(
                int.tryParse(controller.text) ?? 1000,
              );
            },
          ),
        ],
      ),
    );
  }

  void commitLogDel(int time) async {
    var response = await SingleAccountPageState.ofApi(context).logDelTime(time);
    if (response.success) {
      "修改成功".toast();
    } else {
      response.message.toast();
    }
  }

  Widget buildOtherFun(
    String title,
    String icon,
    GestureTapCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: CupertinoButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 3,
          ),
          child: Column(
            children: [
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                    ref.watch(themeProvider).primaryColor, BlendMode.srcIn),
                child: Image.asset(
                  icon,
                  width: 24,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOtherFun2(
    String title,
    IconData icon,
    GestureTapCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 2,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 3,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: ref.watch(themeProvider).primaryColor,
                size: 24,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getImageByVIP() {
    return "assets/images/normal.png";
  }

  String getImageByVIPLogo() {
    return "assets/images/ql.png";
  }

  @override
  void onLazyLoad() async {
    var response = await SingleAccountPageState.ofApi(context).user();

    if (response.success) {
      userIcon = response.bean?.avatar;
      userName = response.bean?.username ?? "青龙客户端";
      if (userIcon != null && userIcon!.isNotEmpty) {
        userIcon =
            "${SingleAccountPageState.ofUserInfo(context).host}/api/static/$userIcon";
      }
      setState(() {});
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadPoet();
    });
  }

  void delLogsByExperiedDate() async {
    try {
      int before = SpUtil.getInt(spLocalBackUpFileExperiedTime,
          defValue: getDefaultLogExperiedTime());
      String now = DateFormat('yyyy-MM-dd').format(DateTime.now()); //获取多少天前的日期

      print("...$before天之前的文件全部删除");

      Directory directory = Directory(
          "${await FileUtil(SingleAccountPageState.of(context)?.index ?? 0).localPath}/");

      List<FileSystemEntity> list = directory.listSync();

      for (FileSystemEntity file in list) {
        String date = ints.basename(file.path);
        var a = DateTime.tryParse(date);
        var b = DateTime.tryParse(now);

        if (a != null && b != null) {
          if (b.difference(a).inDays > before) {
            if (await file.exists()) {
              await file.delete(recursive: true);
              print("删除成功${file.path}");
            }
          } else {
            print("不用删除${file.path}");
          }
        } else {
          print("时间格式出错${file.path}");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadPoet() async {
    try {
      Dio dio = Dio(BaseOptions(
        receiveTimeout: 10000,
        connectTimeout: 10000,
      ));

      if (!SpUtil.haveKey(spPoetToken)) {
        var tokenResponse = await dio.get("https://v2.jinrishici.com/token");

        if (tokenResponse.statusCode == 200) {
          String? token = tokenResponse.data["data"];
          if (token != null && token.isNotEmpty) {
            SpUtil.putString(spPoetToken, token);
          }
        }
      }

      var response = await dio.get("https://v2.jinrishici.com/one.json",
          options: Options(
            headers: {
              "X-User-Token": SpUtil.getString(spPoetToken, defValue: ""),
            },
          ));
      if (response.statusCode == 200) {
        poetData.clear();
        poetData.addAll(response.data as Map<String, dynamic>);
        desc.value = poetData["data"]?["content"]?.toString() ?? "欢迎使用青龙客户端";
      }
    } catch (e) {}
  }
}

int getDefaultLogExperiedTime() {
  int count = 5;
  if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeVIP) {
    count = 5;
  } else {
    count = 30;
  }
  return count;
}
