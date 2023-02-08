import 'dart:ui';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/enable_widget.dart';
import 'package:qinglong_app/base/ui/running_widget.dart';
import 'package:qinglong_app/base/ui/search_cell.dart';
import 'package:qinglong_app/module/others/dependencies/add_dependency_page.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_bean.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_viewmodel.dart';
import 'package:qinglong_app/module/task/intime_log/intime_dep_log_page.dart';
import 'package:qinglong_app/module/task/task_page.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';

class DependencyPage extends ConsumerStatefulWidget {
  const DependencyPage({Key? key}) : super(key: key);

  @override
  DependcyPageState createState() => DependcyPageState();
}

class DependcyPageState extends ConsumerState<DependencyPage> with TickerProviderStateMixin {
  static List<DepedencyEnum> types = [
    DepedencyEnum.NodeJS,
    DepedencyEnum.Python3,
    DepedencyEnum.Linux,
  ];
  ScrollController? controller;

  bool buttonshow = false;
  bool editMode = false;
  Set<String> checkedIds = <String>{};
  TabController? _tabController;
  TextEditingController searchText = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: types.length, vsync: this);
    searchText.addListener(() {
      setState(() {});
    });
  }

  void scrollToTop() {
    controller?.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    controller ??= ScrollController();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: buttonshow,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              scrollToTop();
            },
            elevation: 2,
            child: const Icon(CupertinoIcons.up_arrow),
          ),
        ),
        appBar: QlAppBar(
          canBack: true,
          backCall: () {
            Navigator.of(context).pop();
          },
          title: (editMode && checkedIds.isNotEmpty) ? "当前选中 ${checkedIds.length} 个依赖" : "依赖管理",
          canClick2Vip: !editMode,
          actions: [
            CupertinoButton(
              color: Colors.transparent,
              padding: EdgeInsets.zero,
              onPressed: () {
                checkedIds.clear();
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  if (editMode) {
                    showOverlay(context);
                  } else {
                    removeOverlay();
                  }
                });
                editMode = !editMode;
                searchText.text = "";
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 15,
                  left: 15,
                ),
                child: Center(
                  child: Text(
                    editMode ? "完成" : "编辑",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).appBarTheme.iconTheme?.color,
                    ),
                  ),
                ),
              ),
            ),
            CupertinoButton(
              color: Colors.transparent,
              padding: EdgeInsets.zero,
              onPressed: () {
                if (editMode) {
                  if (checkedIds.length ==
                      ref
                          .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                          .getListByType(_tabController!.index)
                          .length) {
                    //全不选
                    checkedIds.clear();
                    setState(() {});
                  } else {
                    //全选
                    checkedIds.clear();
                    checkedIds.addAll(ref
                        .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                        .getListByType(_tabController!.index)
                        .map((e) => e.mustId ?? "")
                        .toList());
                    setState(() {});
                  }
                  return;
                }
                Navigator.of(context)
                    .push(
                  CupertinoPageRoute(
                    builder: (context) => const AddDependencyPage(),
                  ),
                )
                    .then(
                  (value) async {
                    if (value != null && value is Map<String, dynamic> && value.isNotEmpty) {
                      await ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier).loadData(
                            context,
                            types[0].name.toLowerCase(),
                            false,
                          );
                      await ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier).loadData(
                            context,
                            types[1].name.toLowerCase(),
                            false,
                          );
                      await ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier).loadData(
                            context,
                            types[2].name.toLowerCase(),
                            false,
                          );

                      var bean = DependencyBean.fromJson(value);
                      showLog(context, bean.name ?? "", ref, bean.sId, bean.id);
                    }
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Center(
                  child: editMode
                      ? Text(
                          checkedIds.length ==
                                  ref
                                      .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                                      .getListByType(_tabController!.index)
                                      .length
                              ? "全不选"
                              : "全选",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).appBarTheme.iconTheme?.color,
                          ),
                        )
                      : Icon(
                          CupertinoIcons.add,
                          size: 24,
                          color: Theme.of(context).appBarTheme.iconTheme?.color,
                        ),
                ),
              ),
            ),
          ],
        ),
        body: BaseStateWidget<DependencyViewModel>(
          onReady: (model) {
            model.loadData(context, types[0].name.toLowerCase());
            model.loadData(context, types[1].name.toLowerCase());
            model.loadData(context, types[2].name.toLowerCase());
          },
          lazyLoad: true,
          model: SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)),
          builder: (context1, model, child) {
            return NotificationListener<ScrollNotification>(
              onNotification: (detail) {
                if (detail is ScrollUpdateNotification && detail.depth == 2) {
                  double y = detail.metrics.pixels;
                  if (y > MediaQuery.of(context).size.height / 2) {
                    if (buttonshow != true) {
                      setState(() {
                        buttonshow = true;
                      });
                    }
                  } else {
                    if (buttonshow != false) {
                      setState(() {
                        buttonshow = false;
                      });
                    }
                  }
                }
                return true;
              },
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: controller,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    _buildAppBar(context, ref, model),
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverPersistentHeader(
                        pinned: true,
                        floating: false,
                        delegate: SliverTabBarDelegate(
                          _tabController!,
                          editMode,
                          ref,
                        ),
                      ),
                    ),
                  ];
                },
                body: SlidableAutoCloseBehavior(
                  child: RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    notificationPredicate: (_) => true,
                    onRefresh: () async {
                      return model.loadData(context, types[_tabController!.index].name);
                    },
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: types.map(
                        (e) {
                          List<DependencyBean> list;
                          if (e.index == 0) {
                            list = model.nodeJsList;
                          } else if (e.index == 1) {
                            list = model.python3List;
                          } else {
                            list = model.linuxList;
                          }

                          return DepListView(
                            list: list,
                            type: e,
                            searchText: searchText.text,
                            editMode: editMode,
                            checked: checkedIds,
                            changed: (id) {
                              if (checkedIds.contains(id)) {
                                checkedIds.remove(id);
                              } else {
                                checkedIds.add(id);
                              }
                              setState(() {});
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void showLog(BuildContext context, String title, WidgetRef ref, String? sId, int? id) {
    String v = "";
    if (sId != null) {
      v = sId;
    } else {
      v = id.toString();
    }
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => InTimeDepLogPage(v, true, title),
      ),
    )
        .then(
      (value) async {
        await ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context))).loadData(
              context,
              types[_tabController!.index].name.toLowerCase(),
            );
      },
    );
  }

  double searchCellHeight = 55;

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref, DependencyViewModel model) {
    return SliverAppBar(
      pinned: false,
      floating: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      snap: false,
      primary: false,
      toolbarHeight: searchCellHeight,
      flexibleSpace: searchCell(context, ref, model),
    );
  }

  Widget searchCell(BuildContext context, WidgetRef context1, DependencyViewModel model) {
    return Container(
      color: ref.watch(themeProvider).themeColor.searchBgColor(),
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
        bottom: 10,
      ),
      height: searchCellHeight.toDouble(),
      child: SearchCell(
        controller: searchText,
      ),
    );
  }

  OverlayEntry? _editModeOverlay;

  void showOverlay(BuildContext context) {
    removeOverlay();
    _editModeOverlay = OverlayEntry(
      builder: (BuildContext context1) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: ref.watch(themeProvider).currentTheme.bottomNavigationBarTheme.backgroundColor?.withOpacity(1),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: kBottomNavigationBarHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EditModeButton(
                      "重新安装",
                      icon: CupertinoIcons.memories,
                      onTap: () {
                        _executeCode(context, "重新安装");
                      },
                    ),
                    EditModeButton(
                      "删除",
                      icon: CupertinoIcons.delete,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _executeCode(context, "删除");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context)?.insert(_editModeOverlay!);
  }

  void _executeCode(BuildContext context1, String s) {
    if (checkedIds.isEmpty) {
      "至少选择1个依赖".toast();
      return;
    }

    showCupertinoDialog(
      context: context1,
      useRootNavigator: false,
      builder: (context2) => CupertinoAlertDialog(
        title: Text("确认$s"),
        content: Text("确认$s吗"),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "取消",
              style: TextStyle(
                color: Color(0xff999999),
              ),
            ),
            onPressed: () {
              Navigator.of(context2).pop();
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
              Navigator.of(context2).pop();
              editMode = false;
              removeOverlay();
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) {
                  if (s == "重新安装") {
                    List<String?> sids = ref
                        .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                        .getListByType(_tabController!.index)
                        .where((element) => checkedIds.contains(element.mustId))
                        .map((e) => e.sId)
                        .toList();

                    List<int?> ids = ref
                        .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                        .getListByType(_tabController!.index)
                        .where((element) => checkedIds.contains(element.mustId))
                        .map((e) => e.id)
                        .toList();

                    reInstalls(context, sids, ids);
                  } else if (s == "删除") {
                    List<String?> sids = ref
                        .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                        .getListByType(_tabController!.index)
                        .where((element) => checkedIds.contains(element.mustId))
                        .map((e) => e.sId)
                        .toList();

                    List<int?> ids = ref
                        .read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier)
                        .getListByType(_tabController!.index)
                        .where((element) => checkedIds.contains(element.mustId))
                        .map((e) => e.id)
                        .toList();
                    ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context)).notifier).del(
                          context,
                          types[_tabController!.index].name,
                          sids,
                          ids,
                        );
                  }
                },
              );
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void reInstalls(BuildContext context, List<String?>? sId, List<int?>? id) async {
    ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context))).reInstall(
          context,
          types[_tabController!.index].name,
          sId,
          id,
        );
  }

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  void removeOverlay() {
    if (_editModeOverlay != null && _editModeOverlay!.mounted) {
      _editModeOverlay?.remove();
      _editModeOverlay = null;
    }
  }

  Widget buildTitle(String title) {
    return Container(
      color: _tabController!.index == 0 ? Colors.white : Colors.grey,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }
}

