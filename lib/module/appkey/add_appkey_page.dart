import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/module/appkey/appkey_page.dart';
import 'package:qinglong_app/module/appkey/appkey_viewmodel.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../base/commit_button.dart';
import '../../base/ql_app_bar.dart';
import '../../base/single_account_page.dart';
import '../../base/theme.dart';
import '../../base/ui/drop.dart';
import '../subscribe/add_subscribe_page.dart';



class AddAppKeyPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> bean;

  const AddAppKeyPage({
    Key? key,
    required this.bean,
  }) : super(key: key);

  @override
  ConsumerState<AddAppKeyPage> createState() => _AddAppKeyPageState();
}

class _AddAppKeyPageState extends ConsumerState<AddAppKeyPage> {
  final TextEditingController _nameController = TextEditingController();

  List<String> selectedPermissions = ["定时任务"];

  @override
  void initState() {
    if (widget.bean.isNotEmpty) {
      _nameController.text = widget.bean["name"] ?? "";

      selectedPermissions.clear();
      selectedPermissions
          .addAll(AppKeyViewModel.getScopeNames(widget.bean["scopes"]));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        actions: [
          CommitButton(
            onTap: () {
              commit();
            },
          ),
        ],
        title: "新增应用",
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
                    "权限",
                    required: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      onTextFieldTap();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: selectedPermissions.isEmpty
                        ? Text(
                            "请选择",
                            style: TextStyle(
                              color: ref
                                  .watch(themeProvider)
                                  .themeColor
                                  .descColor(),
                              fontSize: 16,
                            ),
                          )
                        : Material(
                            color: Colors.transparent,
                            child: Wrap(
                              runSpacing: 5,
                              spacing: 5,
                              children: selectedPermissions
                                  .map((e) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .descColor(),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          e,
                                          maxLines: 1,
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: ref
                                                .watch(themeProvider)
                                                .themeColor
                                                .blackAndWhite(),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
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

  void onTextFieldTap() {
    DropDownState(
      DropDown(
        submitButtonText: "确定",
        submitButtonColor: ref.watch(themeProvider).primaryColor,
        searchHintText: "搜索",
        bottomSheetTitle: "请选择你需要的权限",
        searchBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
        dataList: [
          SelectedListItem(selectedPermissions.contains("定时任务"), "定时任务"),
          SelectedListItem(selectedPermissions.contains("环境变量"), "环境变量"),
          SelectedListItem(selectedPermissions.contains("配置文件"), "配置文件"),
          SelectedListItem(selectedPermissions.contains("脚本管理"), "脚本管理"),
          SelectedListItem(selectedPermissions.contains("任务日志"), "任务日志"),
          SelectedListItem(selectedPermissions.contains("依赖管理"), "依赖管理"),
          SelectedListItem(selectedPermissions.contains("系统信息"), "系统信息"),
        ],
        selectedItems: (List<String> selectedList) {
          selectedPermissions.clear();
          selectedPermissions.addAll(selectedList);
          setState(() {});
        },
        selectedItem: (String selected) {},
        enableMultipleSelection: true,
      ),
    ).showModal(context);
  }

  void commit() async {
    if (_nameController.text.isEmpty) {
      "请输入名称".toast();
      return;
    }

    if (selectedPermissions.isEmpty) {
      "请选择权限".toast();
      return;
    }

    EasyLoading.show(status: "提交中");

    HttpResponse<NullResponse> response;

    Map<String, dynamic> data = {
      "name": _nameController.getTextOrDefault(),
      "scopes": AppKeyViewModel.getScopeKeys(selectedPermissions),
    };
    if (widget.bean.containsKey("_id") || widget.bean.containsKey("id")) {
      if (widget.bean.containsKey("_id")) {
        data["_id"] = widget.bean["_id"];
      } else {
        data["id"] = widget.bean["id"];
      }

      response = await SingleAccountPageState.ofApi(context).updateAppKey(data);
    } else {
      response = await SingleAccountPageState.ofApi(context).addAppKey(data);
    }
    EasyLoading.dismiss();

    if (response.success) {
      Navigator.of(context).pop(true);
    } else {
      response.message.toast();
    }
  }
}
