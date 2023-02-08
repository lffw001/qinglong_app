import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../base/commit_button.dart';

class PushSettingPage extends ConsumerStatefulWidget {
  const PushSettingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PushSettingPage> createState() => _PushSettingPageState();
}

class _PushSettingPageState extends ConsumerState<PushSettingPage> {
  List<PushBean> list = [];

  PushBean? current;
  bool loading = true;

  @override
  void initState() {
    initData();
    super.initState();
    onLazyLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "通知设置",
        actions: [
          CommitButton(
            onTap: () {
              commit();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "通知设置",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<PushBean>(
                        items: list
                            .map<DropdownMenuItem<PushBean>>(
                                (e) => DropdownMenuItem<PushBean>(
                                      value: e,
                                      child: Text(getNameByKey(e.name)),
                                    ))
                            .toList(),
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              ref.watch(themeProvider).themeColor.title2Color(),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                        ),
                        icon: const Icon(
                          CupertinoIcons.chevron_up_chevron_down,
                          size: 16,
                        ),
                        value: current,
                        onChanged: (value) {
                          current = value!;
                          setState(() {});
                        },
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: current?.children
                                .map(
                                  (e) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      TitleWidget(
                                        e.key,
                                        required: e.required,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      TextField(
                                        controller: e.controller,
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        decoration: InputDecoration(
                                          hintText: "请输入${e.key}",
                                        ),
                                        autofocus: false,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        e.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .descColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList() ??
                            [],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void initData() {
    var pushSetting = {
      "gotify": [
        {
          "label": 'gotifyUrl',
          "tip": 'gotify的url地址,例如 https://push.example.de:8080',
          "required": true,
        },
        {"label": 'gotifyToken', "tip": 'gotify的消息应用token码', "required": true},
        {"label": 'gotifyPriority', "tip": '推送消息的优先级'},
      ],
      "goCqHttpBot": [
        {
          "label": 'goCqHttpBotUrl',
          "tip":
              '推送到个人QQ: http://127.0.0.1/send_private_msg，群：http://127.0.0.1/send_group_msg',
          "required": true,
        },
        {"label": 'goCqHttpBotToken', "tip": '访问密钥', "required": true},
        {
          "label": 'goCqHttpBotQq',
          "tip":
              '如果GOBOT_URL设置 /send_private_msg 则需要填入 user_id=个人QQ 相反如果是 /send_group_msg 则需要填入 group_id=QQ群',
          "required": true,
        },
      ],
      "serverChan": [
        {"label": 'serverChanKey', "tip": 'Server酱SENDKEY', "required": true},
      ],
      "pushDeer": [
        {
          "label": 'pushDeerKey',
          "tip": 'PushDeer的Key，https://github.com/easychen/pushdeer',
          "required": true,
        },
      ],
      "bark": [
        {
          "label": 'barkPush',
          "tip": 'Bark的信息IP/设备码，例如：https://api.day.app/XXXXXXXX',
          "required": true,
        },
        {
          "label": 'barkIcon',
          "tip": 'BARK推送图标,自定义推送图标 (需iOS15或以上才能显示)',
        },
        {"label": 'barkSound', "tip": 'BARK推送铃声,铃声列表去APP查看复制填写'},
        {"label": 'barkGroup', "tip": 'BARK推送消息的分组, 默认为qinglong'},
      ],
      "telegramBot": [
        {
          "label": 'telegramBotToken',
          "tip":
              'telegram机器人的token，例如：1077xxx4424:AAFjv0FcqxxxxxxgEMGfi22B4yh15R5uw',
          "required": true,
        },
        {
          "label": 'telegramBotUserId',
          "tip": 'telegram用户的id，例如：129xxx206',
          "required": true,
        },
        {"label": 'telegramBotProxyHost', "tip": '代理IP'},
        {"label": 'telegramBotProxyPort', "tip": '代理端口'},
        {
          "label": 'telegramBotProxyAuth',
          "tip": 'telegram代理配置认证参数, 用户名与密码用英文冒号连接 user:password',
        },
        {
          "label": 'telegramBotApiHost',
          "tip": 'telegram api自建的反向代理地址，默认tg官方api',
        },
      ],
      "dingtalkBot": [
        {
          "label": 'dingtalkBotToken',
          "tip":
              '钉钉机器人webhook token，例如：5a544165465465645d0f31dca676e7bd07415asdasd',
          "required": true,
        },
        {
          "label": 'dingtalkBotSecret',
          "tip": '密钥，机器人安全设置页面，加签一栏下面显示的SEC开头的字符串',
        },
      ],
      "weWorkBot": [
        {
          "label": 'weWorkBotKey',
          "tip":
              '企业微信机器人的 webhook(详见文档 https://work.weixin.qq.com/api/doc/90000/90136/91770)，例如：693a91f6-7xxx-4bc4-97a0-0ec2sifa5aaa',
          "required": true,
        },
      ],
      "weWorkApp": [
        {
          "label": 'weWorkAppKey',
          "tip":
              'corpid,corpsecret,touser(注:多个成员ID使用|隔开),agentid,消息类型(选填,不填默认文本消息类型) 注意用,号隔开(英文输入法的逗号)，例如：wwcfrs,B-76WERQ,qinglong,1000001,2COat',
          "required": true,
        },
      ],
      "iGot": [
        {
          "label": 'iGotPushKey',
          "tip": 'iGot的信息推送key，例如：https://push.hellyw.com/XXXXXXXX',
          "required": true,
        },
      ],
      "pushPlus": [
        {
          "label": 'pushPlusToken',
          "tip":
              '微信扫码登录后一对一推送或一对多推送下面的token(您的Token)，不提供PUSH_PLUS_USER则默认为一对一推送',
          "required": true,
        },
        {
          "label": 'pushPlusUser',
          "tip":
              '一对多推送的“群组编码”（一对多推送下面->您的群组(如无则新建)->群组编码，如果您是创建群组人。也需点击“查看二维码”扫描绑定，否则不能接受群组消息推送）',
        },
      ],
      "chat": [
        {
          "label": 'chatUrl',
          "tip": 'chat的url地址',
          "required": true,
        },
        {
          "label": 'chatToken',
          "tip": 'chat的token码',
          "required": true,
        },
      ],
      "email": [
        {
          "label": 'emailService',
          "tip":
              '邮箱服务名称，比如126、163、Gmail、QQ等，支持列表https://nodemailer.com/smtp/well-known/',
          "required": true,
        },
        {"label": 'emailUser', "tip": '邮箱地址', "required": true},
        {"label": 'emailPass', "tip": '邮箱SMTP授权码', "required": true},
      ],
      "已关闭": [],
    };

    for (var entry in pushSetting.entries) {
      list.add(PushBean(
          entry.key,
          entry.key,
          entry.value
              .map((e) => PushChildBean(e["label"].toString(),
                  e["tip"].toString(), (e["required"] ?? false) as bool))
              .toList()));
    }
  }

  void onLazyLoad() async {
    var response = await SingleAccountPageState.ofApi(context).getNotifcation();

    if (response.success) {
      String result = response.bean ?? "{}";
      Map<String, dynamic> json = jsonDecode(result);

      if (json.isEmpty) {
        current = list.last;
        setState(() {
          loading = false;
        });
        return;
      }
      String? type = json["type"];
      if (type == null || type.isEmpty) {
        current = list.last;
        setState(() {
          loading = false;
        });
        return;
      }

      int index = list.indexWhere((element) => element.key == type);
      if (index < 0) {
        setState(() {
          loading = false;
        });
        return;
      }

      for (var element in list[index].children) {
        element.controller.text = json[element.key]?.toString() ?? "";
      }
      current = list[index];
      setState(() {
        loading = false;
      });
    }
  }

  void commit() async {
    if (current == null || current!.key == "已关闭") {
      EasyLoading.show(status: "提交中");

      var response =
          await SingleAccountPageState.ofApi(context).updateNotifcation({});
      EasyLoading.dismiss();
      if (response.success) {
        "设置成功".toast();
        Navigator.of(context).pop();
      } else {
        response.message.toast();
      }
      return;
    }
    int? index = current?.children.indexWhere((element) =>
        element.controller.text.isEmpty && element.required == true);
    index ??= -1;
    if (index >= 0) {
      ("${current?.children[index].key}为必填项").toast();
      return;
    }

    EasyLoading.show(status: "提交中");

    Map<String, dynamic> params = {};

    params["type"] = current!.key.toString();
    params.addAll(current!.children2Json());
    var response =
        await SingleAccountPageState.ofApi(context).updateNotifcation(params);
    EasyLoading.dismiss();
    if (response.success) {
      "设置成功".toast();
      Navigator.of(context).pop();
    } else {
      response.message.toast();
    }
  }
}

class PushBean {
  String key;
  String name;
  List<PushChildBean> children;

  PushBean(this.key, this.name, this.children);

  Map<String, dynamic> children2Json() {
    Map<String, dynamic> data = {};

    for (var e in children) {
      data[e.key] =
          e.controller.text.isEmpty ? '' : e.controller.text.toString();
    }
    return data;
  }
}

class PushChildBean {
  String key;
  String name;
  bool required;
  TextEditingController controller = TextEditingController();

  PushChildBean(this.key, this.name, this.required);
}

String getNameByKey(String key) {
  if (key == "gotify") {
    return "gotify";
  } else if (key == "goCqHttpBot") {
    return "goCqHttpBot";
  } else if (key == "serverChan") {
    return "server酱";
  } else if (key == "pushDeer") {
    return "PushDeer";
  } else if (key == "bark") {
    return "Bark";
  } else if (key == "telegramBot") {
    return "Telegram机器人";
  } else if (key == "dingtalkBot") {
    return "钉钉机器人";
  } else if (key == "weWorkBot") {
    return "企业微信机器人";
  } else if (key == "weWorkApp") {
    return "企业微信应用";
  } else if (key == "iGot") {
    return "IGot";
  } else if (key == "pushPlus") {
    return "PushPlus";
  } else if (key == "chat") {
    return "群晖chat";
  } else if (key == "email") {
    return "邮箱";
  }

  return "已关闭";
}
