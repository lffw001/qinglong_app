import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/loading_widget.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'base_viewmodel.dart';
import 'ui/button.dart';

class BaseStateWidget<T extends BaseViewModel> extends ConsumerStatefulWidget {
  final Widget Function(WidgetRef context, T value, Widget? child) builder;
  final ChangeNotifierProvider<T> model;
  final Widget? child;
  final Function(T)? onReady;
  final Function(T)? onPre;
  final bool lazyLoad;

  const BaseStateWidget({
    Key? key,
    required this.builder,
    required this.model,
    this.child,
    this.onReady,
    this.onPre,
    this.lazyLoad = true,
  }) : super(key: key);

  @override
  _BaseStateWidgetState<T> createState() => _BaseStateWidgetState<T>();
}

class _BaseStateWidgetState<T extends BaseViewModel>
    extends ConsumerState<BaseStateWidget<T>>
    with LazyLoadState<BaseStateWidget<T>> {
  @override
  Widget build(BuildContext context) {
    var viewModel = ref.watch<T>(widget.model);
    if (viewModel.failedToast != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        (viewModel.failedToast ?? "").toast();
        viewModel.clearToast();
      });
    }
    if (viewModel.currentState == PageState.CONTENT) {
      return widget.builder(ref, viewModel, widget.child);
    }

    if (viewModel.currentState == PageState.LOADING) {
      return Container(
        alignment: Alignment.center,
        child: const LoadingWidget(),
      );
    }

    if (viewModel.currentState == PageState.FAILED) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Text(
                viewModel.failReason ?? "",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.descColor(),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                onTap: () {
                  viewModel.retry(
                    context,
                    showLoading: true,
                  );
                },
                title: "重试",
              ),
            ),
          ],
        ),
      );
    }

    if (viewModel.currentState == PageState.EMPTY) {
      return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Text(
                "暂无数据",
                style: TextStyle(
                  color: ref.watch(themeProvider).themeColor.descColor(),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              width: 100,
              child: ButtonWidget(
                onTap: () {
                  viewModel.retry(
                    context,
                    showLoading: true,
                  );
                },
                title: "重试",
              ),
            ),
          ],
        ),
      );
    }

    return Container();
  }

  @override
  void onLazyLoad() {
    if (widget.onReady != null && widget.lazyLoad) {
      widget.onReady!(ref.read<T>(widget.model));
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.onPre != null) {
      widget.onPre!(ref.read<T>(widget.model));
    }
    if (!widget.lazyLoad) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (widget.onReady != null) {
          widget.onReady!(ref.read<T>(widget.model));
        }
      });
    }
  }
}
