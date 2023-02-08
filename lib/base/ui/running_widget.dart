import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';



class RunningWidget extends ConsumerWidget {
  const RunningWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      decoration: BoxDecoration(
        color: ref.watch(themeProvider).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: ref.watch(themeProvider).primaryColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingWidget(
            color: ref.watch(themeProvider).primaryColor,
            size: 12,
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            "运行中",
            style: TextStyle(
              color: ref.watch(themeProvider).primaryColor,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
