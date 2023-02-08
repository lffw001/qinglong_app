import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:qinglong_app/utils/utils.dart';
import 'package:path/path.dart' as path;



class ICloudUtils {
  static bool remindError = false;

  static String now() {
    return Utils.formatMessageTime(DateTime.now().millisecondsSinceEpoch);
  }

  static const containerID = "iCloud.work.newtab.ql";
  int index;

  ICloudUtils(this.index);

  Future<void> asyncSubscribe(String list, {bool focusUpdate = false}) async {
    try {
      if (list.isEmpty) return;
      if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) return;
      if (SpUtil.getBool(spICloud, defValue: true) == false &&
          focusUpdate == false) return;

      bool exist = await existContent(
          await FileUtil(index).getSubscribeDirectory(), list);

      if (!exist) {
        await FileUtil(index).writeSubscribe(list);
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<bool> existContent(Directory d, String content) async {
    try {
      await for (FileSystemEntity fileSystemEntity in d.list()) {
        if ((await File(fileSystemEntity.path).readAsString()) == content) {
          return true;
        }
      }
      return false;
    } catch (e) {}
    return false;
  }

  Future<void> asyncEnv(List<EnvBean> list, {bool focusUpdate = false}) async {
    try {
      if (list.isEmpty) return;
      if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) return;
      if (SpUtil.getBool(spICloud, defValue: true) == false &&
          focusUpdate == false) return;
      bool exist = await existContent(
          await FileUtil(index).getEnvDirectory(), jsonEncode(list));

      if (!exist) {
        await FileUtil(index).writeEnv(jsonEncode(list));
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> asyncConfig(String? title, String? content,
      {bool focusUpdate = false}) async {
    try {
      if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) return;

      if (content == null || content.isEmpty) return;
      if (SpUtil.getBool(spICloud, defValue: true) == false &&
          focusUpdate == false) return;

      bool exist = await existContent(
          await FileUtil(index)
              .getConfigHolDirectory(title ?? "nameNotFound.sh"),
          content);

      if (!exist) {
        await FileUtil(index).writeConfig(title ?? "nameNotFound.sh", content);
      }
    } catch (e) {}
  }

  void restoreEnv(String? path) async {
    if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) return;

    if (path == null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        if (!result.files.single.path!.endsWith(FileUtil.env)) {
          "只支持 .${FileUtil.env} 结尾的文件".toast();
        } else {
          _handleRestoreEnv(result.files.single.path!);
        }
      }
    } else {
      _handleRestoreEnv(path);
    }
  }

  void restoreSubscribe(String? path) async {
    if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) return;
    if (path == null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        if (!result.files.single.path!.endsWith(FileUtil.subscribe)) {
          "只支持 .${FileUtil.subscribe} 结尾的文件".toast();
        } else {
          _handleRestoreSubscribe(result.files.single.path!);
        }
      }
    } else {
      _handleRestoreSubscribe(path);
    }
  }

  void restoreConfig(String? path) async {
    if (SpUtil.getInt(spVIP, defValue: typeNormal) == typeNormal) return;
    if (path == null) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        if (!result.files.single.path!.endsWith(FileUtil.config)) {
          "只支持 .${FileUtil.config} 结尾的文件".toast();
        } else {
          String p = result.files.single.path!;
          String title = "nameNotFound.sh";

          try {
            //获取倒数第二个/的内容
            List<String> temp = p.split("/");
            if (temp.length > 1) {
              title = temp[temp.length - 2];
            }
            _handleRestoreConfig(title, p);
          } catch (e) {}
        }
      }
    } else {
      String title = "nameNotFound.sh";
      try {
        //获取倒数第二个/的内容
        List<String> temp = path.split("/");
        if (temp.length > 1) {
          title = temp[temp.length - 2];
        }
        _handleRestoreConfig(title, path);
      } catch (e) {}
    }
  }

  void _handleRestoreSubscribe(String localSubscribePath) async {
    try {
      final file = File(localSubscribePath);
      final contents = await file.readAsString();

      List<Map<String, dynamic>> list = [];

      List<dynamic> data = jsonDecode(contents);

      list.addAll(data.map((e) {
        return e as Map<String, dynamic>;
      }).toList());

      for (var value in list) {
        value.remove("id");
        value.remove("status");
        value.remove("pid");
        value.remove("is_disabled");
        value.remove("log_path");
        value.remove("createdAt");
        value.remove("updatedAt");

        await Api(index).addSubscribes(value);
      }
      "已还原，请刷新订阅管理列表查看".toast();
    } catch (e) {
      e.toString().toast();
    }
  }

  void _handleRestoreEnv(String localEnvPath) async {
    try {
      final file = File(localEnvPath);
      final contents = await file.readAsString();

      List<EnvBean> list = [];

      List<dynamic> data = jsonDecode(contents);

      list.addAll(data.map((e) => EnvBean.fromJson(e)).toList());

      var result = await Api(index).envs("");

      if (result.success) {
        if (result.bean != null && result.bean!.isNotEmpty) {
          List<String> temp = result.bean!.map((e) => e.sId!).toList();
          await Api(index).delEnvs(temp);
        }
      }

      for (var value in list) {
        if (value.name == null || value.value == null) continue;

        await Api(index).addEnv(
          value.name!,
          value.value!,
          value.remarks ?? "",
        );
      }
      "已还原，请刷新环境变量列表查看".toast();
    } catch (e) {
      e.toString().toast();
    }
  }

  void _handleRestoreConfig(String title, String localConfigPath) async {
    try {
      final file = File(localConfigPath);
      final contents = await file.readAsString();

      Api(index).saveFile(title, contents);
      "已还原$title文件".toast();
    } catch (e) {
      e.toString().toast();
    }
  }
}

