import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/utils/utils.dart';

class EnvDetailPage extends ConsumerStatefulWidget {
  final EnvBean envBean;

  const EnvDetailPage(this.envBean, {Key? key}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<EnvDetailPage> {
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
        title: widget.envBean.name ?? "",
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 15,
                bottom: 15,
              ),
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EnvDetailCell(
                    title: "ID",
                    desc: widget.envBean.sId ?? "",
                  ),
                  EnvDetailCell(
                    title: "变量名称",
                    desc: widget.envBean.name ?? "",
                  ),
                  EnvDetailCell(
                    title: "创建时间",
                    desc: widget.envBean.created == null
                        ? Utils.formatTime2(widget.envBean.createdAt)
                        : Utils.formatMessageTime(widget.envBean.created ?? 0),
                  ),
                  EnvDetailCell(
                    title: "更新时间",
                    desc: widget.envBean.updatedAt == null
                        ? Utils.formatGMTTime(widget.envBean.timestamp ?? "")
                        : Utils.formatTime2(widget.envBean.updatedAt),
                  ),
                  EnvDetailCell(
                    title: "值",
                    desc: widget.envBean.value ?? "",
                  ),
                  EnvDetailCell(
                    title: "备注",
                    desc: widget.envBean.remarks ?? "",
                  ),
                  EnvDetailCell(
                    title: "变量状态",
                    desc: widget.envBean.status == 1 ? "已禁用" : "已启用",
                    hideDivide: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 80,
              child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  color: Colors.red,
                  child: const Text(
                    "删 除",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    delTask(context, ref);
                  }),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  void enableTask() async {
    await ref
        .read(SingleAccountPageState.ofEnvProvider(context)(
            getProviderName(context)))
        .enableEnv(context, [widget.envBean.sId!], widget.envBean.status!);
    setState(() {});
  }

  void delTask(BuildContext context1, WidgetRef ref) {
    showCupertinoDialog(
      useRootNavigator: false,
      context: context1,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除环境变量 ${widget.envBean.name ?? ""} 吗"),
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
              await ref
                  .read(SingleAccountPageState.ofEnvProvider(context1)(
                      getProviderName(context1)))
                  .delEnv(context1, widget.envBean.sId!);
              Navigator.of(context1).pop();
            },
          ),
        ],
      ),
    );
  }
}

class EnvDetailCell extends ConsumerWidget {
  final String title;
  final String? desc;
  final Widget? icon;
  final bool hideDivide;
  final Function? taped;

  const EnvDetailCell({
    Key? key,
    required this.title,
    this.desc,
    this.icon,
    this.hideDivide = false,
    this.taped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: desc,
        style: TextStyle(
          color: ref.watch(themeProvider).themeColor.descColor(),
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    bool left = false;
    if (textPainter.width > MediaQuery.of(context).size.width / 1.5) {
      left = true;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10,
            left: 15,
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
                      child: Align(
                        alignment:
                            left ? Alignment.centerLeft : Alignment.centerRight,
                        child: SelectableText(
                          desc!,
                          selectionHeightStyle: BoxHeightStyle.max,
                          selectionWidthStyle: BoxWidthStyle.max,
                          onTap: () {
                            if (taped != null) {
                              taped!();
                            }
                          },
                          style: TextStyle(
                            color:
                                ref.watch(themeProvider).themeColor.descColor(),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child:
                          Align(alignment: Alignment.centerRight, child: icon!),
                    ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
        ),
        hideDivide
            ? const SizedBox.shrink()
            : const Divider(
                indent: 15,
              ),
      ],
    );
  }
}
