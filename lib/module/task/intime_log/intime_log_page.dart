import 'dart:async';
import 'dart:ui';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/module/scan_page.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../../base/commit_button.dart';
import '../../../base/http/api.dart';

class InTimeLogPage extends ConsumerStatefulWidget {
  final String cronId;
  final bool needTimer;
  final String title;
  final String? command;

  const InTimeLogPage(
    this.cronId,
    this.needTimer,
    this.title, {
    Key? key,
    this.command,
  }) : super(key: key);

  @override
  _InTimeLogPageState createState() => _InTimeLogPageState();
}

class _InTimeLogPageState extends ConsumerState<InTimeLogPage> with LazyLoadState<InTimeLogPage> {
  Timer? _timer;

  String? content;

  bool isRequest = false;
  bool canRequest = true;
  bool alwaysAuthScroll = false;

  ScrollController? controller = ScrollController();
  bool showVIPReminder = false;

  getLogData() async {
    if (!canRequest) return;
    if (isRequest) return;
    if (!mounted) return;
    isRequest = true;
    HttpResponse<String> response = await SingleAccountPageState.ofApi(context).inTimeLog(widget.cronId);

    if (!mounted) return;
    isRequest = false;
    if (response.success) {
      if (!mounted) return;
      content = response.bean;
      if (content == null || content!.isEmpty) return;

      String? found = ScanPageState.foundReg(widget.command ?? "", content ?? "");
      if (found != null &&
          found.isNotEmpty &&
          widget.command != null &&
          (widget.command!.endsWith(".js") || widget.command!.endsWith(".ts") || widget.command!.endsWith(".py")) &&
          SpUtil.getInt(spVIP, defValue: typeNormal) != typeNormal) {
        Api api = Api(SingleAccountPageState.of(context)?.index ?? 0);
        var result = await ScanPageState.autoInstallFounded(api, found, widget.command!);
        if (result == true) {
          "已安装依赖 $found".toast();
        }
      }
      if (alwaysAuthScroll) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if (!mounted) return;
          if ((controller?.hasClients ?? false)) {
            controller!.animateTo(controller!.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.linear);
          }
        });
      }
      if (!mounted) return;
      setState(() {});
    } else {
      if (!hasToastedFailed) {
        hasToastedFailed = true;
        response.message.toast();
      }
    }
  }

  bool hasToastedFailed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              alwaysAuthScroll = !alwaysAuthScroll;
            });
          },
          elevation: 2,
          child: Icon(
            alwaysAuthScroll ? CupertinoIcons.pause_circle : CupertinoIcons.play_circle,
          ),
        ),
        appBar: QlAppBar(
          canBack: true,
          actions: [
            CommitButton(
              title: "分享",
              onTap: () {
                Share.share(content ?? "");
              },
            ),
          ],
          title: widget.title,
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
            child: (content == null)
                ? const Center(
                    child: LoadingWidget(),
                  )
                : CupertinoScrollbar(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ExtendedText(
                            content!,
                            selectionHeightStyle: BoxHeightStyle.max,
                            selectionEnabled: true,
                            selectionWidthStyle: BoxWidthStyle.max,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  @override
  void onLazyLoad() {
    alwaysAuthScroll = SpUtil.getBool(spLogAutoJump2Bottom, defValue: false);
    if (widget.needTimer) {
      _timer = Timer.periodic(
        const Duration(seconds: 2),
        (timer) {
          getLogData();
        },
      );
      getLogData();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getLogData();
      });
    }
  }
}

