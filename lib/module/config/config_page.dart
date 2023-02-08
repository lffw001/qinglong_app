import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/empty_widget.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/config/add_config_page.dart';
import 'package:qinglong_app/module/config/config_bean.dart';
import 'package:qinglong_app/utils/utils.dart';

import '../home/home_page.dart';
import 'config_viewmodel.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  ConfigPageState createState() => ConfigPageState();
}

class ConfigPageState extends ConsumerState<ConfigPage> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  BuildContext? childContext;
  String? configContent;
  bool gotoConfigDetailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadConfigData(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (MultiAccountPageState.actionEditConfig == MultiAccountPageState.useAction()) {
        gotoConfigDetailed = false;
        loadConfigData(context);
      }
    }
  }

  Future<void> loadConfigData(BuildContext context) async {
    HttpResponse<String> result = await SingleAccountPageState.ofApi(context).content("config.sh");
    if (result.success && result.bean != null) {
      configContent = result.bean;

      if (MultiAccountPageState.actionEditConfig == MultiAccountPageState.useAction() && !gotoConfigDetailed) {
        gotoConfigDetailed = true;
        Navigator.of(context).pushNamed(
          Routes.routeConfigEdit,
          arguments: {
            "title": "config.sh",
            "content": configContent,
          },
        ).then((value) {
          loadConfigData(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: false,
        title: "配置文件",
        actions: [
          CupertinoButton(
            color: Colors.transparent,
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.of(context)
                  .push(
                CupertinoPageRoute(
                  builder: (context) => const AddConfigPage(),
                ),
              )
                  .then(
                (value) {
                  if (value != null && value == true) {
                    ref.read(SingleAccountPageState.ofConfigProvider(context)(getProviderName(context)).notifier).loadData(context, false);
                  }
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: 24,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BaseStateWidget<ConfigViewModel>(
        builder: (ref, model, child) {
          List<Widget> list = [];
          for (int i = 0; i < model.list.length; i++) {
            ConfigBean value = model.list[i];

            if (value.title?.toLowerCase() == "config.sh") {
              list.add(GestureDetector(
                behavior: HitTestBehavior.opaque,
                onDoubleTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.routeConfigEdit,
                    arguments: {
                      "title": value.title,
                      "content": configContent,
                    },
                  ).then((value) {
                    Future.delayed(const Duration(seconds: 1), () {
                      loadConfigData(context);
                    });
                  });
                },
                child: ConfigCell(
                  bean: value,
                ),
              ));
            } else {
              list.add(ConfigCell(
                bean: value,
              ));
            }
          }

          return model.list.isEmpty
              ? const EmptyWidget()
              : RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  onRefresh: () async {
                    await loadConfigData(context);
                    return model.loadData(context, false);
                  },
                  child: ListView(
                    primary: true,
                    padding: const EdgeInsets.only(
                      bottom: kBottomNavigationBarHeight + 50,
                    ),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: list,
                  ),
                );
        },
        model: SingleAccountPageState.ofConfigProvider(context)(getProviderName(context)),
        onReady: (viewModel) {
          viewModel.loadData(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class ConfigCell extends ConsumerWidget {
  final ConfigBean bean;

  const ConfigCell({
    Key? key,
    required this.bean,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.routeConfigDetail, arguments: {
          "bean": bean,
        });
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          bean.title ?? "",
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: ref.watch(themeProvider).themeColor.titleColor(),
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Image.asset(
                        "assets/images/icon_right.png",
                        fit: BoxFit.cover,
                        width: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(
              height: 1,
              indent: 15,
            ),
          ],
        ),
      ),
    );
  }
}
