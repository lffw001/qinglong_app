import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:qinglong_app/base/cupertino_sheet.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/module/task/add_task_page.dart';
import 'package:qinglong_app/module/task/intime_log/intime_log_page.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/utils.dart';
import 'package:timezone/standalone.dart';

import '../../../base/cron_parse.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final TaskBean taskBean;
  final bool hideAppbar;

  const TaskDetailPage(this.taskBean, {Key? key, this.hideAppbar = false}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> with LazyLoadState<TaskDetailPage> {
  bool isPin = false;
  bool isLoading = true;

  var nextRunTime = "".obs;

  void getNextRunTime(String time) {
    if (time.isEmpty) return;
    try {
      String cronTime;
      List<dynamic> timeList = time.split(" ");
      Duration duration;
      if (timeList.length > 5) {
        var first = timeList.first;
        var second = parseConstraint(first)?.first ?? 0;
        duration = Duration(seconds: second);

        cronTime = timeList.sublist(1, timeList.length).join(" ");
      } else {
        cronTime = time;
        duration = const Duration(seconds: 0);
      }

      var cronIterator = Cron().parse(cronTime, "Asia/Shanghai");
      TZDateTime nextDate = cronIterator.next();
      var result = nextDate.add(duration);
      var resultStr = Utils.formatMessageTime(result.millisecondsSinceEpoch);
      nextRunTime.value = resultStr;
    } catch (e) {
      nextRunTime.value = "- -";
    }
  }

  @override
  void initState() {
    isPin = widget.taskBean.isPinned == 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = const Center(
        child: LoadingWidget(),
      );
    } else {
      body = Material(
        color: Colors.transparent,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
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
                      TaskDetailCell(
                        title: "名称",
                        desc: widget.taskBean.name ?? "",
                      ),
                      TaskDetailCell(
                        title: "ID",
                        desc: widget.taskBean.sId ?? "",
                      ),
                      TaskDetailCell(
                        title: "任务",
                        desc: widget.taskBean.command ?? "",
                      ),
                      Visibility(
                        visible: widget.taskBean.command != null && widget.taskBean.command!.isNotEmpty && widget.taskBean.command!.startsWith("task "),
                        child: TaskDetailCell(
                          title: "脚本",
                          suffixIcon: Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: ref.watch(themeProvider).themeColor.descColor(),
                          ),
                          desc: widget.taskBean.command?.replaceAll("task ", "") ?? "-",
                          taped: () {
                            if (widget.taskBean.command == null || widget.taskBean.command!.isEmpty) return;
                            if (!(widget.taskBean.command?.startsWith("task ") ?? true)) return;

                            String path = widget.taskBean.command?.replaceAll("task ", "").trim() ?? "";

                            if (!path.contains("/")) {
                              Navigator.of(context).pushNamed(Routes.routeScriptDetail, arguments: {
                                "title": path.trim(),
                                "path": "",
                              });
                            } else {
                              List<String> paths = path.split("/");
                              if (paths.length == 2) {
                                Navigator.of(context).pushNamed(Routes.routeScriptDetail, arguments: {
                                  "title": paths[1],
                                  "path": paths[0],
                                });
                              }
                            }
                          },
                        ),
                      ),
                      TaskDetailCell(
                        title: "创建时间",
                        desc: widget.taskBean.created == null
                            ? Utils.formatTime2(widget.taskBean.createdAt)
                            : Utils.formatMessageTime(widget.taskBean.created ?? 0),
                      ),
                      TaskDetailCell(
                        title: "更新时间",
                        desc: widget.taskBean.updatedAt == null
                            ? Utils.formatGMTTime(widget.taskBean.timestamp ?? "")
                            : Utils.formatTime2(widget.taskBean.updatedAt),
                      ),
                      TaskDetailCell(
                        title: "任务定时",
                        desc: widget.taskBean.schedule ?? "",
                      ),
                      Obx(() {
                        return TaskDetailCell(
                          title: "下次运行时间",
                          desc: nextRunTime.value,
                        );
                      }),
                      TaskDetailCell(
                        title: "最后运行时间",
                        desc: Utils.formatMessageTime(widget.taskBean.lastExecutionTime ?? 0),
                      ),
                      TaskDetailCell(
                        title: "最后运行时长",
                        desc: widget.taskBean.lastRunningTime == null ? "-" : "${widget.taskBean.lastRunningTime ?? "-"}秒",
                      ),
                      TaskDetailCell(
                        title: "最新日志",
                        desc: widget.taskBean.logPath ?? "-",
                        suffixIcon: Icon(
                          CupertinoIcons.right_chevron,
                          size: 16,
                          color: ref.watch(themeProvider).themeColor.descColor(),
                        ),
                        taped: () {
                          showLog();
                        },
                      ),
                      Visibility(
                        visible: widget.taskBean.command != null && widget.taskBean.command!.isNotEmpty && widget.taskBean.command!.startsWith("task "),
                        child: TaskDetailCell(
                          title: "日志历史",
                          suffixIcon: Icon(
                            CupertinoIcons.right_chevron,
                            size: 16,
                            color: ref.watch(themeProvider).themeColor.descColor(),
                          ),
                          desc: widget.taskBean.command?.replaceAll("task ", "").replaceAll("/", "_").split(".")[0] ?? "-",
                          taped: () {
                            Navigator.of(context).pushNamed(
                              Routes.routeTaskLog,
                              arguments: {"search": widget.taskBean.command?.replaceAll("task ", "").replaceAll("/", "_").split(".")[0] ?? ""},
                            );
                          },
                        ),
                      ),
                      TaskDetailCell(
                        title: "运行状态",
                        desc: widget.taskBean.status == 0 ? "正在运行" : "空闲",
                      ),
                      TaskDetailCell(
                        title: "脚本状态",
                        desc: widget.taskBean.isDisabled == 1 ? "已禁用" : "已启用",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              "是否置顶",
                              style: TextStyle(
                                color: ref.watch(themeProvider).themeColor.titleColor(),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            const Spacer(),
                            CupertinoSwitch(
                                value: isPin,
                                onChanged: (v) {
                                  pinTask(v);
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                widget.hideAppbar
                    ? const SizedBox.shrink()
                    : SizedBox(
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
        ),
      );
    }

    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: widget.taskBean.name ?? "",
        actions: [
          CupertinoButton(
            color: Colors.transparent,
            padding: EdgeInsets.zero,
            onPressed: () {
              showMoreOperate(
                context,
                [
                  CupertinoSheer(
                    title: widget.taskBean.status! == 1 ? "运行" : "停止运行",
                    onTap: () async {
                      if (widget.taskBean.status! == 1) {
                        await startCron(context, ref);
                      } else {
                        await stopCron(context, ref);
                      }
                    },
                  ),
                  addDivider(),
                  CupertinoSheer(
                    title: "编辑",
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => AddTaskPage(
                            taskBean: widget.taskBean,
                            hideUploadFile: true,
                          ),
                        ),
                      );
                    },
                  ),
                  addDivider(),
                  CupertinoSheer(
                    title: widget.taskBean.isDisabled! == 0 ? "禁用" : "启用",
                    onTap: () {
                      enableTask();
                    },
                  ),
                ],
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Icon(
                  Icons.more_horiz,
                  size: 26,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
              ),
            ),
          )
        ],
      ),
      body: body,
    );
  }

  startCron(BuildContext context, WidgetRef ref) async {
    await ref.read(SingleAccountPageState.ofTaskProvider(context)(getProviderName(context)).notifier).runCrons(context, [widget.taskBean.sId!]);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showLog();
    });
  }

  stopCron(BuildContext context, WidgetRef ref) async {
    await ref.read(SingleAccountPageState.ofTaskProvider(context)(getProviderName(context)).notifier).stopCrons(context, [widget.taskBean.sId!]);
    setState(() {});
  }

  void enableTask() async {
    await ref
        .read(SingleAccountPageState.ofTaskProvider(context)(getProviderName(context)))
        .enableTask(context, [widget.taskBean.sId!], widget.taskBean.isDisabled!);
    setState(() {});
  }

  void pinTask(bool v) async {
    await ref.read(SingleAccountPageState.ofTaskProvider(context)(getProviderName(context)).notifier).pinTask(
          context,
          [widget.taskBean.sId!],
          //这里取反
          v ? 0 : 1,
        );
    isPin = !isPin;
    setState(() {});
  }

  void delTask(BuildContext context1, WidgetRef ref) {
    showCupertinoDialog(
      useRootNavigator: false,
      context: context1,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除定时任务 ${widget.taskBean.name ?? ""} 吗"),
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
              await ref.read(SingleAccountPageState.ofTaskProvider(context1)(getProviderName(context1))).delCron(context1, [widget.taskBean.sId!]);
              Navigator.of(context1).pop();
            },
          ),
        ],
      ),
    );
  }

  void showLog() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => InTimeLogPage(
          widget.taskBean.sId!,
          true,
          widget.taskBean.name ?? "",
          command: widget.taskBean.command,
        ),
      ),
    );
  }

  @override
  void onLazyLoad() {
    isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getNextRunTime(widget.taskBean.schedule ?? "");
    });
    setState(() {});
  }
}

class TaskDetailCell extends ConsumerWidget {
  final String title;
  final String? desc;
  final Widget? icon;
  final Widget? suffixIcon;
  final bool hideDivide;
  final Function? taped;

  const TaskDetailCell({
    Key? key,
    required this.title,
    this.desc,
    this.icon,
    this.suffixIcon,
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
                        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
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
                            color: ref.watch(themeProvider).themeColor.descColor(),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Align(alignment: Alignment.centerRight, child: icon!),
                    ),
              suffixIcon == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                      ),
                      child: suffixIcon!,
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
