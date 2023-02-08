import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/subscribe/subscribe_detail_page.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:url_launcher/url_launcher.dart';

class AddSubscribePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> taskBean;

  const AddSubscribePage({Key? key, required this.taskBean}) : super(key: key);

  @override
  ConsumerState<AddSubscribePage> createState() => _AddSubscribePageState();
}

enum Type {
  public,
  single,
  private,
}

enum PullType {
  privateKey,
  userName,
}

enum CronType {
  cron,
  interval,
}

class _AddSubscribePageState extends ConsumerState<AddSubscribePage> {
  static const cName = "name";
  static const cType = "type";
  static const cLink = "url";
  static const cBranch = "branch";
  static const cPullType = "pull_type";
  static const cPrivateKey = "private_key";
  static const cUserName = "username";
  static const cPassword = "password";
  static const cCronType = "schedule_type";
  static const cPullOption = "pull_option";
  static const cCron = "schedule";
  static const cInterval = "interval_schedule";
  static const cWhite = "whitelist";
  static const cBlack = "blacklist";
  static const cDep = "dependences";
  static const cSuffix = "extensions";
  static const cBefore = "sub_before";
  static const cAfter = "sub_after";
  static const cAlias = "alias";

  final TextEditingController _nameController = TextEditingController();
  Type type = Type.public;
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  CronType cronType = CronType.cron;
  final TextEditingController _cronController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  PullType pullType = PullType.privateKey;
  String intervalUnit = "天";
  final TextEditingController _privateKeyController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _whiteListController = TextEditingController();
  final TextEditingController _blackListController = TextEditingController();
  final TextEditingController _depController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _taskBeforeController = TextEditingController();
  final TextEditingController _taskAfterController = TextEditingController();

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        actions: [
          CommitButton(
            onTap: () {
              submit();
            },
          ),
        ],
        title: widget.taskBean.isEmpty ? "新增订阅" : "编辑订阅",
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              const TitleWidget("名称"),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "请输入订阅名",
                ),
                autofocus: false,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleWidget(
                    "类型",
                    required: true,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        buildRadioButton(
                          "公开仓库",
                          type == Type.public,
                          onTap: () {
                            type = Type.public;
                            setState(() {});
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        buildRadioButton(
                          "私有仓库",
                          type == Type.private,
                          onTap: () {
                            type = Type.private;
                            setState(() {});
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        buildRadioButton(
                          "单文件",
                          type == Type.single,
                          onTap: () {
                            type = Type.single;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const TitleWidget(
                "链接",
                required: true,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  hintText: "请输入订阅链接",
                ),
                autofocus: false,
              ),
              Visibility(
                visible: type == Type.public,
                child: _buildOpenPub(),
              ),
              Visibility(
                visible: type == Type.single,
                child: _buildSingle(),
              ),
              Visibility(
                visible: type == Type.private,
                child: _buildPrivatePub(),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleWidget(
                    "定时类型",
                    required: true,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        buildRadioButton(
                          "crontab",
                          cronType == CronType.cron,
                          onTap: () {
                            cronType = CronType.cron;
                            setState(() {});
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        buildRadioButton(
                          "interval",
                          cronType == CronType.interval,
                          onTap: () {
                            cronType = CronType.interval;
                            setState(() {});
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: cronType == CronType.cron,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: cronType == CronType.cron,
                child: const TitleWidget(
                  "定时规则",
                  required: true,
                ),
              ),
              Visibility(
                visible: cronType == CronType.cron,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: cronType == CronType.cron,
                child: TextField(
                  controller: _cronController,
                  decoration: const InputDecoration(
                    hintText: "秒(可选) 分 时 天 月 周",
                  ),
                  autofocus: false,
                ),
              ),
              Visibility(
                visible: cronType == CronType.cron,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: cronType == CronType.cron,
                child: GestureDetector(
                  onTap: () async {
                    try {
                      await launchUrl(Uri.tryParse("https://crontab.guru")!);
                    } catch (e) {}
                  },
                  child: Text(
                    "在线测试",
                    style: TextStyle(
                      fontSize: 12,
                      color: ref.watch(themeProvider).primaryColor,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: cronType == CronType.interval,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: cronType == CronType.interval,
                child: const TitleWidget(
                  "定时规则",
                  required: true,
                ),
              ),
              Visibility(
                visible: cronType == CronType.interval,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const TitleWidget(
                          "每",
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _intervalController,
                            decoration: const InputDecoration(
                              hintText: "",
                            ),
                            autofocus: false,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String result) {
                            intervalUnit = result;
                            setState(() {});
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: "天",
                              child: Text("天"),
                            ),
                            const PopupMenuItem<String>(
                              value: "时",
                              child: Text("时"),
                            ),
                            const PopupMenuItem<String>(
                              value: "分",
                              child: Text("分"),
                            ),
                            const PopupMenuItem<String>(
                              value: "秒",
                              child: Text("秒"),
                            ),
                          ],
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              TitleWidget(
                                intervalUnit,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                CupertinoIcons.chevron_up_chevron_down,
                                size: 16,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const TitleWidget(
                  "白名单",
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: TextField(
                  controller: _whiteListController,
                  decoration: const InputDecoration(
                    hintText: "请输入脚本筛选白名单关键词,多个关键词竖线分割",
                  ),
                  autofocus: false,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const TitleWidget(
                  "黑名单",
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: TextField(
                  controller: _blackListController,
                  decoration: const InputDecoration(
                    hintText: "请输入脚本筛选黑名单关键词,多个关键词竖线分割",
                  ),
                  autofocus: false,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const TitleWidget(
                  "依赖文件",
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: TextField(
                  controller: _depController,
                  decoration: const InputDecoration(
                    hintText: "请输入依赖文件关键词,多个关键词竖线分割",
                  ),
                  autofocus: false,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const TitleWidget(
                  "文件后缀",
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: TextField(
                  controller: _suffixController,
                  decoration: const InputDecoration(
                    hintText: "请输入文件后缀",
                  ),
                  autofocus: false,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const TitleWidget(
                  "执行前",
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: TextField(
                  controller: _taskBeforeController,
                  decoration: const InputDecoration(
                    hintText: "请输入运行订阅前要执行的命令",
                  ),
                  autofocus: false,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 15,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const TitleWidget(
                  "执行后",
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: const SizedBox(
                  height: 10,
                ),
              ),
              Visibility(
                visible: type != Type.single,
                child: TextField(
                  controller: _taskAfterController,
                  decoration: const InputDecoration(
                    hintText: "请输入运行订阅后要执行的命令",
                  ),
                  autofocus: false,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRadioButton(
    String title,
    bool isCheck, {
    GestureTapCallback? onTap,
    flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Row(
          children: [
            Image.asset(
              isCheck
                  ? "assets/images/icon_check.png"
                  : "assets/images/icon_uncheck.png",
              width: 16,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  void submit() async {
    if (_linkController.text.isEmpty) {
      "请输入订阅链接".toast();
      return;
    }

    if (type == Type.private) {
      if (pullType == PullType.privateKey) {
        if (_privateKeyController.text.isEmpty) {
          "请输入私钥".toast();
          return;
        }
      }
      if (pullType == PullType.userName) {
        if (_userNameController.text.isEmpty) {
          "请输入认证用户名".toast();
          return;
        }
        if (_userPasswordController.text.isEmpty) {
          "请输入密码或者Token".toast();
          return;
        }
      }
    }

    if (cronType == CronType.cron) {
      if (_cronController.text.isEmpty) {
        "请输入定时规则".toast();
        return;
      }
    }
    if (cronType == CronType.interval) {
      if (_intervalController.text.isEmpty) {
        "请输入定时规则".toast();
        return;
      }
    }

    commitReal();
  }

  void commitReal() async {
    try {
      Map<String, dynamic> params = {
        cName: _nameController.getTextOrDefault(),
        cType: type.name,
        cCronType: cronType.name,
        cLink: _linkController.getTextOrDefault(),
      };

      if (widget.taskBean.containsKey("id")) {
        params["id"] = widget.taskBean["id"];
      }

      if (cronType == CronType.cron) {
        params[cCron] = _cronController.getTextOrDefault();
      } else {
        params[cInterval] = {
          "type": getCodeByName(intervalUnit),
          "value": int.tryParse(_intervalController.text)
        };
      }

      if (type == Type.private) {
        params[cPullType] = pullType.name;
        if (pullType == PullType.userName) {
          params[cPullOption] = {
            cUserName: _userNameController.getTextOrDefault(),
            cPassword: _userPasswordController.getTextOrDefault(),
          };
        } else {
          params[cPullOption] = {
            cPrivateKey: _privateKeyController.getTextOrDefault(),
          };
        }
      }

      if (type != Type.single) {
        params[cBranch] = _branchController.getTextOrDefault();
        params[cWhite] = _whiteListController.getTextOrDefault();
        params[cBlack] = _blackListController.getTextOrDefault();
        params[cDep] = _depController.getTextOrDefault();
        params[cSuffix] = _suffixController.getTextOrDefault();
        params[cBefore] = _taskBeforeController.getTextOrDefault();
        params[cAfter] = _taskAfterController.getTextOrDefault();
      }

      params[cAlias] = getAlias(_linkController.text,
          _branchController.getTextOrDefault(), type.name);
      await EasyLoading.show(status: " 提交中");
      var response = params.containsKey("id")
          ? await SingleAccountPageState.ofApi(context).updateSubscribes(params)
          : await SingleAccountPageState.ofApi(context).addSubscribes(params);
      await EasyLoading.dismiss();
      if (response.success) {
        "提交成功".toast();
        Navigator.of(context).pop(true);
      } else {
        response.message.toast();
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  Widget _buildSingle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [],
      ),
    );
  }

  Widget _buildOpenPub() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          const TitleWidget(
            "分支",
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _branchController,
            decoration: const InputDecoration(
              hintText: "请输入分支",
            ),
            autofocus: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivatePub() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          const TitleWidget(
            "分支",
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _branchController,
            decoration: const InputDecoration(
              hintText: "请输入分支",
            ),
            autofocus: false,
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              const TitleWidget(
                "拉取方式",
                required: true,
              ),
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    buildRadioButton(
                      "私钥",
                      pullType == PullType.privateKey,
                      onTap: () {
                        pullType = PullType.privateKey;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    buildRadioButton(
                      "用户名密码/Token",
                      pullType == PullType.userName,
                      flex: 2,
                      onTap: () {
                        pullType = PullType.userName;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Visibility(
            visible: pullType == PullType.privateKey,
            child: const TitleWidget(
              "私钥",
              required: true,
            ),
          ),
          Visibility(
            visible: pullType == PullType.privateKey,
            child: const SizedBox(
              height: 10,
            ),
          ),
          Visibility(
            visible: pullType == PullType.privateKey,
            child: TextField(
              controller: _privateKeyController,
              decoration: const InputDecoration(
                hintText: "请输入私钥",
              ),
              autofocus: false,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: const TitleWidget(
              "用户名",
              required: true,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: const SizedBox(
              height: 10,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: TextField(
              controller: _userNameController,
              decoration: const InputDecoration(
                hintText: "请输入用户名",
              ),
              autofocus: false,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: const SizedBox(
              height: 15,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: const TitleWidget(
              "密码/Token",
              required: true,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: const SizedBox(
              height: 10,
            ),
          ),
          Visibility(
            visible: pullType == PullType.userName,
            child: TextField(
              controller: _userPasswordController,
              decoration: const InputDecoration(
                hintText: "请输入密码或者Token",
              ),
              autofocus: false,
            ),
          ),
        ],
      ),
    );
  }

  void loadData() {
    if (widget.taskBean.isEmpty) return;

    _nameController.text = widget.taskBean >>> cName;
    _linkController.text = widget.taskBean >>> cLink;
    _branchController.text = widget.taskBean >>> cBranch;
    _privateKeyController.text = widget.taskBean >>> cPrivateKey;
    _userNameController.text = widget.taskBean >>> cUserName;
    _userPasswordController.text = widget.taskBean >>> cPassword;
    _cronController.text = widget.taskBean >>> cCron;
    _intervalController.text = widget.taskBean >>> cInterval;
    _whiteListController.text = widget.taskBean >>> cWhite;
    _blackListController.text = widget.taskBean >>> cBlack;
    _depController.text = widget.taskBean >>> cDep;
    _suffixController.text = widget.taskBean >>> cSuffix;
    _taskBeforeController.text = widget.taskBean >>> cBefore;
    _taskAfterController.text = widget.taskBean >>> cAfter;

    //解析几种type

    String tempType = widget.taskBean[cType] ?? Type.public.name;
    type = getTypeCodeByTypeName(tempType);

    if (type == Type.private) {
      String tempPullType =
          widget.taskBean[cPullType] ?? PullType.privateKey.name;
      pullType = getPullTypeCodeByPullTypeName(tempPullType);

      if (pullType == PullType.privateKey) {
        _privateKeyController.text =
            widget.taskBean[cPullOption][cPrivateKey] ?? "";
      } else {
        _userNameController.text =
            widget.taskBean[cPullOption][cUserName] ?? "";
        _userPasswordController.text =
            widget.taskBean[cPullOption][cPassword] ?? "";
      }
    }
    String tempCronType = widget.taskBean[cCronType] ?? CronType.cron.name;
    cronType = getCronTypeCodeByPullTypeName(tempCronType);

    if (cronType == CronType.cron) {
      _cronController.text = widget.taskBean[cCron] ?? "";
    } else {
      _intervalController.text =
          widget.taskBean[cInterval]?["value"]?.toString() ?? "";
      String tempDays =
          widget.taskBean[cInterval]?["type"]?.toString() ?? "days";
      intervalUnit = getNameByCode(tempDays);
    }
  }

  Type getTypeCodeByTypeName(String name) {
    switch (name) {
      case "public-repo":
        return Type.public;
      case "private-repo":
        return Type.private;
      case "file":
        return Type.single;
    }
    return Type.public;
  }

  PullType getPullTypeCodeByPullTypeName(String name) {
    switch (name) {
      case "ssh-key":
        return PullType.privateKey;
      case "user-pwd":
        return PullType.userName;
    }
    return PullType.privateKey;
  }

  CronType getCronTypeCodeByPullTypeName(String name) {
    switch (name) {
      case "crontab":
        return CronType.cron;
      case "interval":
        return CronType.interval;
    }
    return CronType.cron;
  }

  String getCodeByName(String name) {
    switch (name) {
      case "天":
        return "days";
      case "时":
        return "hours";
      case "分":
        return "minutes";
      case "秒":
        return "seconds";
      default:
        return "says";
    }
  }

  String getNameByCode(String code) {
    switch (code) {
      case "days":
        return "天";
      case "hours":
        return "时";
      case "minutes":
        return "分";
      case "seconds":
        return "秒";
      default:
        return "天";
    }
  }

  String getAlias(String url, String? branch, String type) {
    var repoUrlRegx = RegExp(r'[^\/\:]+\/[^\/]+(?=\.git)');
    var fileUrlRegx = RegExp(r'[^\/\:]+\/[^\/]+$');
    String _alias = "";
    var _regx = type == 'file' ? fileUrlRegx : repoUrlRegx;
    if (_regx.hasMatch(url)) {
      _alias = _regx
              .firstMatch(url)
              ?.group(0)
              ?.replaceAll('/', '_')
              .replaceAll('.', '_') ??
          "";
    }
    if (branch != null) {
      _alias = _alias + '_' + branch;
    }
    return _alias;
  }
}

class TitleWidget extends ConsumerWidget {
  final String title;
  final bool required;

  const TitleWidget(
    this.title, {
    Key? key,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return RichText(
      text: TextSpan(
        text: !required ? "" : "* ",
        style: const TextStyle(
          color: Color(0xFFF02D2D),
        ),
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 14,
              color: ref.watch(themeProvider).themeColor.titleColor(),
            ),
          ),
        ],
      ),
    );
  }
}

extension TextEditingControllerExtension on TextEditingController {
  String? getTextOrDefault({String? defaultValue}) {
    return text.isEmpty ? defaultValue : text;
  }
}

extension TypeExtension on Type {
  String get name {
    switch (this) {
      case Type.public:
        return 'public-repo';
      case Type.private:
        return 'private-repo';
      case Type.single:
        return 'file';
    }
  }
}

extension PullTypeExtension on PullType {
  String get name {
    switch (this) {
      case PullType.userName:
        return 'user-pwd';
      case PullType.privateKey:
        return 'ssh-key';
    }
  }
}

extension CronTypeExtension on CronType {
  String get name {
    switch (this) {
      case CronType.cron:
        return 'crontab';
      case CronType.interval:
        return 'interval';
    }
  }
}
