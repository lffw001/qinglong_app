import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/utils/extension.dart';

import '../../base/theme.dart';
import 'scripts/script_code_detail_page.dart';

class FileDirectoryPage extends ConsumerStatefulWidget {
  final String path;

  const FileDirectoryPage({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  ConsumerState<FileDirectoryPage> createState() => _FileDirectoryPageState();
}

class _FileDirectoryPageState extends ConsumerState<FileDirectoryPage> {
  List<String> paths = [];

  @override
  void initState() {
    super.initState();
    readFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "查看文件",
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          bool isDirectly = Directory(paths[index]).existsSync();

          return ListTile(
            onTap: () async {
              if (isDirectly) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => FileDirectoryPage(
                      path: paths[index],
                    ),
                  ),
                );
              } else {
                try {
                  String content = await File(paths[index]).readAsString();
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ScriptCodeDetailPage(
                        title: paths[index].replaceAll(widget.path, "").replaceAll("/", ""),
                        content: content,
                        absPath: paths[index],
                        canRestore: true,
                      ),
                    ),
                  );
                } catch (e) {
                  e.toString().toast();
                }
              }
            },
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 15,
            ),
            trailing: !isDirectly
                ? const SizedBox.shrink()
                : Icon(
                    CupertinoIcons.right_chevron,
                    size: 16,
                    color: ref.watch(themeProvider).themeColor.descColor(),
                  ),
            title: Text(paths[index].replaceAll(widget.path, "").replaceAll("/", "")),
          );
        },
        itemCount: paths.length,
        separatorBuilder: (context, index) {
          return const Divider(
            indent: 15,
            height: 1,
          );
        },
      ),
    );
  }

  void readFiles() async {
    Stream<FileSystemEntity> fileList = Directory(widget.path).list();
    paths.clear();
    await for (FileSystemEntity fileSystemEntity in fileList) {
      paths.add(fileSystemEntity.path);
    }
    setState(() {});
  }
}
