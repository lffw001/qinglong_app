import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';

import '../base/theme.dart';



class PoetPage extends ConsumerWidget {
  final Map<String, dynamic> data;

  const PoetPage({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      backgroundColor: ref.watch(themeProvider).themeColor.bg2Color(),
      appBar: QlAppBar(
        title: data["data"]?["origin"]?["title"]?.toString() ?? "",
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 10,
                bottom: 0,
              ),
              child: Text(
                "${data["data"]?["origin"]?["author"]?.toString() ?? ""} - ${data["data"]?["origin"]?["dynasty"]?.toString() ?? ""}",
                maxLines: 1,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: ref.watch(themeProvider).themeColor.descColor(),
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: ref.watch(themeProvider).themeColor.blackAndWhite(),
              ),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              margin: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 10,
                top: 5,
              ),
              child: SelectableText(
                (data["data"]?["origin"]?["content"] as List?)?.join("\n\n").toString() ?? "",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 14,
                ),
              ),
            ),
            Visibility(
              visible: data["data"]?["origin"]?["translate"] != null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: Text(
                  "译文",
                  maxLines: 1,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: data["data"]?["origin"]?["translate"] != null,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: ref.watch(themeProvider).themeColor.blackAndWhite(),
                ),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 10,
                  top: 5,
                ),
                child: SelectableText(
                  (data["data"]?["origin"]?["translate"] as List?)?.join("\n\n").toString() ?? "",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.titleColor(),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 10,
              ),
              child: SelectableText(
                "数据来源:https://www.jinrishici.com",
                maxLines: 1,
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
    );
  }
}
