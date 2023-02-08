import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

class CodeMirrorOptions {
  CodeMirrorOptions({
    this.mode = 'shell',
    this.readOnly = false,
  }) {
    theme = (SpUtil.getInt(spThemeStyle, defValue: modeWhite) == modeDark)
        ? "3024-night"
        : "neat";
    showLineNumber = SpUtil.getBool(spShowLine, defValue: false);
  }

  late final bool showLineNumber;
  final String mode;
  late final String theme;
  final bool readOnly;

  CodeMirrorOptions copyWith({
    String? mode,
    String? theme,
    bool? readOnly,
  }) {
    return CodeMirrorOptions(
      mode: mode ?? this.mode,
      readOnly: readOnly ?? this.readOnly,
    );
  }
}

class EditorController {
  EditorController({
    required this.setValue,
    required this.setOptions,
    required this.refresh,
  });

  final void Function(String val) setValue;
  final void Function(CodeMirrorOptions val) setOptions;
  final void Function() refresh;
}

abstract class CodeMirrorViewImpl extends ConsumerStatefulWidget {
  const CodeMirrorViewImpl({Key? key}) : super(key: key);
}

abstract class CodeMirrorViewImplState<T extends CodeMirrorViewImpl>
    extends ConsumerState<T> {}
