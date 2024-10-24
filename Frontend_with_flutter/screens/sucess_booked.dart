import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../components/button.dart';

class AppointmentBooked extends StatelessWidget {
  const AppointmentBooked({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Lottie.asset('images/sucess.json'),
          ),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'Sucessfully Booked',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),

          //back to home page
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Button(
              width: double.infinity,
              title: "Back to home page",
              onPressed: () => Navigator.of(context).pushNamed('main'),
              disable: false,
            ),
          )
        ],
      )),
    );
  }
}
