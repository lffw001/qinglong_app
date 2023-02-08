import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/search_cell.dart';
import 'package:qinglong_app/module/appkey/appkey_detail_page.dart';
import 'package:qinglong_app/module/appkey/appkey_viewmodel.dart';
import 'package:qinglong_app/utils/utils.dart';

import 'add_appkey_page.dart';

class AppKeyPage extends ConsumerStatefulWidget {
  const AppKeyPage({Key? key}) : super(key: key);

  @override
  _AppKeyPageState createState() => _AppKeyPageState();
}

class _AppKeyPageState extends ConsumerState<AppKeyPage> {
  TextEditingController searchText = TextEditingController();

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
        title: "应用管理",
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .push(
                CupertinoPageRoute(
                  builder: (context) => const AddAppKeyPage(
                    bean: {},
                  ),
                ),
              )
                  .then(
                (value) {
                  if (value != null && value == true) {
                    ref
                        .read(
                          SingleAccountPageState.ofAppKeyProvider(context)(
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
      body: BaseStateWidget<AppKeyViewModel>(
        builder: (ref, model, child) {
          return body(model, getListByType(model), ref);
        },
        model: SingleAccountPageState.ofAppKeyProvider(context)(getProviderName(context)),
        lazyLoad: true,
        onReady: (viewModel) {
          viewModel.loadData(context);
        },
      ),
    );
  }

  Widget body(AppKeyViewModel model, List<Map<String, dynamic>> list, WidgetRef ref) {
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
              if (searchText.text.isEmpty || (item["name"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false)) {
                return AppKeyItemCell(item, ref);
              } else {
                return const SizedBox.shrink();
              }
            },
            itemCount: list.length + 1,
            separatorBuilder: (BuildContext context, int index) {
              if (index == 0) return const SizedBox.shrink();
              Map<String, dynamic> item = list[index - 1];
              if (searchText.text.isEmpty || (item["name"]?.toLowerCase().contains(searchText.text.toLowerCase()) ?? false)) {
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

  List<Map<String, dynamic>> getListByType(AppKeyViewModel model) {
    return model.list;
  }
}

class AppKeyItemCell extends StatelessWidget {
  final Map<String, dynamic> bean;
  final WidgetRef ref;

  const AppKeyItemCell(this.bean, this.ref, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ref.watch(themeProvider).themeColor.settingBgColor(),
      child: Slidable(
        key: ValueKey(getAppKeyId(bean)),
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
                    builder: (context) => AddAppKeyPage(
                      bean: bean,
                    ),
                  ),
                )
                    .then(
                  (value) {
                    if (value != null && value == true) {
                      ref
                          .read(
                            SingleAccountPageState.ofAppKeyProvider(context)(
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
                    _reset(context);
                  });
                },
                foregroundColor: Colors.white,
                icon: CupertinoIcons.arrow_2_circlepath),
            SlidableAction(
              backgroundColor: const Color(0xffEA4D3E),
              onPressed: (_) {
                WidgetsBinding.instance.endOfFrame.then((value) {
                  _del(context, ref);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
            ),
          ],
        ),
        child: Material(
          color: ref.watch(themeProvider).themeColor.settingBgColor(),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => AppKeyDetailDetailPage(
                    bean,
                  ),
                ),
              );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 5,
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
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Wrap(
                      runSpacing: 5,
                      spacing: 5,
                      children: AppKeyViewModel.getScopeNames((bean["scopes"] as List<dynamic>?))
                          .map((e) => Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  e,
                                  maxLines: 1,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: ref.watch(themeProvider).themeColor.blackAndWhite(),
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
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
        content: Text("确认删除应用 ${bean["name"] ?? ""} 吗"),
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
                    SingleAccountPageState.ofAppKeyProvider(context1)(
                      getProviderName(context1),
                    ),
                  )
                  .delAppKey(
                    context1,
                    getAppKeyId(bean),
                  );
            },
          ),
        ],
      ),
    );
  }

  void _reset(BuildContext context) {
    showCupertinoDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text("确认重置应用 ${bean["name"]} 的Secret吗"),
        content: const Text("重置Secret会让当前应用所有token失效"),
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
                    SingleAccountPageState.ofAppKeyProvider(context)(
                      getProviderName(context),
                    ),
                  )
                  .resetAppKey(
                    context,
                    getAppKeyId(bean),
                  );
            },
          ),
        ],
      ),
    );
  }
}

String getAppKeyId(Map<String, dynamic> bean) {
  if (bean.containsKey("_id")) {
    return bean["_id"] ?? "";
  }
  return bean["id"]?.toString() ?? "";
}
