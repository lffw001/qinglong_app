import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';

class SearchCell extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const SearchCell({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SearchCellState();
}

class _SearchCellState extends ConsumerState<SearchCell> {
  int searchTextWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: "搜索",
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    );
    textPainter.layout();
    return CupertinoTextField.borderless(
      maxLines: 1,
      textAlign: widget.controller.text.isNotEmpty ? TextAlign.center : TextAlign.start,
      decoration: BoxDecoration(
        color: ref.watch(themeProvider).themeColor.pinedAndWhite(),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      suffixMode: OverlayVisibilityMode.editing,
      suffix: GestureDetector(
        onTap: () {
          widget.controller.text = "";
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Icon(
            CupertinoIcons.clear_circled_solid,
            size: 20,
            color: ref.watch(themeProvider).themeColor.descColor(),
          ),
        ),
      ),
      controller: widget.controller,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 7,
      ),
      prefixMode: OverlayVisibilityMode.notEditing,
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      prefix: Padding(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width / 2 - textPainter.width - 15 - 5,
        ),
        child: Image.asset(
          "assets/images/icon_search.png",
          width: 18,
          color: ref.watch(themeProvider).themeColor.descColor(),
          fit: BoxFit.cover,
        ),
      ),
      placeholderStyle: TextStyle(
        fontSize: 14,
        color: ref.watch(themeProvider).themeColor.descColor(),
      ),
      style: TextStyle(
        fontSize: 16,
        color: ref.watch(themeProvider).themeColor.title2Color(),
      ),
      placeholder: "搜索",
    );
  }
}
