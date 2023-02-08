import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/base/ui/search_cell.dart';
import 'package:qinglong_app/base/ui/tree/models/script_data.dart';
import 'package:qinglong_app/module/others/scripts/folder_add_page.dart';
import 'package:qinglong_app/module/others/scripts/script_upload_page.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../../base/cupertino_sheet.dart';
import '../../../base/ui/tree/tree_view.dart';
import '../../../base/ui/tree/tree_view_controller.dart';
import '../../../main.dart';
import '../../home/system_bean.dart';

class ScriptPage extends ConsumerStatefulWidget {
  const ScriptPage({Key? key}) : super(key: key);

  @override
  _ScriptPageState createState() => _ScriptPageState();
}

class _ScriptPageState extends ConsumerState<ScriptPage> with LazyLoadState<ScriptPage> {
  List<ScriptData> list = [];

  String? path;

  ScrollController controller = ScrollController();
  TextEditingController searchText = TextEditingController();

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
    if (y > 500) {
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

  late TreeViewController _treeViewController;

  @override
  Widget build(BuildContext context) {
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
          title: "脚本管理",
          actions: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showMoreOperate(
                  context,
                  [
                    CupertinoSheer(
                      title: "新增文件",
                      onTap: () {
                        addScript();
                      },
                    ),
                    addDivider(),
                    CupertinoSheer(
                      title: "新增文件夹",
                      onTap: () {
                        SystemBean? systemBean;
                        try {
                          systemBean = getIt<SystemBean>(instanceName: (SingleAccountPageState.of(context)?.index ?? 0).toString());
                        } catch (e) {
                          systemBean = SystemBean(version: "2.10.13", fromAutoGet: false);
                        }
                        if (!systemBean.isUpperVersion2_14_5()) {
                          "该功能仅支持v2.14.5及以上版本".toast();
                          return;
                        }
                        addFloder();
                      },
                    )
                  ],
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
        body: list.isEmpty
            ? const Center(
                child: LoadingWidget(),
              )
            : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  await loadData();
                  return Future.value();
                },
                child: TreeView(
                  controller: _treeViewController,
                  onExpansionChanged: (key, state) {
                    ScriptData? node = _treeViewController.getNode(key);
                    if (node != null) {
                      List<ScriptData> updated = _treeViewController.updateNode(key, node.copyWith(expanded: !node.expanded));
                      setState(() {
                        _treeViewController = _treeViewController.copyWith(children: updated);
                      });
                    }
                  },
                  onDeleteSelfClick: (ScriptData data) {
                    showCupertinoDialog(
                      useRootNavigator: false,
                      context: context,
                      builder: (context1) => CupertinoAlertDialog(
                        title: const Text("确认删除"),
                        content: const Text("确认删除吗"),
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
                              Navigator.of(context1).pop();
                              deleteFold(data);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  onNodeTap: (key) {
                    ScriptData? selectedNode = _treeViewController.getNode(key);
                    Navigator.of(context).pushNamed(
                      Routes.routeScriptDetail,
                      arguments: {
                        "title": selectedNode?.title,
                        "path": selectedNode?.parent,
                      },
                    ).then(
                      (value) {
                        if (value != null && value == true) {
                          loadData();
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget searchCell(WidgetRef context) {
    return Container(
      color: ref.watch(themeProvider).themeColor.searchBgColor(),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: SearchCell(
        controller: searchText,
      ),
    );
  }

  Future<void> loadData() async {
    HttpResponse<List<ScriptData>> response = await SingleAccountPageState.ofApi(context).scripts();

    if (response.success) {
      if (response.bean == null || response.bean!.isEmpty) {
        "暂无数据".toast();
      }
      list.clear();
      response.bean?.removeWhere((element) => element.title == "node_modules");
      list.addAll(response.bean ?? []);
      _treeViewController = TreeViewController(children: list);
      setState(() {});
    } else {
      response.message?.toast();
    }
  }

  @override
  void onLazyLoad() {
    loadData();
  }

  String scriptPath = "";

  void addScript() {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => const ScriptUploadPage(),
      ),
    )
        .then((value) {
      if (value != null && value == true) {
        loadData();
      }
    });
  }

  void addFloder() {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => const FloderAddPage(),
      ),
    )
        .then((value) {
      if (value != null && value == true) {
        loadData();
      }
    });
  }

  void deleteFold(ScriptData item) async {
    SystemBean? systemBean;

    try {
      systemBean = getIt<SystemBean>(instanceName: (SingleAccountPageState.of(context)?.index ?? 0).toString());
    } catch (e) {
      systemBean = SystemBean(version: "2.10.13", fromAutoGet: false);
    }
    if ((item.children.isNotEmpty) && !systemBean.isUpperVersion2_14_5()) {
      "该功能仅支持v2.14.5及以上版本".toast();
      return;
    }

    EasyLoading.show(status: "删除中...");
    var temp = (item.type == "directory")
        ? await SingleAccountPageState.ofApi(context).delScriptFold(
            item.title,
            item.parent,
          )
        : (systemBean.isUpperVersion2_14_5()
            ? await SingleAccountPageState.ofApi(context).delScriptNewVersion(
                item.title,
                item.parent,
              )
            : await SingleAccountPageState.ofApi(context).delScript(
                item.title,
                item.parent,
              ));
    EasyLoading.dismiss();
    if (temp.success) {
      "已删除".toast();
      await loadData();
    } else {
      temp.message.toast();
    }
  }
}
