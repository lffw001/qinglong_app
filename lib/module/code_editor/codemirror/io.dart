import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../base/theme.dart';
import 'impl.dart';

class CodeMirrorView extends CodeMirrorViewImpl {
  final CodeMirrorOptions options;

  final ValueChanged<EditorController> onCreate;

  final Function(String val) onValue;

  const CodeMirrorView({
    Key? key,
    required this.options,
    required this.onCreate,
    required this.onValue,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return CodeMirrorViewState();
  }
}

class CodeMirrorViewState extends CodeMirrorViewImplState<CodeMirrorView> {
  String getHtml(String raw) {
    String _html = raw;
    _html = _html.replaceAll('VERSION', '5.65.6');
    _html = _html.replaceAll('EDITOR_THEME', widget.options.theme);
    _html = _html.replaceAll('EDITOR_MODE', widget.options.mode);
    return Uri.dataFromString(_html, mimeType: 'text/html').toString();
  }

  WebViewController? _controller;

  bool readOnly = false;
  bool isLoaded = false;

  static bool isLoadedJs = false;
  bool isShowSearch = false;

  Future<void> showSearchBar() async {
    if (isShowSearch) {
      await _controller?.runJavascript(
        'clearSearchText()',
      );
    } else {
      await _controller?.runJavascript(
        'searchText()',
      );
    }
    isShowSearch = !isShowSearch;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return FutureBuilder<String>(
        future: rootBundle.loadString('assets/codemirror.html'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: LoadingWidget());
          }
          return LayoutBuilder(
            builder: (context, dimens) {
              return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                if (isLoaded) {
                  _controller?.runJavascript(
                    'editor.setSize(${dimens.maxWidth},${dimens.maxHeight})',
                  );
                }

                return WebView(
                  backgroundColor: ref.watch(themeProvider).themeColor.codeBgColor(),
                  debuggingEnabled: true,
                  initialUrl: getHtml(snapshot.data ?? ""),
                  onWebViewCreated: (controller) {
                    if (MultiAccountPageState.useAction().isEmpty) {
                      if (!isLoadedJs) {
                        isLoadedJs = true;
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          EasyLoading.show(status: "加载中");
                        });
                      }
                    }
                    _controller = controller;
                  },
                  onPageFinished: (url) {
                    _controller?.runJavascript(
                      'editor.setSize(${dimens.maxWidth},${dimens.maxHeight})',
                    );
                    widget.onCreate(EditorController(
                      setOptions: (val) async {
                        readOnly = val.readOnly;
                        _controller?.runJavascript(
                          'editor.setSize(${dimens.maxWidth},${dimens.maxHeight})',
                        );

                        await _controller?.runJavascript(
                          'editor.setOption("mode", "${val.mode}")',
                        );
                        await _controller?.runJavascript(
                          'editor.setOption("theme", "${val.theme}")',
                        );
                        await _controller?.runJavascript(
                          'editor.setOption("readOnly", ${val.readOnly ? '\"nocursor\"' : false})',
                        );

                        await _controller?.runJavascript(
                          'editor.setOption("lineNumbers", ${val.showLineNumber})',
                        );
                        await Future.delayed(
                          const Duration(milliseconds: 200),
                        );
                        await _controller?.runJavascript(
                          'editor.refresh()',
                        );
                        await EasyLoading.dismiss();
                        if (widget.options.mode != val.mode || widget.options.theme != val.theme) {
                          await _controller?.loadUrl(getHtml(snapshot.data ?? ""));
                        }
                      },
                      setValue: (val) async {
                        TextPainter painter = TextPainter(
                          text: TextSpan(
                            text: val,
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          textDirection: TextDirection.ltr,
                        );
                        painter.layout(
                          maxWidth: MediaQuery.of(context).size.width,
                        );
                        isLoaded = true;
                        final raw = Uri.encodeComponent(val);
                        _controller?.runJavascript('editor.setValue(decodeURIComponent("$raw"))');
                      },
                      refresh: () async {
                        const delay = Duration(milliseconds: 50);
                        await Future.delayed(delay);
                        _controller?.runJavascript(
                          'editor.refresh()',
                        );
                      },
                    ));
                  },
                  javascriptMode: JavascriptMode.unrestricted,
                  javascriptChannels: {
                    JavascriptChannel(
                      name: 'MessageInvoker',
                      onMessageReceived: (event) => widget.onValue(event.message),
                    ),
                  },
                );
              });
            },
          );
        });
  }
}
