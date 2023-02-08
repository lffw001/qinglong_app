import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/cupertino_sheet.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/module/config/config_bean.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:share_plus/share_plus.dart';

import '../../base/routes.dart';
import '../../utils/icloud_utils.dart';
import '../code_editor/codemirror/io.dart';
import '../code_editor/editor.dart';



class ConfigDetailPage extends ConsumerStatefulWidget {
  final ConfigBean bean;
  final String? content;

  const ConfigDetailPage({
    Key? key,
    required this.bean,
    this.content,
  }) : super(key: key);

  @override
  ConsumerState<ConfigDetailPage> createState() => _ConfigDetailPageState();
}

class _ConfigDetailPageState extends ConsumerState<ConfigDetailPage> with LazyLoadState<ConfigDetailPage> {
  String? sourceContent;
  CodeMirrorOptions options = CodeMirrorOptions().copyWith(
    readOnly: true,
  );
  EditorController? controller;

  @override
  void initState() {
    sourceContent = widget.content;
    if (sourceContent != null && sourceContent!.isNotEmpty) {
      isLoading = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ref.watch(themeProvider).themeColor.codeBgColor(),
      appBar: QlAppBar(
        canBack: true,
        title: widget.bean.title ?? "",
        actions: [
          CupertinoButton(
            color: Colors.transparent,
            padding: EdgeInsets.zero,
            onPressed: () async {
              codeKey.currentState?.showSearchBar();
            },
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
              ),
              child: Center(
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                  size: 22,
                ),
              ),
            ),
          ),
          CupertinoButton(
            color: Colors.transparent,
            padding: EdgeInsets.zero,
            onPressed: () async {
              hideKeyboardFocus();
              showMoreOperate(context, [
                CupertinoSheer(
                  title: "编辑",
                  onTap: () async {
                    Navigator.of(context).pushNamed(
                      Routes.routeConfigEdit,
                      arguments: {
                        "title": widget.bean.title,
                        "content": sourceContent,
                      },
                    ).then(
                      (value) async {
                        if (value != null && (value as String).isNotEmpty) {
                          sourceContent = value;
                          controller?.setValue(sourceContent ?? "");
                          setState(() {});
                        }
                      },
                    );
                  },
                ),
                addDivider(),
                CupertinoSheer(
                  title: "分享",
                  onTap: () {
                    Share.share(sourceContent ?? "");
                  },
                ),
                addDivider(),
                CupertinoSheer(
                  title: "下载",
                  onTap: () async {
                    try {
                      String name = "${Random().nextInt(40000)}_${widget.bean.title}";
                      var file = await FileUtil(0).writeDownloadFile(name, sourceContent ?? "");
                      "已写入qinglong_app文件夹下,文件名$name".toast2();
                    } catch (e) {
                      e.toString().toast();
                    }
                  },
                ),
              ]);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).appBarTheme.iconTheme?.color,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: LoadingWidget())
          : SafeArea(
              top: false,
              child: Editor(
                options: options,
                codeMirrorKey: codeKey,
                onCreate: (val) {
                  controller = val;
                  controller?.setOptions(options);
                  controller?.setValue(sourceContent ?? "");
                },
                onValue: (val) {},
              ),
            ),
    );
  }

  GlobalKey<CodeMirrorViewState> codeKey = GlobalKey();

  void loadData(ConfigBean bean) async {
    HttpResponse<String> result = await SingleAccountPageState.ofApi(context).content(bean.value!);
    if (result.success && result.bean != null) {
      sourceContent = result.bean;
      isLoading = false;
      setState(() {});
    } else {
      result.message!.toast();
    }
  }

  bool isLoading = true;

  @override
  void onLazyLoad() {
    if (sourceContent == null || sourceContent!.isEmpty) {
      loadData(widget.bean);
    }
  }

  @override
  void dispose() {
    EasyLoading.dismiss();
    super.dispose();
  }
}

Future<void> hideKeyboardFocus() async {
  FocusManager.instance.primaryFocus?.unfocus();
}
