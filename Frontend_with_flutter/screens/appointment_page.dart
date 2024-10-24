import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/utils/config.dart';

import '../components/api_provider.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

//enum for appointment status
enum FilterStatus { upcoming, complete, cancel }

class _AppointmentPageState extends State<AppointmentPage> {
  Map<String, dynamic> hospital = {};
// String d_url = 'https://brain-tumor-classifier-in-medical.onrender.com';
  String d_url = 'http://10.0.2.2:5000';
  // String d_url = 'http://165.232.123.217:8000';
  Future<void> _getAppointments() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final url = '$d_url/user/appointments';
      final response =
          await http.get(Uri.parse(url), headers: {'token': token});

      if (response.statusCode == 200) {
        setState(() {
          schedules = json.decode(response.body)['All_Appointments'];
          print(schedules);
        });
      }
      if (response.statusCode == 204) {
        print('No content');
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('No appointments'),
            content: const Text("No appointments."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      if (response.statusCode == 401) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Logged out'),
            content: const Text(
                "You have been logged out, sign in again to continue."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

// fetch hospital
  Map<String, dynamic> user = {};
  FilterStatus status = FilterStatus.upcoming; //initial status
  Alignment _alignment = Alignment.centerLeft;
  List<dynamic> schedules = [];

  @override
  void initState() {
    super.initState();
    _getAppointments();
  }

  @override
  Widget build(BuildContext context) {
    //schedule info
    List<dynamic> filterdSchedules = schedules.where((var schedule) {
      switch (schedule['status']) {
        case 'upcoming':
          schedule['status'] = FilterStatus.upcoming;
          break;
        case 'completed':
          schedule['status'] = FilterStatus.complete;
          break;
        case 'cancled':
          schedule['status'] = FilterStatus.cancel;
          break;
      }
      return schedule['status'] == status;
    }).toList();
    return SafeArea(
        child: schedules.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Appointment schedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Config.spaceSmall,
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (FilterStatus filterStatus
                                  in FilterStatus.values)
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (filterStatus ==
                                            FilterStatus.upcoming) {
                                          status = FilterStatus.upcoming;
                                          _alignment = Alignment.centerLeft;
                                        } else if (filterStatus ==
                                            FilterStatus.complete) {
                                          status = FilterStatus.complete;
                                          _alignment = Alignment.center;
                                        } else if (filterStatus ==
                                            FilterStatus.cancel) {
                                          status = FilterStatus.cancel;
                                          _alignment = Alignment.centerRight;
                                        }
                                      });
                                    },
                                    child: Center(
                                      child: Text(filterStatus.name),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        AnimatedAlign(
                          alignment: _alignment,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 100,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Config.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                                child: Text(
                              status.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ),
                        )
                      ],
                    ),
                    Config.spaceSmall,
                    Expanded(
                      child: ListView.builder(
                        itemCount: filterdSchedules.length,
                        itemBuilder: ((context, index) {
                          var schedule = filterdSchedules[index];
                          bool isLastElement =
                              filterdSchedules.length + 1 == index;
                          return Card(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: !isLastElement
                                ? const EdgeInsets.only(bottom: 20)
                                : EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundImage:
                                            AssetImage('images/d_hospital.jpg'),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            schedule['hospital_name'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          // Text(
                                          //   schedule['location'],
                                          //   style: const TextStyle(
                                          //     color: Colors.grey,
                                          //     fontSize: 12,
                                          //     fontWeight: FontWeight.w600,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),

                                  //schedule card here also
                                  ScheduleCard(
                                    date: schedule['date'],
                                    day: schedule['day'],
                                    time: schedule['time'],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: OutlinedButton(
                                        onPressed: () async {
                                          try {
                                            final SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            final token =
                                                prefs.getString('token') ?? '';
                                            final details =
                                                await cancelAppointment(
                                                    schedule['id'], token);
                                            if (details == 'successfully') {
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context)
                                                  .pushNamed('main');
                                            }
                                            if (details == 'Invalid Token') {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  title: const Text(
                                                      'Login Failed'),
                                                  content: const Text(
                                                      'You have been logged out, try again.'),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pushNamed('/'),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          } catch (error) {
                                            print(
                                                'Error fetching user data: $error');
                                          }
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                              color: Config.primaryColor),
                                        ),
                                      ))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ));
  }
}

//schedule Widget
class ScheduleCard extends StatelessWidget {
  const ScheduleCard(
      {Key? key, required this.time, required this.date, required this.day})
      : super(key: key);
  final String date;
  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Icon(
            Icons.calendar_today,
            color: Config.primaryColor,
            size: 15,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            '$day, $date',
            style: const TextStyle(color: Config.primaryColor),
          ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.access_alarm,
            color: Config.primaryColor,
            size: 17,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              time,
              style: const TextStyle(color: Config.primaryColor),
            ),
          )
        ],
      ),
    );
    ;
  }
}
