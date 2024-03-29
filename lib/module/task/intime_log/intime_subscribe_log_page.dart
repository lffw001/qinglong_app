import 'dart:async';
import 'dart:ui';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:share_plus/share_plus.dart';

import '../../../base/commit_button.dart';

class InTimeSubscribeLogPage extends StatefulWidget {
  final int cronId;
  final bool needTimer;
  final String title;

  const InTimeSubscribeLogPage(this.cronId, this.needTimer, this.title, {Key? key}) : super(key: key);

  @override
  _InTimeSubscribeLogPageState createState() => _InTimeSubscribeLogPageState();
}

class _InTimeSubscribeLogPageState extends State<InTimeSubscribeLogPage> with LazyLoadState<InTimeSubscribeLogPage> {
  Timer? _timer;

  String? content;

  ScrollController? controller = ScrollController();

  @override
  void initState() {
    super.initState();
    getLogData();
  }

  bool alwaysAuthScroll = false;

  bool isRequest = false;
  bool canRequest = true;

  getLogData() async {
    if (!canRequest) return;
    if (isRequest) return;
    isRequest = true;
    HttpResponse<String> response = await SingleAccountPageState.ofApi(context).inTimeSubscribeLog(widget.cronId);
    if (response.success) {
      content = response.bean;
      if (alwaysAuthScroll) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          if ((controller?.hasClients ?? false)) {
            controller!.jumpTo(controller!.position.maxScrollExtent);
          }
        });
      }
      setState(() {});
    }
    isRequest = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                      primary: true,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getLogData();
      });
    }
  }
}
