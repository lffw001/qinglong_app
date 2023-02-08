import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/upload_script_widget.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/utils/extension.dart';

class FloderAddPage extends ConsumerStatefulWidget {
  const FloderAddPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<FloderAddPage> createState() => ScriptUploadPageState();
}

class ScriptUploadPageState extends ConsumerState<FloderAddPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "新增文件夹",
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
                    "文件夹名称",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "请输入文件夹名称",
                    ),
                    autofocus: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  UploadScriptWidget(
                    key: fileKey,
                    onlyShowName: true,
                    nameCallBack: (name) {},
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
        "请输入文件夹名称".toast();
        return;
      }

      addFloder(
        context,
        fileKey.currentState?.scriptPath ?? "",
      );
    } catch (e) {
      e.toString().toast();
    }
  }

  void addFloder(BuildContext context, String path) async {
    EasyLoading.show(status: "新增中...");
    var temp = await SingleAccountPageState.ofApi(context).addScriptFolder(
      _nameController.text.toString(),
      path,
    );
    EasyLoading.dismiss();
    if (temp.success) {
      "新增成功".toast();
      Navigator.of(context).pop(true);
    } else {
      temp.message.toast();
    }
  }
}
