import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/upload_script_widget.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:path/path.dart';
import 'package:qinglong_app/module/task/add_task_page.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

class ScriptUploadPage extends ConsumerStatefulWidget {
  const ScriptUploadPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ScriptUploadPage> createState() => ScriptUploadPageState();
}

class ScriptUploadPageState extends ConsumerState<ScriptUploadPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "新增脚本",
        actions: [
          CommitButton(
            onTap: () {
              submit(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const TitleWidget(
                    "脚本名称",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "上传脚本可自动识别脚本名称",
                    ),
                    autofocus: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  UploadScriptWidget(
                    key: fileKey,
                    nameCallBack: (name) {
                      _nameController.text = name ?? "";
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  GlobalKey<UploadScriptWidgetState> fileKey = GlobalKey();

  void submit(BuildContext context) async {
    try {
      if (_nameController.text.isEmpty) {
        "请输入文件名称".toast();
        return;
      }

      if (fileKey.currentState?.file == null) {
        Navigator.of(context).pushNamed(
          Routes.routeScriptAdd,
          arguments: {
            "title": _nameController.text,
            "path": fileKey.currentState?.scriptPath,
          },
        ).then((value) {
          if (value != null && value == true) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        String content = await fileKey.currentState!.file!.readAsString();
        EasyLoading.show(status: "提交中...");
        HttpResponse<NullResponse> response = await SingleAccountPageState.ofApi(context).addScript(
          _nameController.text,
          fileKey.currentState?.scriptPath ?? "",
          content,
        );
        EasyLoading.dismiss();
        if (response.success) {
          "提交成功".toast();

          String command =
              "task ${fileKey.currentState?.scriptPath}${(fileKey.currentState?.scriptPath != null && fileKey.currentState!.scriptPath.isNotEmpty) ? separator : ""}${_nameController.text} ";

          String? cron = getCronString(content, _nameController.text);
          Navigator.of(context)
              .push(
            CupertinoPageRoute(
              builder: (context) => AddTaskPage(
                taskBean: TaskBean(
                  name: _nameController.text,
                  command: command,
                  schedule: cron,
                ),
                hideUploadFile: true,
              ),
            ),
          )
              .then((value) {
            Navigator.of(context).pop();
          });
        } else {
          (response.message ?? "").toast();
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      e.toString().toast();
    }
  }

  static String? getCronString(String pre, String fileName) {
    try {
      String reg = "([\\d\\*]*[\\*-\\/,\\d]*[\\d\\*] ){4,5}[\\d\\*]*[\\*-\\/,\\d]*[\\d\\*]( |,|\").*$fileName";
      RegExp regExp = RegExp(reg);
      RegExpMatch? result = regExp.firstMatch(pre);
      String? find = result?[0]?.replaceAll(fileName, "").trim();

      String regNext = "([\\d\\*]*[\\*-\\/,\\d]*[\\d\\*] ){4,5}[\\d\\*]*[\\*-\\/,\\d]*[\\d\\*]( |,|\")";
      RegExp regExpNext = RegExp(regNext);
      RegExpMatch? resultNext = regExpNext.firstMatch(find ?? "");
      return resultNext?[0]?.trim();
    } catch (e) {
      return null;
    }
  }
}
