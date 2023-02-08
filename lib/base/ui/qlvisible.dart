import 'dart:io';

import 'package:flutter/material.dart';



class QlVisible extends StatelessWidget {
  final Widget child;
  final Widget? childReplace;

  const QlVisible({
    Key? key,
    required this.child,
    this.childReplace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (childReplace != null && Platform.isAndroid) return childReplace!;
    return Visibility(
      child: child,
      visible: Platform.isIOS,
    );
  }
}
