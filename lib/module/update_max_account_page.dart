import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/multi_account_userinfo_viewmodel.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/utils/extension.dart';


class UpdateMaxAccountPage extends ConsumerStatefulWidget {
  const UpdateMaxAccountPage({Key? key}) : super(key: key);

  @override
  ConsumerState<UpdateMaxAccountPage> createState() =>
      _UpdateMaxAccountPageState();
}

class _UpdateMaxAccountPageState extends ConsumerState<UpdateMaxAccountPage> {
  int count = MultiAccountUserInfoViewModel.maxAccount;

  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: count.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: QlAppBar(
          canBack: true,
          actions: [
            CommitButton(
              onTap: () {
                commit(context);
              },
            ),
          ],
          title: "修改多账号登录最大个数",
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleWidget(
                "设置最大个数:当前($count个)",
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: "请输入你想要的个数",
                ),
                autofocus: false,
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "温馨提示:按需设置，如果你的手机性能有限，建议在系统设置中开启单实例模式",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void commit(BuildContext context) {
    if (controller.text.isEmpty) {
      "请输入数字".toast();
      return;
    }
    int? result = int.tryParse(controller.text.toString());

    if (result == null) {
      "请输入数字".toast();
      return;
    }

    if (result < 5) {
      "请输入5以上的数字".toast();
      return;
    }

    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("温馨提示"),
        content: Text("你设置了${controller.text}个最大登录数,确定吗?"),
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
              "确实",
              style: TextStyle(
                color: ref.watch(themeProvider).primaryColor,
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              MultiAccountUserInfoViewModel.updateMaxAccount(
                  int.tryParse(controller.text.toString()) ?? count);
              _restartApp(context);
            },
          ),
        ],
      ),
    );
  }

  void _restartApp(BuildContext context) {
    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("提示"),
        content: const Text("重启APP后，相关功能将会启用"),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "知道了",
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
