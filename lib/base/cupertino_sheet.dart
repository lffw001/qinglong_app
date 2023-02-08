import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/theme.dart';

class CupertinoSheer extends ConsumerWidget {
  final String title;
  final GestureTapCallback onTap;

  const CupertinoSheer({
    Key? key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      color: ref.watch(themeProvider).themeColor.settingBordorColor(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.titleColor(),
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget addDivider() {
  return const Divider(
    height: 0.5,
  );
}

void showMoreOperate(BuildContext context, List<Widget> list) {
  showCupertinoModalPopup(
    useRootNavigator: false,
    context: context,
    builder: (context1) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: Consumer(builder: (context, ref, c) {
          return ColoredBox(
            color: ref.watch(themeProvider).themeColor.settingBordorColor(),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...list,
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                    color: ref.watch(themeProvider).themeColor.pinColor(),
                  ),
                  CupertinoSheer(
                    title: "取消",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          );
        }),
      );
    },
  );
}
