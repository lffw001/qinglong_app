import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launch_review/launch_review.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/qlvisible.dart';
import 'package:qinglong_app/module/home/system_bean.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> with LazyLoadState<AboutPage> {
  String desc = "";
  String versionCode = "";

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  @override
  Widget build(BuildContext context) {
    SystemBean? systemBean;

    try {
      systemBean = getIt<SystemBean>(instanceName: (SingleAccountPageState.of(context)?.index ?? 0).toString());
    } catch (e) {
      systemBean = SystemBean(version: "2.10.13", fromAutoGet: false);
    }
    return Scaffold(
      backgroundColor: ref.watch(themeProvider).themeColor.bg2Color(),
      appBar: QlAppBar(
        canBack: true,
        title: "关于软件",
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 25,
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/images/ql.png",
                    height: 60,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Text(
                  "青龙客户端",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ref.watch(themeProvider).themeColor.titleColor(),
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: Text(
                  "基于青龙开源项目打造的第三方${getPlatformName()}客户端",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "版本",
                            style: TextStyle(
                              color: ref.watch(themeProvider).themeColor.titleColor(),
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "$desc ($versionCode)",
                            style: TextStyle(
                              color: ref.watch(themeProvider).themeColor.descColor(),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      indent: 15,
                      height: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        onTap: () {
                          _checkUpdate();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 10,
                            top: 10,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "青龙服务端",
                                style: TextStyle(
                                  color: ref.watch(themeProvider).themeColor.titleColor(),
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${systemBean.version}",
                                style: TextStyle(
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  "反馈",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    QlVisible(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          onTap: () async {
                            LaunchReview.launch(writeReview: false, iOSAppId: "1625871665");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.heart,
                                  color: ref.watch(themeProvider).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "在 App Store 评分",
                                  style: TextStyle(
                                    color: ref.watch(themeProvider).themeColor.titleColor(),
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  size: 16,
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      childReplace: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          onTap: () async {
                            try {
                              await launchUrl(Uri.tryParse("https://t.me/qinglongapp")!);
                            } catch (e) {
                              logger.e(e);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.cloud_download,
                                  color: ref.watch(themeProvider).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "下载地址",
                                  style: TextStyle(
                                    color: ref.watch(themeProvider).themeColor.titleColor(),
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  size: 16,
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 50,
                      height: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _launchURL("https://newtab.work/PrivacyPolicy.html");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.shield,
                                color: ref.watch(themeProvider).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "用户协议",
                                style: TextStyle(
                                  color: ref.watch(themeProvider).themeColor.titleColor(),
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                CupertinoIcons.right_chevron,
                                size: 16,
                                color: ref.watch(themeProvider).themeColor.descColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 50,
                      height: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _launchURL("https://t.me/qinglongapp");
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.paperplane,
                                color: ref.watch(themeProvider).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "App更新通知",
                                style: TextStyle(
                                  color: ref.watch(themeProvider).themeColor.titleColor(),
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                CupertinoIcons.right_chevron,
                                size: 16,
                                color: ref.watch(themeProvider).themeColor.descColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 50,
                      height: 1,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        onTap: () {
                          if (Platform.isAndroid) {
                            Share.share("分享一款好用的青龙客户端，快去点击下面的链接地址下载吧 https://t.me/qinglongapp");
                          } else {
                            Share.share("分享一款好用的青龙客户端，快去美区 AppStore 搜索『青龙客户端』或者点击下面的链接地址下载吧 https://apps.apple.com/us/app/id1625871665");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.share,
                                color: ref.watch(themeProvider).primaryColor,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                "分享App",
                                style: TextStyle(
                                  color: ref.watch(themeProvider).themeColor.titleColor(),
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                CupertinoIcons.right_chevron,
                                size: 16,
                                color: ref.watch(themeProvider).themeColor.descColor(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "APP不会收集任何关于您的信息,使用前请仔细阅读用户协议",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String _url) async {
    try {
      await launchUrl(Uri.tryParse(_url.trimLeft())!);
    } catch (e) {
      logger.e(e);
    }
  }

  void getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    versionCode = packageInfo.buildNumber;
    desc = version;
    setState(() {});
  }

  @override
  void onLazyLoad() {}

  void _checkUpdate() async {
    var response = await SingleAccountPageState.ofApi(context).checkUpdate();
    if (response.success) {
      if (response.bean?.hasNewVersion ?? false) {
        showCupertinoDialog(
          context: context,
          useRootNavigator: false,
          builder: (childContext) => CupertinoAlertDialog(
            title: Text("青龙服务端发现新版本 ${response.bean?.lastVersion}"),
            content: Padding(
              padding: const EdgeInsets.only(
                left: 5,
                top: 5,
              ),
              child: Text(
                "${response.bean?.lastLog}",
                textAlign: TextAlign.left,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                  "知道了",
                ),
                onPressed: () {
                  Navigator.of(childContext).pop();
                },
              ),
            ],
          ),
        );
      } else {
        "已经是新版本".toast();
      }
    }
  }
}

String getPlatformName() {
  if (Platform.isAndroid) {
    return "Android";
  }
  return "iOS";
}
