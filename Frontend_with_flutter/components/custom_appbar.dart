import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/config.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    this.appTitle,
    this.route,
    this.icon,
    this.action,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60); //default size of appBar

  final String? appTitle;
  final String? route;
  final FaIcon? icon;
  final List<Widget>? action;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.appTitle!,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      //if icon is not set, return null
      leading: widget.icon != null
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Config.primaryColor,
              ),
              child: IconButton(
                onPressed: () {
                  //if route is given, then this button gan navigate to the route
                  if (widget.route != null) {
                    Navigator.of(context).pushNamed(widget.route!);
                  } else {
                    //else just simple pop back to previous page
                    Navigator.of(context).pop();
                  }
                },
                icon: widget.icon!,
                iconSize: 16,
                color: Colors.white,
              ),
            )
          : null,
      //if action is not set, return null  
      actions: widget.action ?? null,
    );
  }
}
