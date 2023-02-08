import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/theme.dart';

class InAppPurchasePage extends ConsumerStatefulWidget {
  final bool fromDirectly;

  const InAppPurchasePage({
    Key? key,
    this.fromDirectly = false,
  }) : super(key: key);

  @override
  ConsumerState<InAppPurchasePage> createState() => _InAppPurchasePageState();
}

class _InAppPurchasePageState extends ConsumerState<InAppPurchasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "APP功能介绍",
        canBack: true,
      ),
      body: SingleChildScrollView(
        primary: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "高级功能",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const BasicFuncWidget(
                title: "多账号同时登录不限账号个数",
                advance: true,
              ),
              const SizedBox(
                height: 10,
              ),
              const BasicFuncWidget(
                title: "使用Face ID解锁APP",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "支持QuickActions,桌面长按图标可以一键运行所有任务,快速编辑配置文件",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "支持环境变量,所有配置文件,订阅管理等文件实时备份,最高可查看历史100天的备份文件",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "支持白色主题和黑色主题",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "支持剪切板识别,自动填入配置文件",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "支持修改App内字体大小",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "支持远程上传文件",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "账号历史记录保存无上限",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "多账号同时登录,最多3个账号",
                advance: true,
              ),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "轻触任意页面标题,即可打开多账号切换页面",
                advance: true,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "基础功能",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const BasicFuncWidget(title: "对定时任务进行各项操作"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(title: "管理环境变量,增删改,排序等"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(title: "查看,编辑配置文件"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(title: "查看,编辑脚本文件"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(title: "操作服务器依赖管理"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(title: "查看任务日志"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(title: "查看登录记录"),
              const SizedBox(
                height: 5,
              ),
              const BasicFuncWidget(
                title: "账号历史记录最多保存5个",
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BasicFuncWidget extends ConsumerWidget {
  final String title;
  final bool advance;

  const BasicFuncWidget({
    Key? key,
    required this.title,
    this.advance = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Row(
      children: [
        Image.asset(
          advance ? "assets/images/icon_b.png" : "assets/images/icon_a.png",
          fit: BoxFit.cover,
          width: 13,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: ref.watch(themeProvider).themeColor.descColor(),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
