import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:json_table/json_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';

import '../../code_editor/editor.dart';

class ScriptCodeDetailPage extends ConsumerStatefulWidget {
  final String title;
  final String content;
  final bool canRestore;
  final String? absPath;

  const ScriptCodeDetailPage({
    Key? key,
    required this.title,
    required this.content,
    this.absPath,
    this.canRestore = false,
  }) : super(key: key);

  @override
  ScriptCodeDetailPageState createState() => ScriptCodeDetailPageState();
}

class ScriptCodeDetailPageState extends ConsumerState<ScriptCodeDetailPage> with LazyLoadState<ScriptCodeDetailPage> {
  bool buttonshow = false;

  late CodeMirrorOptions options;
  EditorController? controller;

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

  bool showTable = true;
  String? content;

  bool isJsonFile() {
    return (widget.absPath?.endsWith(".${FileUtil.env}") ?? false) || (widget.absPath?.endsWith(".${FileUtil.subscribe}") ?? false);
  }

  String getPrettyJSONString() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(jsonDecode(content ?? "[]"));
    return jsonString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: isJsonFile()
          ? FloatingActionButton(
              child: const Icon(
                Icons.grid_on,
              ),
              onPressed: () {
                setState(
                  () {
                    showTable = !showTable;
                  },
                );
              })
          : const Visibility(
              visible: false,
              child: SizedBox.shrink(),
            ),
      appBar: QlAppBar(
        canBack: true,
        actions: [
          !widget.canRestore
              ? const SizedBox.shrink()
              : CupertinoButton(
                  color: Colors.transparent,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (childContext) => CupertinoAlertDialog(
                        title: const Text("温馨提示"),
                        content: const Text("确定还原吗?"),
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
                            onPressed: () async {
                              Navigator.of(context).pop();
                              if (widget.title.endsWith(".${FileUtil.env}")) {
                                getIt<ICloudUtils>(instanceName: (SingleAccountPageState.of(context)?.index ?? 0).toString()).restoreEnv(widget.absPath!);
                              } else if (widget.title.endsWith(".${FileUtil.config}")) {
                                getIt<ICloudUtils>(instanceName: (SingleAccountPageState.of(context)?.index ?? 0).toString()).restoreConfig(widget.absPath!);
                              } else if (widget.title.endsWith(".${FileUtil.subscribe}")) {
                                getIt<ICloudUtils>(instanceName: (SingleAccountPageState.of(context)?.index ?? 0).toString()).restoreSubscribe(widget.absPath!);
                              } else {
                                "不支持还原该文件".toast();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: Center(
                      child: Text(
                        "还原",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).appBarTheme.iconTheme?.color,
                        ),
                      ),
                    ),
                  ),
                )
        ],
        title: widget.title,
      ),
      body: (content == null)
          ? const Center(
              child: LoadingWidget(),
            )
          : SafeArea(
              top: false,
              child: isJsonFile()
                  ? json()
                  : Editor(
                      options: options,
                      onCreate: (val) {
                        controller = val;
                        controller?.setOptions(options);
                        controller?.setValue(content ?? "");
                      },
                      onValue: (val) {},
                    ),
            ),
    );
  }

  Widget json() {
    return !showTable
        ? Center(
            child: SelectableText(
              getPrettyJSONString(),
              selectionWidthStyle: BoxWidthStyle.max,
              selectionHeightStyle: BoxHeightStyle.max,
            ),
          )
        : JsonTable(
            jsonDecode(content ?? "[]"),
            tableHeaderBuilder: (String? header) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  minHeight: 50,
                  maxHeight: 50,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.5),
                ),
                child: Text(
                  header ?? "",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              );
            },
            tableCellBuilder: (value) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                constraints: const BoxConstraints(
                  maxWidth: 200,
                  minHeight: 50,
                  maxHeight: 50,
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 0.5,
                )),
                child: Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              );
            },
          );
  }

  @override
  void onLazyLoad() {
    content = widget.content;
    setState(() {});
  }

  @override
  void initState() {
    options = CodeMirrorOptions(
      readOnly: true,
      mode: getLanguageType(widget.title),
    );
    super.initState();
  }
}
