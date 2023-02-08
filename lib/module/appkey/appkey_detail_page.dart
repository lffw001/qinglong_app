import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';

import 'appkey_page.dart';
import 'appkey_viewmodel.dart';

class AppKeyDetailDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> bean;

  const AppKeyDetailDetailPage(
    this.bean, {
    Key? key,
  }) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<AppKeyDetailDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: widget.bean["name"] ?? "",
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppKeyDetailCell(
              title: 'Client ID	',
              desc: widget.bean >> "client_id",
            ),
            const SizedBox(
              height: 5,
            ),
            AppKeyDetailCell(
              title: 'Client Secret	',
              obtext: true,
              desc: widget.bean >> "client_secret",
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                right: 10,
                bottom: 10,
              ),
              child: Text(
                "权限",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Material(
              color: Colors.transparent,
              child: Wrap(
                runSpacing: 5,
                spacing: 5,
                children: AppKeyViewModel.getScopeNames(
                        (widget.bean["scopes"] as List<dynamic>?))
                    .map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                ref.watch(themeProvider).themeColor.descColor(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            e,
                            maxLines: 1,
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: ref
                                  .watch(themeProvider)
                                  .themeColor
                                  .blackAndWhite(),
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 80,
                child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    alignment: Alignment.center,
                    color: Colors.red,
                    child: const Text(
                      "删 除",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      _del(context, ref);
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _del(BuildContext context1, WidgetRef ref) {
    showCupertinoDialog(
      context: context1,
      useRootNavigator: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除应用 ${widget.bean["name"] ?? ""} 吗"),
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
            onPressed: () {
              Navigator.of(context).pop();
              EasyLoading.show(status: "删除中");
              ref
                  .read(
                    SingleAccountPageState.ofAppKeyProvider(context1)(
                      getProviderName(context1),
                    ),
                  )
                  .delAppKey(
                    context1,
                    getAppKeyId(widget.bean),
                  )
                  .then((value) {
                EasyLoading.dismiss();
                Navigator.of(context1).pop(true);
              }).catchError((_, __) {
                EasyLoading.dismiss();
              });
            },
          ),
        ],
      ),
    );
  }
}

class AppKeyDetailCell extends ConsumerWidget {
  final String title;
  final String? desc;
  final Widget? icon;
  final bool hideDivide;
  final bool obtext;

  const AppKeyDetailCell({
    Key? key,
    required this.title,
    this.desc,
    this.icon,
    this.hideDivide = false,
    this.obtext = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            right: 10,
            bottom: 10,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              desc != null
                  ? Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: desc,
                            ),
                          );
                          "已复制到剪切板".toast();
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            obtext ? "*******" : desc!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: ref
                                  .watch(themeProvider)
                                  .themeColor
                                  .descColor(),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child:
                          Align(alignment: Alignment.centerRight, child: icon!),
                    ),
            ],
          ),
        ),
        hideDivide
            ? const SizedBox.shrink()
            : const Divider(
                height: 1,
              ),
      ],
    );
  }
}

extension DynamicEmptyHandle on Map<String, dynamic> {
  String operator >>(Object? key) {
    if (containsKey(key)) {
      dynamic value = this[key];
      if (value != null) {
        if (value is String) {
          if (value.isNotEmpty) {
            return value;
          }
        } else {
          return value.toString();
        }
      }
    }
    return "- -";
  }

  String operator >>>(Object? key) {
    if (containsKey(key)) {
      dynamic value = this[key];
      if (value != null) {
        if (value is String) {
          if (value.isNotEmpty) {
            return value;
          }
        } else {
          return value.toString();
        }
      }
    }
    return "";
  }
}
