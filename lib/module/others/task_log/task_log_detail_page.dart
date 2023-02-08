import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/utils/extension.dart';


class TaskLogDetailPage extends ConsumerStatefulWidget {
  final String title;
  final String path;

  const TaskLogDetailPage({
    Key? key,
    required this.title,
    required this.path,
  }) : super(key: key);

  @override
  _TaskLogDetailPageState createState() => _TaskLogDetailPageState();
}

class _TaskLogDetailPageState extends ConsumerState<TaskLogDetailPage>
    with LazyLoadState<TaskLogDetailPage> {
  String? content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: "任务日志详情",
      ),
      body: content == null
          ? const Center(child: LoadingWidget())
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: SelectableText(
                (content == null || content!.isEmpty) ? "暂无数据" : content!,
                selectionHeightStyle: BoxHeightStyle.max,
                selectionWidthStyle: BoxWidthStyle.max,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
    );
  }

  Future<void> loadData() async {
    HttpResponse<String> response =
        await SingleAccountPageState.ofApi(context).taskLogDetail(
      widget.title,
      widget.path,
    );

    if (response.success) {
      content = response.bean;
      setState(() {});
    } else {
      response.message?.toast();
    }
  }

  @override
  void onLazyLoad() {
    loadData();
  }
}
