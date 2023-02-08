import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:path/path.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

import '../../../main.dart';

class ScriptDownloadPage extends ConsumerStatefulWidget {
  const ScriptDownloadPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ScriptDownloadPage> createState() => _ScriptDownloadPageState();
}

class _ScriptDownloadPageState extends ConsumerState<ScriptDownloadPage> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: "");
    super.initState();
    focusNode.requestFocus();
  }

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: QlAppBar(
          canBack: true,
          actions: [
            CommitButton(
              title: "下载",
              onTap: () {
                download(context);
              },
            ),
          ],
          title: "远程地址",
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TitleWidget(
                "远程地址",
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                focusNode: focusNode,
                controller: controller,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: "请输入远程地址",
                ),
                autofocus: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void download(BuildContext context) async {
    if (controller.text.isEmpty) {
      "请输入远程地址".toast();
      return;
    }
    if (!controller.text.startsWith("http")) {
      "请输入合法的远程地址".toast();
      return;
    }
    EasyLoading.show(status: "下载中");
    try {
      var _dio = Dio(
        BaseOptions(
          connectTimeout: 50000,
          receiveTimeout: 50000,
          sendTimeout: 50000,
          contentType: "application/json",
        ),
      );
      var response = await _dio.get(
        controller.text.trim(),
      );
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        final path = await _localPath;
        String fileName = basename(controller.text.trim());
        File f = File('$path/${DateTime.now().millisecondsSinceEpoch}_$fileName');
        if (f.existsSync()) {
          f.deleteSync();
        }
        await f.writeAsString(response.data.toString());
        Navigator.of(context).pop({
          "path": f.path,
          "name": fileName,
        });
      } else {
        response.statusMessage.toast();
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  Future<String> get _localPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
}
