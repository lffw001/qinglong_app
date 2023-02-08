import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../module/in_app_purchase_page.dart';

class CommitButton extends StatefulWidget {
  final GestureTapCallback onTap;
  final String? title;

  const CommitButton({
    Key? key,
    required this.onTap,
    this.title,
  }) : super(key: key);

  @override
  State<CommitButton> createState() => _CommitButtonState();
}

class _CommitButtonState extends State<CommitButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      onPressed: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: Center(
          child: Text(
            widget.title ?? "提交",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
          ),
        ),
      ),
    );
  }
}

void gotoInAppPurchase(BuildContext context) {
  Navigator.of(context).push(
    CupertinoPageRoute(
      builder: (context) => const InAppPurchasePage(
        fromDirectly: true,
      ),
    ),
  );
}
