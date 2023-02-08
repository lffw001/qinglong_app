import 'package:flutter/material.dart';

class ButtonWidget extends StatefulWidget {
  final GestureTapCallback onTap;

  final String? title;

  const ButtonWidget({
    Key? key,
    required this.onTap,
    this.title,
  }) : super(key: key);

  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff5DD16F),
                Color(0xff089556),
              ],
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Center(
            child: Text(
              widget.title ?? "提交",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
