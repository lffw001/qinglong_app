import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:path/path.dart' as p;
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/upload_script_widget.dart';
import 'package:qinglong_app/module/others/scripts/script_upload_page.dart';
import 'package:qinglong_app/module/subscribe/add_subscribe_page.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/config_detail_page.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  final TaskBean? taskBean;
  final bool hideUploadFile;

  const AddTaskPage({
    Key? key,
    this.taskBean,
    required this.hideUploadFile,
  }) : super(key: key);

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> with LazyLoadState<AddTaskPage> {
  late TaskBean taskBean;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _cronController = TextEditingController();

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.taskBean != null) {
      taskBean = widget.taskBean!;
      _nameController.text = taskBean.name ?? "";
      _commandController.text = taskBean.command ?? "";
      _cronController.text = taskBean.schedule ?? "";
    } else {
      taskBean = TaskBean();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        actions: [
          CommitButton(
            onTap: () {
              submit();
            },
          ),
        ],
        title: (taskBean.sId == null || taskBean.sId!.isEmpty) ? "新增任务" : "编辑任务",
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
                    height: 15,
                  ),
                  const TitleWidget(
                    "名称",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    focusNode: focusNode,
                    controller: _nameController,
                    maxLines: 3,
                    minLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: "请输入名称",
                    ),
                    autofocus: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const TitleWidget(
                    "命令",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _commandController,
                    maxLines: 4,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: "请输入命令",
                    ),
                    autofocus: false,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const TitleWidget(
                    "定时规则",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _cronController,
                    minLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: "秒(可选) 分	时 天 月 周",
                    ),
                    autofocus: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      try {
                        var cron = _cronController.text.replaceAll(" ", "_");
                        await launchUrl(Uri.tryParse("https://crontab.guru/#$cron")!);
                      } catch (e) {}
                    },
                    child: Text(
                      "在线测试",
                      style: TextStyle(
                        fontSize: 12,
                        color: ref.watch(themeProvider).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    visible: !widget.hideUploadFile,
                    child: UploadScriptWidget(
                      key: fileKey,
                      nameCallBack: (name) async {
                        _nameController.text = name ?? "";
                        if (name == null || name.isEmpty) {
                          _commandController.text = "";
                          _cronController.text = "";
                        } else {
                          String command =
                              "task ${fileKey.currentState?.scriptPath}${(fileKey.currentState != null && fileKey.currentState!.scriptPath.isNotEmpty) ? p.separator : ""}${fileKey.currentState?.getFileName()}";

                          _commandController.text = command;

                          String data = await fileKey.currentState?.file?.readAsString() ?? "";

                          _cronController.text = ScriptUploadPageState.getCronString(data, name) ?? "";
                        }
                      },
                    ),
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

  void submit() async {
    if (_nameController.text.isEmpty) {
      "任务名称不能为空".toast();
      return;
    }
    if (_commandController.text.isEmpty) {
      "命令不能为空".toast();
      return;
    }
    if (_cronController.text.isEmpty) {
      "定时规则不能为空".toast();
      return;
    }

    commitReal();
  }

  void commitReal() async {
    try {
      hideKeyboardFocus();
      if (fileKey.currentState != null && fileKey.currentState!.file != null) {
        String content = await fileKey.currentState!.file!.readAsString();
        HttpResponse<NullResponse> responseS = await SingleAccountPageState.ofApi(context).addScript(
          fileKey.currentState?.getFileName() ?? _commandController.text.split(" ").last,
          fileKey.currentState?.scriptPath ?? "",
          content,
        );
        if (!responseS.success) {
          responseS.message.toast();
          return;
        }
      }

      taskBean.name = _nameController.text;
      taskBean.command = _commandController.text.trim();
      taskBean.schedule = _cronController.text.trim();

      await EasyLoading.show(status: " 提交中");
      HttpResponse<NullResponse> response = await SingleAccountPageState.ofApi(context).addTask(
        _nameController.text,
        _commandController.text.trim(),
        _cronController.text.trim(),
        id: taskBean.id,
        nId: taskBean.nId,
      );
      await EasyLoading.dismiss();
      if (response.success) {
        (widget.taskBean?.sId == null) ? "新增成功" : "修改成功".toast();
        ref.read(SingleAccountPageState.ofTaskProvider(context)(getProviderName(context))).updateBean(context, taskBean);
        Navigator.of(context).pop();
      } else {
        response.message.toast();
      }
    } catch (e) {
      e.toString().toast();
      EasyLoading.dismiss();
    }
  }

  @override
  void onLazyLoad() {
    if (widget.hideUploadFile) {
      focusNode.requestFocus();
    }
  }
}
