import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/enable_widget.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';

import 'login_log_bean.dart';


class LoginLogPage extends ConsumerStatefulWidget {
  const LoginLogPage({Key? key}) : super(key: key);

  @override
  _LoginLogPageState createState() => _LoginLogPageState();
}

class _LoginLogPageState extends ConsumerState<LoginLogPage>
    with LazyLoadState<LoginLogPage> {
  List<LoginLogBean> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: "登录日志",
      ),
      body: list.isEmpty
          ? const Center(
              child: LoadingWidget(),
            )
          : ListView.separated(
              primary: true,
              itemBuilder: (context, index) {
                LoginLogBean item = list[index];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(
                                Size.fromWidth(
                                    MediaQuery.of(context).size.width / 1.8),
                              ),
                              child: Text(
                                "${item.address}",
                                style: TextStyle(
                                  color: ref
                                      .watch(themeProvider)
                                      .themeColor
                                      .titleColor(),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 2,
                              ),
                              child: StatusWidget(
                                title:  item.status == 0
                                    ? "成功"
                                    : "失败",
                                color:  item.status == 0
                                    ? ref.watch(themeProvider).primaryColor
                                    : const Color(0xffFB5858),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SelectableText(
                          "${item.ip}",
                          selectionWidthStyle: BoxWidthStyle.max,
                          selectionHeightStyle: BoxHeightStyle.max,
                          style: TextStyle(
                            color:
                                ref.watch(themeProvider).themeColor.descColor(),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        Utils.formatMessageTime(item.timestamp ?? 0),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              ref.watch(themeProvider).themeColor.descColor(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                  ],
                );
              },
              itemCount: list.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  indent: 15,
                  height: 1,
                );
              },
            ),
    );
  }

  Future<void> loadData() async {
    HttpResponse<List<LoginLogBean>> response =
        await SingleAccountPageState.ofApi(context).loginLog();

    if (response.success) {
      if (response.bean == null || response.bean!.isEmpty) {
        "暂无数据".toast();
      }
      list.clear();
      list.addAll(response.bean ?? []);
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