class FileUtil {
  int index;

  FileUtil(this.index);

  static const String config = "config";
  static const String env = "env";
  static const String subscribe = "subscribe";
  static const String downloadFiles = "download_files";

  String today() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String time() {
    return DateFormat('HH-mm-ss').format(DateTime.now());
  }

  String getHost() {
    String? temp =
        getIt<UserInfoViewModel>(instanceName: index.toString()).host;

    if (temp == null) return "";

    return temp
        .trim()
        .replaceAll("http://", "")
        .replaceAll("https://", "")
        .replaceAll("/", "-")
        .replaceAll("\\", "-")
        .replaceAll(":", "-")
        .replaceAll("*", "_")
        .replaceAll("?", "_")
        .replaceAll("<", "_")
        .replaceAll(">", "_")
        .replaceAll("|", "_");
  }

  Future<String> get downloadFilePath async {
    Directory directory;
    if (Platform.isAndroid) {
      var temp = await getExternalStorageDirectory();

      if (temp != null) {
        directory = temp;
      } else {
        directory = Directory("storage/emulated/0");
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    return directory.path;
  }

  Future<String> get sourcePath async {
    Directory directory;
    if (Platform.isAndroid) {
      directory = await getApplicationSupportDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    return directory.path;
  }

  Future<String> get localPath async {
    return (await sourcePath) + path.separator + getHost();
  }

  Future<Directory> getSubscribeDirectory() async {
    final path = await localPath;
    Directory f = Directory('$path/${today()}/$subscribe/');
    if (!(await f.exists())) {
      await f.create(recursive: true);
    }
    return f;
  }

  Future<File> get _localSubscribeFile async {
    final path = await localPath;
    File f = File('$path/${today()}/$subscribe/${time()}.$subscribe');
    if (f.existsSync()) {
      f.deleteSync();
    }
    return f;
  }

  Future<Directory> getEnvDirectory() async {
    final path = await localPath;
    Directory f = Directory('$path/${today()}/$env/');
    if (!(await f.exists())) {
      await f.create(recursive: true);
    }
    return f;
  }

  Future<File> get _localEnvFile async {
    final path = await localPath;
    File f = File('$path/${today()}/$env/${time()}.$env');
    if (f.existsSync()) {
      f.deleteSync();
    }
    return f;
  }

  Future<File> writeDownloadFile(String suffix, String content) async {
    final path = await downloadFilePath;
    File f;
    if (Platform.isAndroid) {
      f = File('$path/qinglong_app/$downloadFiles/$suffix');
    } else {
      f = File('$path/$downloadFiles/$suffix');
    }
    if (f.existsSync()) {
      f.deleteSync();
    }
    await f.create(recursive: true);
    return f.writeAsString(content);
  }

  Future<File> writeSubscribe(String content) async {
    final file = await _localSubscribeFile;
    await file.create(recursive: true);
    return file.writeAsString(content);
  }

  Future<File> writeEnv(String content) async {
    final file = await _localEnvFile;
    await file.create(recursive: true);
    return file.writeAsString(content);
  }

  Future<Directory> getConfigHolDirectory(String name) async {
    final path = await localPath;
    Directory f = Directory('$path/${today()}/$config/$name/');
    if (!(await f.exists())) {
      await f.create(recursive: true);
    }
    return f;
  }

  Future<File> locaConfigHolFile(String title) async {
    final path = await localPath;
    File f = File('$path/${today()}/$config/$title/${time()}.$config');
    if (f.existsSync()) {
      f.deleteSync();
    }
    return f;
  }

  Future<File> writeConfig(String title, String content) async {
    final file = await locaConfigHolFile(title);
    await file.create(recursive: true);
    return file.writeAsString(content);
  }
}
