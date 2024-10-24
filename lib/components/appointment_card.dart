import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/components/api_provider.dart';
import 'package:untitled/utils/config.dart';
import 'package:http/http.dart' as http;

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({Key? key, required this.appointment})
      : super(key: key);
  final Map<String, dynamic> appointment;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  Map<String, dynamic> hospital = {};
  // String d_url = 'https://brain-tumor-classifier-in-medical.onrender.com';
  String d_url = 'http://10.0.2.2:5000';
  // String d_url = 'http://165.232.123.217:8000';

  Future<void> _fetchHospital() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      // print(token);
      //get current user

      String url =
          "$d_url/get_the_hospital?id=${widget.appointment['hospital_id']}";
      final response =
          await http.get(Uri.parse(url), headers: {'token': token});

      if (response.statusCode == 200) {
        setState(() {
          hospital = json.decode(response.body);
          print(hospital);
        });
      }
      if (response.statusCode == 204) {
        // setState(() {
        Navigator.of(context).pushNamed('/');

        // });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHospital();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.appointment);
    Config().init(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Config.primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: hospital.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage:
                              // 2
                              AssetImage(
                                  'images/d_hospital.jpg'), //insert hospital profilel
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${hospital['hospital']['name']} , ${hospital['hospital']['email']}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Config.spaceSmall,

                    //schedule info here
                    ScheduleCard(
                      appointment: widget.appointment,
                    ),
                    Config.spaceSmall,

                    //action buttom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final token = prefs.getString('token') ?? '';
                                final details = await cancelAppointment(
                                    widget.appointment['id'], token);
                                if (details == 'successfull') {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushNamed('main');
                                }
                                if (details == 'Invalid Token') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Login Failed'),
                                      content: const Text(
                                          'You have been logged out, try again.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pushNamed('/'),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (error) {
                                print('Error fetching user data: $error');
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Completed',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                final SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                final token = prefs.getString('token') ?? '';
                                final details = await completeAppointment(
                                    widget.appointment['id'], token);
                                print(details);
                                if (details == 'successfull') {
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushNamed('main');
                                }
                                if (details == 'Invalid Token') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Login Failed'),
                                      content: const Text(
                                          'You have been logged out, try again.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pushNamed('/'),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                if (details == 'Error') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title:
                                          const Text('Operation unsuccessfull'),
                                      content: const Text(
                                          "You can't complete a day that has not come."),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              } catch (error) {
                                print('Error fetching user data: $error');
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

//schedule Widget
class ScheduleCard extends StatelessWidget {
  const ScheduleCard({Key? key, required this.appointment}) : super(key: key);
  final Map<String, dynamic> appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            "${appointment['day']} ${appointment['date']}",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.access_alarm,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              appointment['time'],
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
