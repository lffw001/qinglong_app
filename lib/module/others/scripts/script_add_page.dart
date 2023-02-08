import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../code_editor/editor.dart';

class ScriptAddPage extends ConsumerStatefulWidget {
  final String title;
  final String path;

  const ScriptAddPage(this.title, this.path, {Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _ScriptAddPageState();
}

class _ScriptAddPageState extends ConsumerState<ScriptAddPage> {
  late String result;
  FocusNode focusNode = FocusNode();
  late String preResult;

  late CodeMirrorOptions options;
  EditorController? controller;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    options = CodeMirrorOptions().copyWith(
      readOnly: false,
      mode: getLanguageType(widget.title),
    );
    result = "## created by 青龙客户端 ${DateTime.now().toString()}\n\n";
    preResult = result;
    super.initState();
  }

  getLanguageType(String title) {
    if (title.endsWith(".js")) {
      return 'javascript';
    }

    if (title.endsWith(".sh")) {
      return 'shell';
    }

    if (title.endsWith(".py")) {
      return 'python';
    }
    if (title.endsWith(".json")) {
      return 'shell';
    }
    if (title.endsWith(".yaml")) {
      return 'yaml';
    }
    return "shell";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          FocusManager.instance.primaryFocus?.unfocus();

          if (preResult == result) {
            Navigator.of(context).pop();
          } else {
            showCupertinoDialog(
              context: context,
              useRootNavigator: false,
              builder: (childContext) => CupertinoAlertDialog(
                title: const Text("温馨提示"),
                content: const Text("你新增的内容还没用提交,确定退出吗?"),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(
                      "取消",
                      style: TextStyle(
                        color: Color(0xff999999),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(childContext).pop();
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
                      Navigator.of(childContext).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          }
        },
        title: '新增${widget.title}',
        actions: [
          CupertinoButton(
            color: Colors.transparent,
            padding: EdgeInsets.zero,
            onPressed: () async {
              try {
                await EasyLoading.show(status: " 提交中");
                HttpResponse<NullResponse> response =
                    await SingleAccountPageState.ofApi(context).addScript(
                  widget.title,
                  widget.path,
                  result,
                );
                await EasyLoading.dismiss();
                if (response.success) {
                  "提交成功".toast();
                  Navigator.of(context).pop(true);
                } else {
                  (response.message ?? "").toast();
                }
              } catch (e) {
                EasyLoading.dismiss();
              }
            },
            child:  Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Text(
                  "提交",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).appBarTheme.iconTheme?.color,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        top: false,
        child: Editor(
          options: options,
          onCreate: (val) {
            controller = val;
            controller?.setOptions(options);
            controller?.setValue(result);
          },
          onValue: (val) {
            result = val;
          },
        ),
      ),
    );
  }
}
