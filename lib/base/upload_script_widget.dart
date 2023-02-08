import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as ints;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/cupertino_sheet.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/base/ui/tree/models/script_data.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/others/scripts/script_code_detail_page.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import '../module/others/scripts/script_download_page.dart';
import '../module/subscribe/add_subscribe_page.dart';
import 'single_account_page.dart';

typedef StringCallBack = void Function(String? name);
typedef CronCallBack = void Function(String? name);

class UploadScriptWidget extends ConsumerStatefulWidget {
  final StringCallBack nameCallBack;
  final CronCallBack? cronCallBack;
  final bool onlyShowName;

  const UploadScriptWidget({
    Key? key,
    required this.nameCallBack,
    this.onlyShowName = false,
    this.cronCallBack,
  }) : super(key: key);

  @override
  ConsumerState<UploadScriptWidget> createState() => UploadScriptWidgetState();
}

class UploadScriptWidgetState extends ConsumerState<UploadScriptWidget>
    with LazyLoadState<UploadScriptWidget> {
  String scriptPath = "";
  File? file;
  String? fileName;
  List<String?> paths = [];
  bool isLoading = true;

  @override
  void onLazyLoad() {
    init();
  }

  void init() async {
    isLoading = true;
    HttpResponse<List<ScriptData>> response = await SingleAccountPageState.ofApi(context).scripts();

    if (response.success) {
      if (response.bean == null || response.bean!.isEmpty) {
        return;
      }
      void lookNode(ScriptData node) {
        if (node.type != "directory") {
          String name = node.parent;
          if (name == "") return;
          if (paths.isEmpty) {
            paths.add(name);
          } else {
            if (!paths.contains(name)) {
              paths.add(node.parent);
            }
          }
          return;
        } else {
          if (node.children.isEmpty) {
            String name = node.parent;
            if (name == "") return;
            if (paths.isEmpty) {
              paths.add(name + "/" + node.title);
            } else {
              if (!paths.contains(name + "/" + node.title)) {
                paths.add(name + "/" + node.title);
              }
            }
          } else {
            for (var value in node.children) {
              lookNode(value);
            }
          }
        }
      }

      if (response.bean != null) {
        for (var value in response.bean!) {
          lookNode(value);
        }
      }
      paths = paths.reversed.toList();
      isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleWidget(
          widget.onlyShowName ? "父目录" : "脚本目录",
        ),
        const SizedBox(
          height: 10,
        ),
        isLoading
            ? const Center(child: LoadingWidget())
            : DropdownButtonFormField<String>(
                elevation: 0,
                isExpanded: true,
                items: paths
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Text(
                              e ?? "",
                              maxLines: 2,
                            ),
                          ),
                        ))
                    .toList()
                  ..insert(
                    0,
                    DropdownMenuItem(
                      value: "",
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 100,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Text(
                            "根目录",
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                style: TextStyle(
                  fontSize: 14,
                  color: ref.watch(themeProvider).themeColor.title2Color(),
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                ),
                icon: const Icon(
                  CupertinoIcons.chevron_up_chevron_down,
                  size: 16,
                ),
                value: scriptPath,
                onChanged: (value) {
                  scriptPath = value ?? "";
                  widget.nameCallBack(fileName);
                  setState(() {});
                },
              ),
        const SizedBox(
          height: 30,
        ),
        Visibility(
          visible: !widget.onlyShowName,
          child: RichText(
            text: TextSpan(
              text: "上传脚本",
              style: TextStyle(
                fontSize: 16,
                color: ref.watch(themeProvider).themeColor.titleColor(),
              ),
            ),
          ),
        ),
        Visibility(
          visible: !widget.onlyShowName,
          child: const SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: !widget.onlyShowName,
          child: Container(
            height: 80,
            alignment: Alignment.centerLeft,
            child: file == null ? addWidget(context) : addedWidget(context),
          ),
        ),
      ],
    );
  }

  Widget addWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 10,
      ),
      child: CupertinoButton(
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        onPressed: () async {
          showMoreOperate(
            context,
            [
              CupertinoSheer(
                title: "远程地址",
                onTap: () {
                  fromRemote(context);
                },
              ),
              addDivider(),
              CupertinoSheer(
                title: "本地上传",
                onTap: () {
                  pickLocalFile();
                },
              )
            ],
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: ref.watch(themeProvider).themeColor.pinColor(),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.add,
              size: 35,
              color: ref.watch(themeProvider).themeColor.descColor(),
            ),
          ),
        ),
      ),
    );
  }

  void pickLocalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
      file = File(result.files.single.path!);
      fileName = null;

      if (file == null) return;
      if (file!.lengthSync() > 5242880) {
        file = null;
        "最大支持上传5M的文件".toast();
        return;
      }

      widget.nameCallBack(getFileName());
      setState(() {});
    }
  }

  void fromRemote(BuildContext context) {
    Navigator.of(context)
        .push(
      CupertinoPageRoute(
        builder: (context) => const ScriptDownloadPage(),
      ),
    )
        .then((value) {
      if (value != null) {
        Map<String, String> data = value;

        fileName = data["name"] ?? "";
        String path = data["path"] ?? "";
        file = File(path);
        if (file == null) return;
        if (file!.lengthSync() > 5242880) {
          file = null;
          "最大支持上传5M的文件".toast();
          return;
        }

        widget.nameCallBack(getFileName());
        setState(() {});
      } else {
        fileName = null;
      }
    });
  }

  Widget addedWidget(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          String content = await file!.readAsString();
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => ScriptCodeDetailPage(
                title: getFileName(),
                content: content,
              ),
            ),
          );
        } catch (e) {
          e.toString().toast();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Image.asset(
              getIconBySuffix(),
              width: 50,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFileName(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    getFileSize(file!.path, 2),
                    style: TextStyle(
                      color: ref.watch(themeProvider).themeColor.descColor(),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                file = null;
                fileName = null;
                widget.nameCallBack(null);
                setState(() {});
              },
              child: Icon(
                CupertinoIcons.clear,
                size: 20,
                color: ref.watch(themeProvider).themeColor.descColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFileSize(String filepath, int decimals) {
    var file = File(filepath);
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  String getFileName() {
    if (fileName != null) {
      return fileName!;
    }
    return ints.basename(file!.path);
  }

  String getIconBySuffix() {
    String end = file!.path;

    if (end.endsWith(".py")) {
      return "assets/images/py.png";
    }
    if (end.endsWith(".js")) {
      return "assets/images/js.png";
    }
    if (end.endsWith(".ts")) {
      return "assets/images/ts.png";
    }
    if (end.endsWith(".json")) {
      return "assets/images/json.png";
    }
    if (end.endsWith(".sh")) {
      return "assets/images/shell.png";
    }
    return "assets/images/other.png";
  }
}
