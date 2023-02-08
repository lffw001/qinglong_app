import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_bean.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';

import '../base/http/http.dart';
import '../base/ui/button.dart';



class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ScanPage> createState() => ScanPageState();
}

class ScanPageState extends ConsumerState<ScanPage> {
  bool scaning = false;

  var textProvider = StateProvider<String>((ref) => "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "扫描缺失的依赖",
        backCall: () {
          if (!scaning) {
            Navigator.of(context).pop();
          } else {
            showCupertinoDialog(
              context: context,
              useRootNavigator: false,
              builder: (childContext) => CupertinoAlertDialog(
                title: const Text("温馨提示"),
                content: const Text("当前正在扫描文件,确定退出吗?"),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(
                      "取消",
                      style: TextStyle(
                        color: Color(0xff999999),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(childContext).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      "确定",
                      style: TextStyle(
                        color: ref.watch(themeProvider).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(childContext).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      body: scanWidget(),
    );
  }

  void _startScan() async {
    List<String> jsInstalled = [];
    List<String> pyInstalled = [];
    Api api = Api(SingleAccountPageState.of(context)?.index ?? 0);
    List<TaskBean> list = ref
        .read(SingleAccountPageState.ofTaskProvider(context)(
                getProviderName(context))
            .notifier)
        .list;
    List<DependencyBean> jsList = [];
    List<DependencyBean> pyList = [];
    var jsDep = await api.dependencies("nodejs");

    if (jsDep.success) {
      jsList.addAll(jsDep.bean ?? []);
    }
    var pyDep = await api.dependencies("python3");
    if (pyDep.success) {
      pyList.addAll(pyDep.bean ?? []);
    }

    for (TaskBean bean in list) {
      if (scaning == false) break;
      if (bean.command == null || bean.command!.isEmpty) continue;
      String command = bean.command!.trim().split(" ").last;
      if (!command.endsWith(".js") &&
          !command.endsWith(".ts") &&
          !command.endsWith(".py")) continue;

      _updateDescText("正在扫描: $command");
      HttpResponse<String> response =
          await SingleAccountPageState.ofApi(context).inTimeLog(bean.sId!);

      String text = "";

      if (response.success &&
          response.bean != null &&
          response.bean!.isNotEmpty) {
        text = response.bean ?? "";
        String? found = foundReg(command, text);
        if (found != null && found.isNotEmpty) {
          var result = await autoInstallFounded(api, found, command);
          if (result == true) {
            if (command.endsWith(".py")) {
              pyInstalled.add(found);
            } else {
              jsInstalled.add(found);
            }
          }
        }
      }
    }

    scaning = false;
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (jsInstalled.isNotEmpty || pyInstalled.isNotEmpty) {
          showCupertinoDialog(
            context: context,
            useRootNavigator: false,
            builder: (childContext) => CupertinoAlertDialog(
              title: const Text("本次已安装如下依赖"),
              content: Text(
                  "NodeJS:\n ${jsInstalled.join("\n").toString()} \n Python3:\n ${pyInstalled.join("\n").toString()}"),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    "知道了",
                    style: TextStyle(
                      color: ref.watch(themeProvider).primaryColor,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(childContext).pop();
                  },
                ),
              ],
            ),
          );
        } else {
          "暂未发现缺失的依赖".toast();
        }
      },
    );
    setState(() {});
  }

  Widget scanWidget() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Lottie.asset(
              'assets/scan.json',
              animate: scaning,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 50,
            child: Consumer(
              builder: (context, ref, _) {
                String text = ref.watch(textProvider);
                return Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 12,
                    color: ref.watch(themeProvider).themeColor.descColor(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: ButtonWidget(
              title: !scaning ? "开始扫描" : "停止扫描",
              onTap: () {
                if (scaning == true) {
                  scaning = false;
                  setState(() {});
                  ref.read(textProvider.notifier).state = "";
                } else {
                  scaning = true;
                  setState(() {});
                  _startScan();
                }
              },
            ),
          )
        ],
      ),
    );
  }

  void _updateDescText(String s) {
    ref.read(textProvider.notifier).state = s;
  }

  static Future<bool> autoInstallFounded(
      Api api, String found, String command) async {
    if (found.contains(".") || found.contains("/")) return false;
    if (command.endsWith(".py")) {
      List<DependencyBean> pyList = [];
      var pyDep = await api.dependencies("python3");
      if (pyDep.success) {
        pyList.addAll(pyDep.bean ?? []);
      }
      DependencyBean bean = pyList.firstWhere(
          (element) => element.name == found,
          orElse: () => DependencyBean());
      if (bean.name == null || bean.name!.isEmpty) {
        await api.addDependency(
          [
            {
              "name": found,
              "type": 1,
            }
          ],
        );
        return true;
      }
    } else {
      var jsDep = await api.dependencies("nodejs");
      List<DependencyBean> jsList = [];

      if (jsDep.success) {
        jsList.addAll(jsDep.bean ?? []);
      }
      DependencyBean bean = jsList.firstWhere(
          (element) => element.name == found,
          orElse: () => DependencyBean());

      if (bean.name == null || bean.name!.isEmpty) {
        await api.addDependency(
          [
            {
              "name": found,
              "type": 0,
            }
          ],
        );
        return true;
      }
    }
    return false;
  }

  static String? foundReg(String command, String text) {
    if (text.isEmpty) return null;

    if (command.isEmpty) return null;

    String? founded;
    if (command.endsWith(".py")) {
      RegExp firstReg = RegExp(r"No module named '(.*)'");

      var firstMatch = firstReg.firstMatch(text);
      int firstStart = firstMatch?.start ?? -1;
      int firstEnd = firstMatch?.end ?? -1;

      if (firstStart >= 0 && firstEnd >= 0) {
        founded = text.substring(firstStart + 17, firstEnd - 1);
      } else {
        RegExp secondReg = RegExp(r'No module named "(.*)"');

        var secondMatch = secondReg.firstMatch(text);
        int secondStart = secondMatch?.start ?? -1;
        int secondEnd = secondMatch?.end ?? -1;
        if (secondStart >= 0 && secondEnd >= 0) {
          founded = text.substring(secondStart + 17, secondEnd - 1);
        }
      }
    } else {
      RegExp firstReg = RegExp(r"Cannot find module '(.*)'");

      var firstMatch = firstReg.firstMatch(text);
      int firstStart = firstMatch?.start ?? -1;
      int firstEnd = firstMatch?.end ?? -1;

      if (firstStart >= 0 && firstEnd >= 0) {
        founded = text.substring(firstStart + 20, firstEnd - 1);
      } else {
        RegExp secondReg = RegExp(r'Cannot find module "(.*)"');

        var secondMatch = secondReg.firstMatch(text);
        int secondStart = secondMatch?.start ?? -1;
        int secondEnd = secondMatch?.end ?? -1;
        if (secondStart >= 0 && secondEnd >= 0) {
          founded = text.substring(secondStart + 20, secondEnd - 1);
        }
      }
    }

    if (founded != null && founded.isNotEmpty) {
      if (founded.contains((".")) || founded.contains("/")) {
        return null;
      } else {
        return founded;
      }
    }

    return null;
  }
}
