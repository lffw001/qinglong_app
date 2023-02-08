import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/commit_button.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../base/sp_const.dart';
import '../../utils/sp_utils.dart';



class TextSizePage extends ConsumerStatefulWidget {
  const TextSizePage({Key? key}) : super(key: key);

  @override
  ConsumerState<TextSizePage> createState() => _TextSizePageState();
}

class _TextSizePageState extends ConsumerState<TextSizePage> {
  double textScaleFactor = 1.0;

  @override
  void initState() {
    textScaleFactor = SpUtil.getDouble(spTextScaleFactor, defValue: 1.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromWindow(window),
      child: Scaffold(
        backgroundColor: ref.watch(themeProvider).themeColor.bg2Color(),
        appBar: QlAppBar(
          canBack: true,
          title: "设置字体大小",
          actions: [
            CommitButton(
              onTap: () {
                context.findAncestorStateOfType<QlAppState>()?.updateTextScaleFactor(textScaleFactor);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            MediaQuery(
              data: MediaQueryData.fromWindow(window).copyWith(
                textScaleFactor: textScaleFactor,
              ),
              child: Material(
                color: ref.watch(themeProvider).themeColor.settingBgColor(),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints.loose(
                                          Size.fromWidth(MediaQuery.of(context).size.width * 0.45),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Text(
                                            "测试任务",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: ref.watch(themeProvider).themeColor.titleColor(),
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                    ],
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: Text(
                                    "6/12 12:00",
                                    maxLines: 1,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      color: ref.watch(themeProvider).themeColor.descColor(),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: Text(
                                "10 1-23/3 * * *",
                                maxLines: 1,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: Text(
                                "task test/test.js",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ColoredBox(
              color: ref.watch(themeProvider).currentTheme.scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const Text(
                    "A",
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () {
                      textScaleFactor = 1;
                      setState(() {});
                    },
                    child: Text(
                      "标准",
                      style: TextStyle(
                        color: ref.watch(themeProvider).primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    "A",
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              width: MediaQuery.of(context).size.width,
              color: ref.watch(themeProvider).currentTheme.scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 80,
                  child: CupertinoSlider(
                    key: const Key('slider'),
                    value: textScaleFactor,
                    max: 1.4,
                    min: 0.6,
                    onChangeStart: (double value) {},
                    onChangeEnd: (double value) {},
                    onChanged: (double value) {
                      textScaleFactor = value;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
