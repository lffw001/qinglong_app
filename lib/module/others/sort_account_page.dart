import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/multi_account_userinfo_viewmodel.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

import '../../base/commit_button.dart';
import '../../main.dart';

class SortAccountPage extends ConsumerStatefulWidget {
  const SortAccountPage({Key? key}) : super(key: key);

  @override
  _ChangeAccountPageState createState() => _ChangeAccountPageState();
}

class _ChangeAccountPageState extends ConsumerState<SortAccountPage> {
  List<TokenBean> list = [];

  @override
  void initState() {
    try {
      String json = jsonEncode(getIt<MultiAccountUserInfoViewModel>().tokenBeans);
      list.addAll((jsonDecode(json) as List).map((e) => TokenBean.fromJson(e)).toList());
    } catch (e) {}

    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "账号排序",
        actions: [
          CommitButton(
            title: "保存",
            onTap: () {
              getIt<MultiAccountUserInfoViewModel>().resetTokenBeans(list);
              showCupertinoDialog(
                useRootNavigator: false,
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text("保存成功"),
                  content: const Text("重启APP后,新的顺序开始生效"),
                  actions: [
                    CupertinoDialogAction(
                      child: Text(
                        "知道了",
                        style: TextStyle(
                          color: ref.watch(themeProvider).primaryColor,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: 30,
          top: 10,
        ),
        child: ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (int oldIndex, int newIndex) {
            setState(
              () {
                //交换数据
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final TokenBean item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
              },
            );
          },
          children: list
              .map((e) => ClipRRect(
                    key: ValueKey(e.host),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: ref.watch(themeProvider).themeColor.settingBordorColor(),
                      child: buildCell(e),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget buildCell(TokenBean model) {
    Widget child = ListTile(
      title: Text(
        model.host ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        model.alias ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      minVerticalPadding: 10,
      trailing: (model.token != null && model.token!.isNotEmpty)
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: ref.watch(themeProvider).primaryColor, width: 1),
              ),
              child: Text(
                "已登录",
                style: TextStyle(color: ref.watch(themeProvider).primaryColor, fontSize: 12),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: const Color(0xffFB5858), width: 1),
              ),
              child: const Text(
                "未登录",
                style: TextStyle(color: Color(0xffFB5858), fontSize: 12),
              ),
            ),
    );
    if (model.host == null || model.host!.isEmpty) {
      return child;
    }

    return child;
  }

  Widget addAccount(BuildContext context, int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.findAncestorStateOfType<MultiAccountPageState>()?.updateIndex(index);
        Navigator.of(
          context,
        ).pop();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          decoration: BoxDecoration(
            color: ref.watch(themeProvider).themeColor.settingBordorColor(),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                  ),
                ),
                child: Icon(
                  CupertinoIcons.add,
                  color: ref.watch(themeProvider).themeColor.descColor(),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                "添加账号",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
