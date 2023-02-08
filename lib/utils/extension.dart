import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';

extension ContextExt on BuildContext {
  T read<T>(ProviderBase<T> provider) {
    return ProviderScope.containerOf(this, listen: false).read(provider);
  }
}

extension StringExt on String? {
  void toast() {
    if (this == null || this!.isEmpty) return;
    Fluttertoast.showToast(
      msg: this!,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
    );
  }

  void toast2() {
    if (this == null || this!.isEmpty) return;
    Fluttertoast.showToast(
      msg: this!,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
    );
  }

  void log() {
    logger.i(this);
  }
}
