import 'package:flutter/material.dart';
import 'package:untitled/components/hospital_appointments.dart';

class HospitalPage extends StatefulWidget {
  const HospitalPage({super.key});

  @override
  State<HospitalPage> createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  int currentPage = 2;
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
          HospitalAppointmentPage()
        ],
      ),
    );
  }
}
