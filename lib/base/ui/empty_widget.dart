import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/theme.dart';

class EmptyWidget extends ConsumerWidget {
  const EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "暂无数据",
            style: TextStyle(
              fontSize: 14,
              color: ref.watch(themeProvider).themeColor.descColor(),
            ),
          ),
        ],
      ),
    );
  }
}
