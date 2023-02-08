import 'package:flutter/material.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/utils/icloud_utils.dart';

class IcloudFilePage extends StatefulWidget {
  const IcloudFilePage({Key? key}) : super(key: key);

  @override
  _IcloudFilePageState createState() => _IcloudFilePageState();
}

class _IcloudFilePageState extends State<IcloudFilePage> {
  List<ICloudFile> list = [];

  @override
  void initState() {
    super.initState();
    getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "iCloud文件",
      ),
      body: ListView.builder(
        itemBuilder: (c, index) {
          return ListTile(
            title: Text(
              list[index].relativePath,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          );
        },
        itemCount: list.length,
      ),
    );
  }

  void getFiles() async {
    final iCloudStorage = await ICloudStorage.getInstance(ICloudUtils.containerID);
    final fileList = await iCloudStorage.gatherFiles(onUpdate: (stream) {});
    list.clear();
    list.addAll(fileList);
    setState(() {});
  }
}
