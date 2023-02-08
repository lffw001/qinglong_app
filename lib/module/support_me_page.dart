import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';

import '../base/theme.dart';


class SupportMePage extends ConsumerStatefulWidget {
  const SupportMePage({Key? key}) : super(key: key);

  @override
  ConsumerState<SupportMePage> createState() => _SupportMePageState();
}

class _SupportMePageState extends ConsumerState<SupportMePage> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "请作者喝杯咖啡",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: Text(
              "截屏后打开相应的支付软件即可",
              maxLines: 1,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: ref.watch(themeProvider).themeColor.descColor(),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 55,
            child: ColoredBox(
              color: ref.watch(themeProvider).currentTheme.scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  bottom: 10,
                  top: 10,
                ),
                child: CustomSlidingSegmentedControl<int>(
                  initialValue: 0,
                  height: 35,
                  isStretch: true,
                  children: {
                    0: Text(
                      "微信",
                      style: TextStyle(
                        fontSize: 14,
                        color: ref.watch(themeProvider).themeColor.title2Color(),
                      ),
                    ),
                    1: Text(
                      "支付宝",
                      style: TextStyle(
                        fontSize: 14,
                        color: ref.watch(themeProvider).themeColor.title2Color(),
                      ),
                    ),
                  },
                  decoration: BoxDecoration(
                    color: ref.watch(themeProvider).themeColor.segmentedUnCheckBg(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: ref.watch(themeProvider).themeColor.blackAndWhite(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInToLinear,
                  onValueChanged: (v) {
                    tabController.index = v;
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  child: Image.asset(
                    "assets/images/support_me.png",
                    width: MediaQuery.of(context).size.width - 60,
                    height: MediaQuery.of(context).size.width - 60,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                Padding(
                  child: Image.asset(
                    "assets/images/alipay.png",
                    fit: BoxFit.fitHeight,
                    width: MediaQuery.of(context).size.width - 60,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
              ],
              controller: tabController,
            ),
          ),
        ],
      ),
    );
  }
}
