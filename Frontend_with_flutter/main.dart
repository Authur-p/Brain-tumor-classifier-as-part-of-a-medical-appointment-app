import 'package:flutter/material.dart';
import 'package:untitled/main_layout.dart';
import 'package:untitled/screens/appointment_page.dart';
import 'package:untitled/screens/auth_page.dart';
import 'package:untitled/screens/home_page.dart';
import 'package:untitled/screens/hospital_details.dart';
import 'package:untitled/screens/hospital_page.dart';
import 'package:untitled/screens/signup_page.dart';
import 'package:untitled/screens/sucess_booked.dart';
import 'package:untitled/utils/config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

//this is for push navigator
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    //define ThemeData here
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Flutter Doctor App',
      theme: ThemeData(
        //pre-define input decoration
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Config.primaryColor,
          border: Config.outlinedBorder,
          focusedBorder: Config.focusBorder,
          errorBorder: Config.errorBorder,
          enabledBorder: Config.outlinedBorder,
          floatingLabelStyle: TextStyle(color: Config.primaryColor),
          prefixIconColor: Colors.black38,
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Config.primaryColor,
          selectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey.shade700,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/',
      routes: {
        //this is initial route of the app
        //which is auth page (login and sign up )
        '/': (context) => const AuthPage(),
        //this is for main layout after login
        'main': (context) => const MainLayout(),
        'hospital_page': (context) => const HospitalPage(),
        'hospital_details': (context) => const HospitalDetails(),
        'sucess_booked': (context) => const AppointmentBooked(),
        'signup': (context) => const SignUpPage(),
        'appointments': (context) => const AppointmentPage(),
        'homePage': (context) => const HomePage(),
      },
      // home: const MyHomePage(title: 'Flutter Doctor App'),
    );
  }
}
