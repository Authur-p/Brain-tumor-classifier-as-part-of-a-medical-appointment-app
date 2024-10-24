import 'package:flutter/material.dart';
import 'package:untitled/components/signup_form.dart';

import '../utils/config.dart';
import '../utils/text.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

//enum for appointment status
enum FilterStatus { doctor, user }

class _SignUpPageState extends State<SignUpPage> {
  FilterStatus status = FilterStatus.doctor; //initial status
  Alignment _alignment = Alignment.centerLeft;

  int currentPage = 1;
  final PageController _page = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _page,
        onPageChanged: ((value) {
          setState(() {
            //update page index when tab pressed/switch page
            currentPage = value;
          });
        }),
        children: const <Widget>[
          //put screen here
          SignUpAs()
        ],
      ),
    );
  }
}
