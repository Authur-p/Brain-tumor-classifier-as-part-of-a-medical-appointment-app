// import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:untitled/components/appointment_card.dart';
import 'package:untitled/components/hospital_card.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> user = {};
  Map<String, dynamic> appointments = {};
// String d_url = 'https://brain-tumor-classifier-in-medical.onrender.com';
  String d_url = 'http://10.0.2.2:5000';
  // String d_url = 'http://165.232.12 3.217:8000';
  // File? file;
  // ImagePicker image = ImagePicker();

  Future<void> _fetchCurrentUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      // print(token);
      //get current user

      final url = '$d_url/current_user';
      final response =
          await http.get(Uri.parse(url), headers: {'token': token});

      if (response.statusCode == 200 && jsonDecode(response.body) != '') {
        setState(() {
          user = json.decode(response.body);
          print(user);
        });
      }
      if (response.statusCode == 401) {
        // setState(() {
        Navigator.of(context).pushNamed('/');

        // });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> _fetchAppointment() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      // print(token);
      //get current user

      final url = '$d_url/upcoming/user/appointment';
      final response =
          await http.get(Uri.parse(url), headers: {'token': token});

      if (response.statusCode == 200 && response.body != '') {
        setState(() {
          appointments = json.decode(response.body);
          print(appointments);
        });
      }
      // if (response.statusCode == 204) {
      //   // setState(() {
      //   // Navigator.of(context).pushNamed('/');

      //   // });
      // }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
    _fetchAppointment();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      body: user.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            user['Logged_in_user']['name'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  // 1
                                  AssetImage('images/d_profile_u.jpg'),
                            ),
                          )
                        ],
                      ),
                      Config.spaceBig,

                      //appointment card
                      const Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,

                      appointments.isNotEmpty
                          ? Column(
                              children: List.generate(
                                  appointments['Upcoming'].length, (index) {
                                return Column(
                                  children: [
                                    AppointmentCard(
                                      appointment: appointments['Upcoming']
                                          [index],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }),
                            )
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                  child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "No upcoming appointments",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))),

                      Config.spaceSmall,

                      //Available hospitals
                      const Text(
                        'Book appointments with available hospitals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // list of hospitals
                      Config.spaceSmall,
                      Column(
                        children: List.generate(user['All_Hospitals'].length,
                            (index) {
                          return DoctorCard(
                            route: 'hospital_details',
                            hospital: user['All_Hospitals'][index],
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
