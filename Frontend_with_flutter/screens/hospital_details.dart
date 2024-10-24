import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/components/api_provider.dart';
import 'package:untitled/components/button.dart';
import 'package:untitled/components/custom_appbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:untitled/utils/Booking_datetime_conversion.dart';
import '../utils/config.dart';

class HospitalDetails extends StatefulWidget {
  const HospitalDetails({super.key});

  @override
  State<HospitalDetails> createState() => _HospitalDetailsState();
}

class _HospitalDetailsState extends State<HospitalDetails> {
  //declarations
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  @override
  Widget build(BuildContext context) {
    //get arguments passed form hospital card
    final hospital = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: const CustomAppBar(
        appTitle: "Appointment",
        icon: FaIcon(Icons.arrow_back_ios_new_rounded),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                //pass hospital details here
                AboutHospital(
                  hospital: hospital,
                ),
                _tableCalendar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Select Consultation Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 30),
                    alignment: Alignment.center,
                    child: const Text(
                      'Weekend is not available, please select another date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          //when selected, update current index and set time selected to true
                          setState(() {
                            _currentIndex = index;
                            _timeSelected = true;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          // change size of consult time here
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            color: _currentIndex == index
                                ? Config.primaryColor
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  _currentIndex == index ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, childAspectRatio: 1.5),
                ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: Button(
                width: double.infinity,
                title: "Make Appointment",
                onPressed: () async {
                  try {
                    final getDate = DateConverted.getDate(_currentDay);
                    final getDay = DateConverted.getDay(_currentDay.weekday);
                    final getTime = DateConverted.getTime(_currentIndex!);
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final token = prefs.getString('token') ?? '';
                    final details = await bookAppointment(
                        hospital['id'], getDate, getTime, getDay, token);
                    if (details) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamed('sucess_booked');
                    }
                    //  (details == null)
                    else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Login Failed'),
                          content: const Text(
                              'You have been logged out, try again.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/'),
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
                disable: _timeSelected && _dateSelected ? false : true,
              ),
            ),
          )
        ],
      ),
    );
  }

  //table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2023, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
              color: Config.primaryColor, shape: BoxShape.circle)),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          //check if weekend is selected
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }
}

//About_Hospital widget
class AboutHospital extends StatelessWidget {
  const AboutHospital({Key? key, required this.hospital}) : super(key: key);
  final Map<dynamic, dynamic> hospital;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const CircleAvatar(
            radius: 65.0,
            backgroundColor: Colors.white,
            // 4
            backgroundImage: AssetImage(
                                      'images/d_hospital.jpg'),
          ),
          Config.spaceMedium,
          Text(
            hospital['name'],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              hospital['about'],
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: Text(
              hospital['location'],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
