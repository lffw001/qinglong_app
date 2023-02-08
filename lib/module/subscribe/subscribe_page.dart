import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/enable_widget.dart';
import 'package:qinglong_app/base/ui/running_widget.dart';
import 'package:qinglong_app/base/ui/search_cell.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/module/task/intime_log/intime_subscribe_log_page.dart';
import 'package:qinglong_app/module/task/task_viewmodel.dart';
import 'package:qinglong_app/utils/utils.dart';

import 'subscribe_viewmodel.dart';

class SubscribePage extends ConsumerStatefulWidget {
  const SubscribePage({Key? key}) : super(key: key);

  @override
  _SubscribePageState createState() => _SubscribePageState();
}

class _SubscribePageState extends ConsumerState<SubscribePage> {
  TextEditingController searchText = TextEditingController();

  String currentState = TaskViewModel.allStr;
  ScrollController controller = ScrollController();

  bool buttonshow = false;

  void scrollToTop() {
    controller.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(floatingButtonVisibility);
    searchText.addListener(() {
      setState(() {});
    });
  }

  void floatingButtonVisibility() {
    double y = controller.offset;
    if (y > MediaQuery.of(context).size.height / 2) {
      if (buttonshow == true) return;
      setState(() {
        buttonshow = true;
      });
    } else {
      if (buttonshow == false) return;
      setState(() {
        buttonshow = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: buttonshow,
        child: FloatingActionButton(
          mini: true,
          onPressed: () {
            scrollToTop();
          },
          elevation: 2,
          backgroundColor: Colors.white,
          child: const Icon(CupertinoIcons.up_arrow),
        ),
      ),
      appBar: QlAppBar(
        title: "订阅管理",
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                CupertinoPageRoute(
                  builder: (context) => const AddSubscribePage(
                    taskBean: {},
                  ),
                ),
              )
                  .then(
                (value) {
                  if (value != null && value == true) {
                    ref
                        .read(
                          SingleAccountPageState.ofSubscribeProvider(context)(
                            getProviderName(context),
                          ),
                        )
                        .loadData(context);
                  }
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BaseStateWidget<SubscribeViewModel>(
        builder: (ref, model, child) {
          return body(model, getListByType(model), ref);
        },
        model: SingleAccountPageState.ofSubscribeProvider(context)(getProviderName(context)),
        lazyLoad: true,
        onReady: (viewModel) {
          viewModel.loadData(context);
        },
      ),
    );
  }

  Widget body(SubscribeViewModel model, List<Map<String, dynamic>> list, WidgetRef ref) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: () async {
        return model.loadData(context, false);
      },
      child: IconTheme(
        data: const IconThemeData(
          size: 25,
        ),
        child: SlidableAutoCloseBehavior(
          child: ListView.separated(
            padding: const EdgeInsets.only(
              bottom: 80,
            ),
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemBuilder: (context, index) {
              if (index == 0) {
                return searchCell(ref);
              }
              Map<String, dynamic> item = list[index - 1];
              if (searchText.text.isEmpty ||
                  (item["name"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false) ||
                  (item["url"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false)) {
                return TaskItemCell(item, ref);
              } else {
                return const SizedBox.shrink();
              }
            },
            itemCount: list.length + 1,
            separatorBuilder: (BuildContext context, int index) {
              if (index == 0) return const SizedBox.shrink();
              Map<String, dynamic> item = list[index - 1];
              if (searchText.text.isEmpty ||
                  (item["name"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false) ||
                  (item["url"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false)) {
                return Container(
                  color: ref.watch(themeProvider).themeColor.settingBgColor(),
                  child: const Divider(
                    height: 1,
                    indent: 15,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget searchCell(WidgetRef context) {
    return Container(
      color: ref.watch(themeProvider).themeColor.searchBgColor(),
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: SearchCell(
          controller: searchText,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> getListByType(SubscribeViewModel model) {
    return model.list.where((item) {
      if (searchText.text.isEmpty ||
          (item["name"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false) ||
          (item["url"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false)) {
        return true;
      } else {
        return false;
      }
    }).toList();
  }
}

class TaskItemCell extends StatelessWidget {
  final Map<String, dynamic> bean;
  final WidgetRef ref;

  const TaskItemCell(this.bean, this.ref, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ref.watch(themeProvider).themeColor.settingBgColor(),
      child: Slidable(
        key: ValueKey(bean["id"] as int),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.6,
          children: [
            SlidableAction(
              backgroundColor: const Color(0xff5D5E70),
              onPressed: (_) {
                Navigator.of(context)
                    .push(
                  CupertinoPageRoute(
                    builder: (context) => AddSubscribePage(
                      taskBean: bean,
                    ),
                  ),
                )
                    .then(
                  (value) {
                    if (value != null && value == true) {
                      ref
                          .read(
                            SingleAccountPageState.ofSubscribeProvider(context)(
                              getProviderName(context),
                            ),
                          )
                          .loadData(context);
                    }
                  },
                );
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.pencil_outline,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffA356D6),
              onPressed: (_) {
                WidgetsBinding.instance.endOfFrame.then((value) {
                  _enableSubscribe(context, bean["is_disabled"] ?? 0);
                });
              },
              foregroundColor: Colors.white,
              icon: (bean["is_disabled"] ?? 0) != 1 ? Icons.dnd_forwardslash : Icons.check_circle_outline_sharp,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffEA4D3E),
              onPressed: (_) {
                WidgetsBinding.instance.endOfFrame.then((value) {
                  _delSubscribe(context, ref);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              backgroundColor: const Color(0xffD25535),
              onPressed: (_) {
                if (bean["status"] == 1) {
                  _startCron(
                    context,
                    ref,
                    true,
                  );
                } else {
                  _stopCron(
                    context,
                    ref,
                  );
                }
              },
              foregroundColor: Colors.white,
              icon: bean["status"]! == 1 ? CupertinoIcons.memories : CupertinoIcons.stop_circle,
            ),
            SlidableAction(
              backgroundColor: const Color(0xff606467),
              onPressed: (_) {
                Future.delayed(
                    const Duration(
                      milliseconds: 250,
                    ), () {
                  logCron(context, ref);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.text_justifyleft,
            ),
          ],
        ),
        child: Material(
          color: ref.watch(themeProvider).themeColor.settingBgColor(),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.routeSubscribeDetail, arguments: bean);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(
                                Size.fromWidth(
                                  MediaQuery.of(context).size.width / 2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  bean["name"] ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: ref.watch(themeProvider).themeColor.titleColor(),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            bean["status"] == 0 ? const RunningWidget() : const SizedBox.shrink(),
                            const SizedBox(
                              width: 7,
                            ),
                            (bean["is_disabled"] ?? 0) == 1 ? const StatusWidget(title: "已禁用", color: Color(0xffFB5858)) : const SizedBox.shrink()
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          "",
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: ref.watch(themeProvider).themeColor.descColor(),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      bean["schedule"] ?? "",
                      maxLines: 1,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: ref.watch(themeProvider).themeColor.descColor(),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      bean["url"] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: ref.watch(themeProvider).themeColor.descColor(),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _startCron(BuildContext context, WidgetRef ref, bool showLog) async {
    await ref
        .read(
          SingleAccountPageState.ofSubscribeProvider(context)(
            getProviderName(context),
          ),
        )
        .runCrons(
          context,
          bean["id"],
        );
    if (showLog) {
      Future.delayed(const Duration(milliseconds: 250), () {
        logCron(context, ref);
      });
    }
  }

  _stopCron(BuildContext context, WidgetRef ref) {
    ref
        .read(
          SingleAccountPageState.ofSubscribeProvider(context)(
            getProviderName(context),
          ),
        )
        .stopCrons(
          context,
          bean["id"],
        );
  }

  logCron(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => InTimeSubscribeLogPage(
          bean["id"],
          true,
          bean["name"] ?? "",
        ),
      ),
    );
  }

  void _delSubscribe(BuildContext context1, WidgetRef ref) {
    showCupertinoDialog(
      context: context1,
      useRootNavigator: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除订阅 ${bean["name"] ?? ""} 吗"),
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
              ref
                  .read(
                    SingleAccountPageState.ofSubscribeProvider(context1)(
                      getProviderName(context1),
                    ),
                  )
                  .delSubscribe(
                    context1,
                    bean["id"],
                  );
            },
          ),
        ],
      ),
    );
  }

  void _enableSubscribe(BuildContext context, int disabled) {
    ref
        .read(
          SingleAccountPageState.ofSubscribeProvider(context)(
            getProviderName(context),
          ),
        )
        .enableSubscribe(
          context,
          bean["id"],
          disabled,
        );
  }
}