class DepListView extends StatefulWidget {
  final List<DependencyBean> list;
  final String searchText;
  final DepedencyEnum type;

  final bool editMode;
  final Set<String> checked;
  final ValueChanged<String> changed;

  const DepListView({
    Key? key,
    required this.list,
    required this.type,
    required this.searchText,
    required this.editMode,
    required this.checked,
    required this.changed,
  }) : super(key: key);

  @override
  State<DepListView> createState() => _DepListViewState();
}

class _DepListViewState extends State<DepListView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(
        bottom: 80,
        top: kToolbarHeight,
      ),
      itemBuilder: (context, index) {
        DependencyBean item = widget.list[index];
        if (widget.searchText.isEmpty || (item.name?.toLowerCase().contains(widget.searchText.toLowerCase()) ?? false)) {
          return DependencyCell(
            widget.type,
            widget.list[index],
            editMode: widget.editMode,
            checkedCallback: (id) {
              widget.changed(id);
            },
            checked: widget.checked.contains(widget.list[index].mustId),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
      itemCount: widget.list.length,
      separatorBuilder: (BuildContext context, int index) {
        DependencyBean item = widget.list[index];
        if (widget.searchText.isEmpty || (item.name?.toLowerCase().contains(widget.searchText.toLowerCase()) ?? false)) {
          return Divider(
            height: 1,
            indent: widget.editMode ? 55 : 15,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class DependencyCell extends ConsumerWidget {
  final DepedencyEnum type;
  final DependencyBean bean;
  final bool editMode;
  final bool checked;
  final ValueChanged<String> checkedCallback;

  const DependencyCell(
    this.type,
    this.bean, {
    Key? key,
    this.editMode = false,
    required this.checkedCallback,
    required this.checked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey(bean.mustId),
      enabled: !editMode,
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            backgroundColor: const Color(0xff5D5E70),
            onPressed: (_) {
              reInstall(
                bean.name ?? "",
                context,
                ref,
                bean.sId,
                bean.id,
              );
            },
            foregroundColor: Colors.white,
            icon: CupertinoIcons.memories,
          ),
          SlidableAction(
            backgroundColor: const Color(0xffA356D6),
            onPressed: (_) {
              showLog(
                context,
                bean.name ?? "",
                ref,
                bean.sId,
                bean.id,
              );
            },
            foregroundColor: Colors.white,
            icon: CupertinoIcons.text_justifyleft,
          ),
          SlidableAction(
            backgroundColor: const Color(0xffEA4D3E),
            onPressed: (_) {
              del(
                context,
                ref,
                bean,
                bean.sId,
                bean.id,
              );
            },
            foregroundColor: Colors.white,
            icon: CupertinoIcons.delete,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (editMode) {
            checkedCallback(bean.mustId ?? "");
          } else {
            showLog(context, bean.name ?? "", ref, bean.sId, bean.id);
          }
        },
        child: Row(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: SizedBox(
                width: editMode ? 40 : 0,
                height: 40,
                child: Visibility(
                  visible: editMode,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                    ),
                    child: Icon(
                      checked ? CupertinoIcons.checkmark_alt_circle : CupertinoIcons.circle,
                      size: 25,
                      color: checked ? ref.watch(themeProvider).primaryColor : ref.watch(themeProvider).themeColor.descColor(),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              bean.name ?? "",
                              maxLines: 1,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: ref.watch(themeProvider).themeColor.titleColor(),
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        bean.status == 1
                            ? StatusWidget(title: "已安装", color: ref.watch(themeProvider).primaryColor)
                            : (bean.status == 2 ? const StatusWidget(title: "安装失败", color: Color(0xffFB5858)) : const RunningWidget()),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                (bean.created == null || bean.created == 0)
                                    ? (Utils.formatGMTTime(bean.timestamp ?? ""))
                                    : Utils.formatMessageTime(bean.created!),
                                maxLines: 1,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLog(BuildContext context, String title, WidgetRef ref, String? sId, int? id) {
    String v = "";
    if (sId != null) {
      v = sId;
    } else {
      v = id.toString();
    }

    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => InTimeDepLogPage(v, true, title),
      ),
    )
        .then(
      (value) async {
        await ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context))).loadData(
              context,
              type.name.toLowerCase(),
            );
      },
    );
  }

  void reInstall(String title, BuildContext context, WidgetRef ref, String? sId, int? id) async {
    ref.read(SingleAccountPageState.ofDependencyProvider(context)(getProviderName(context))).reInstall(
      context,
      type.name.toLowerCase(),
      [sId],
      [id],
    );
    showLog(context, title, ref, sId, id);
  }

  void del(BuildContext context1, WidgetRef ref, DependencyBean bean, String? sId, int? id) {
    showCupertinoDialog(
      useRootNavigator: false,
      context: context1,
      builder: (context2) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除依赖 ${bean.name ?? ""} 吗"),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "取消",
              style: TextStyle(
                color: Color(0xff999999),
              ),
            ),
            onPressed: () {
              Navigator.of(context2).pop();
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
              Navigator.of(context2).pop();
              await ref
                  .read(SingleAccountPageState.ofDependencyProvider(context1)(getProviderName(context1)))
                  .del(context1, type.name.toLowerCase(), [sId], [id]);
              showLog(context1, bean.name ?? "", ref, sId, id);
            },
          ),
        ],
      ),
    );
  }
}

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final bool editMode;
  final WidgetRef ref;

  const SliverTabBarDelegate(
    this.tabController,
    this.editMode,
    this.ref,
  );

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 55,
      child: ColoredBox(
        color: ref.watch(themeProvider).currentTheme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 10,
            top: 10,
          ),
          child: IgnorePointer(
            ignoring: editMode,
            child: CustomSlidingSegmentedControl<int>(
              initialValue: 1,
              height: 35,
              isStretch: true,
              children: {
                1: Text(
                  DependcyPageState.types[0].name,
                  style: TextStyle(
                    fontSize: 14,
                    color: ref.watch(themeProvider).themeColor.title2Color(),
                  ),
                ),
                2: Text(
                  DependcyPageState.types[1].name,
                  style: TextStyle(
                    fontSize: 14,
                    color: ref.watch(themeProvider).themeColor.title2Color(),
                  ),
                ),
                3: Text(
                  DependcyPageState.types[2].name,
                  style: TextStyle(
                    fontSize: 14,
                    color: ref.watch(themeProvider).themeColor.title2Color(),
                  ),
                ),
              },
              decoration: BoxDecoration(
                color: ref.watch(themeProvider).themeColor.segmentedUnCheckBg(),
                borderRadius: BorderRadius.circular(8),
              ),
              thumbDecoration: BoxDecoration(
                color: ref.watch(themeProvider).themeColor.blackAndWhite(),
                borderRadius: BorderRadius.circular(6),
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInToLinear,
              onValueChanged: (v) {
                if (editMode) return;
                tabController.index = v - 1;
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return true;
  }

  @override
  double get maxExtent => 55;

  @override
  double get minExtent => 55;
}
