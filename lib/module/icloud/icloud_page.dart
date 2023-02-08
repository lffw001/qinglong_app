import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/others/file_directory_page.dart';
import 'package:qinglong_app/module/others/other_page.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

import '../../base/theme.dart';

class IcloudPage extends ConsumerStatefulWidget {
  const IcloudPage({Key? key}) : super(key: key);

  @override
  ConsumerState<IcloudPage> createState() => _IcloudPageState();
}

class _IcloudPageState extends ConsumerState<IcloudPage> with LazyLoadState<IcloudPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ref.watch(themeProvider).themeColor.bg2Color(),
      appBar: QlAppBar(
        title: "文件备份",
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  "当你添加,修改,删除的时候,将会自动备份",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 3,
                        bottom: 3,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "自动备份",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Transform.scale(
                            scale: 0.9,
                            child: CupertinoSwitch(
                              value: SpUtil.getBool(spICloud, defValue: true),
                              onChanged: (v) {
                                SpUtil.putBool(spICloud, v);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          lookUpFiles();
                        },
                        child: Ink(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "查看文件",
                                style: TextStyle(
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
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  "当前已有备份文件 $fileNum 个,共占用 $fileSizes 容量",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  "环境变量",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          try {
                            var result = await Api(SingleAccountPageState.of(context)!.index).envs("");
                            await getIt<ICloudUtils>(instanceName: SingleAccountPageState.of(context)!.index.toString()).asyncEnv(
                              result.bean ?? [],
                              focusUpdate: true,
                            );
                            SpUtil.putString(spEnvBackTime, ICloudUtils.now());
                            setState(() {});
                          } catch (e) {}
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "同步环境变量",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    SpUtil.getString(
                                      spEnvBackTime,
                                      defValue: "",
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ref.watch(themeProvider).themeColor.descColor(),
                                    ),
                                  ),
                                ),
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
                    const Divider(
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          lookUpFiles();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "还原备份",
                                style: TextStyle(
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
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          if (Platform.isAndroid) {
                            "请点击页面下方备份文件删除频率按钮设置删除".toast2();
                            return;
                          }
                          "请前往 \"文件\" App手动删除".toast();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "删除备份",
                                style: TextStyle(
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
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  SpUtil.getInt(spVIP, defValue: typeNormal) == typeVIP ? "config.sh文件" : "配置文件",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          String content;
                          HttpResponse<String> result = await SingleAccountPageState.ofApi(context).content("config.sh");
                          if (result.success && result.bean != null) {
                            content = result.bean ?? "";
                            await ICloudUtils(SingleAccountPageState.of(context)!.index).asyncConfig(
                              "config.sh",
                              content,
                              focusUpdate: true,
                            );
                            SpUtil.putString(spConfigBackTime, ICloudUtils.now());
                            setState(() {});
                          } else {
                            result.message!.toast();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "同步config.sh文件",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    SpUtil.getString(
                                      spConfigBackTime,
                                      defValue: "",
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ref.watch(themeProvider).themeColor.descColor(),
                                    ),
                                  ),
                                ),
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
                    const Divider(
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          lookUpFiles();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "还原备份",
                                style: TextStyle(
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
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          if (Platform.isAndroid) {
                            "请点击页面下方备份文件删除频率按钮设置删除".toast2();
                            return;
                          }
                          "请前往 \"文件\" App手动删除".toast();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "删除备份",
                                style: TextStyle(
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
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  "备份和还原配置文件",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  "订阅管理",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                decoration: BoxDecoration(
                  color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          try {
                            var result = await Api(SingleAccountPageState.of(context)!.index).subscribes();
                            await getIt<ICloudUtils>(instanceName: SingleAccountPageState.of(context)!.index.toString()).asyncSubscribe(
                              result.bean ?? "",
                              focusUpdate: true,
                            );
                            SpUtil.putString(spSubscribeBackTime, ICloudUtils.now());
                            setState(() {});
                          } catch (e) {}
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "同步订阅管理",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    SpUtil.getString(
                                      spSubscribeBackTime,
                                      defValue: "",
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ref.watch(themeProvider).themeColor.descColor(),
                                    ),
                                  ),
                                ),
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
                    const Divider(
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          lookUpFiles();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "还原备份",
                                style: TextStyle(
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
                      height: 1,
                      indent: 15,
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        onTap: () async {
                          if (Platform.isAndroid) {
                            "请点击页面下方备份文件删除频率按钮设置删除".toast2();
                            return;
                          }
                          "请前往 \"文件\" App手动删除".toast();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "删除备份",
                                style: TextStyle(
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
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Text(
                  "功能",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(15),
                ),
                onTap: () {
                  _delDuration();
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 15,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "备份文件删除频率",
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
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: Platform.isAndroid,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: Text(
                    "Android用户为了数据安全,备份文件保存在/data/user/0/work.master.qinglongapp/files/文件夹下,非root用户无法通过文件浏览器查看,只可以点击页面顶部的查看文件按钮查看",
                    style: TextStyle(
                      color: ref.watch(themeProvider).themeColor.descColor(),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delDuration() {
    TextEditingController controller = TextEditingController(
      text: SpUtil.getInt(spLocalBackUpFileExperiedTime, defValue: getDefaultLogExperiedTime()).toString(),
    );
    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("备份文件删除频率:"),
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
                            color: ref.watch(themeProvider).themeColor.title2Color(),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ref.watch(themeProvider).themeColor.title2Color(),
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
              try {
                if (int.tryParse(controller.text) == null || int.tryParse(controller.text)! > 100) {
                  "最大可设置100天".toast();
                  return;
                }
                if (int.tryParse(controller.text) == null || int.tryParse(controller.text)! < 1) {
                  "最小可设置1天".toast();
                  return;
                }

                SpUtil.putInt(spLocalBackUpFileExperiedTime, int.tryParse(controller.text)!);
                Navigator.of(context).pop();
              } catch (e) {}
            },
          ),
        ],
      ),
    );
  }

  @override
  void onLazyLoad() async {
    try {
      Map<String, int> result = await compute(dirStatSync, await FileUtil(SingleAccountPageState.of(context)?.index ?? 0).sourcePath);
      fileNum = result["fileNum"].toString();
      fileSizes = getFileSizeString(
        result["size"] ?? 0,
        2,
      );
      setState(() {});
    } catch (e) {}
  }

  String? fileNum = "-";
  String fileSizes = "-";

  static String getFileSizeString(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)}${suffixes[i]}';
  }

  void lookUpFiles() async {
    String path = await FileUtil(SingleAccountPageState.of(context)?.index ?? 0).sourcePath;
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => FileDirectoryPage(
          path: path,
        ),
      ),
    );
  }
}

Map<String, int> dirStatSync(String dirPath) {
  int fileNum = 0;
  int totalSize = 0;
  var dir = Directory(dirPath);
  try {
    if (dir.existsSync()) {
      dir.listSync(recursive: true, followLinks: false).forEach((FileSystemEntity entity) {
        if (entity is File) {
          fileNum++;
          totalSize += entity.lengthSync();
        }
      });
    }
  } catch (e) {}

  return {'fileNum': fileNum, 'size': totalSize};
}
