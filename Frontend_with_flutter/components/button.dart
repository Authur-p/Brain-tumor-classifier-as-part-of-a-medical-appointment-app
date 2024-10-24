import 'package:flutter/material.dart';

import '../utils/config.dart';

class Button extends StatefulWidget {
  const Button({
    Key? key,
    required this.width,
    required this.title,
    required this.disable,
    required this.onPressed,
  }) : super(key: key);

  final double width;
  final String title;
  final bool disable; //this is used to disable button
  final Function() onPressed;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Config.primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: widget.disable ? null : widget.onPressed,
        child: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}