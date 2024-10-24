import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:dio/dio.dart';
// String d_url = 'https://brain-tumor-classifier-in-medical.onrender.com';
String d_url = 'http://10.0.2.2:5000';
// String d_url = 'http://165.232.123.217:8000';
// login as user
Future<dynamic> getToken(String email, String password) async {
  final url = '$d_url/login_user';
  print(url);
  // Get shared preferences instance
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(Uri.parse(url), body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 && jsonDecode(response.body) != '') {
      // Successful request
      final responseBody = json.decode(response.body);
      print(responseBody['token']);
      // Store the token in shared preferences
      await prefs.setString('token', responseBody['token']);
      return response.body;
    }
    //else {
    //   return false;
    // }
  } catch (error) {
    return error;
  }
}

//finall login user
Future<dynamic> getUser(String token) async {
  try {
    var user = await http
        .get(Uri.parse('$d_url/login_user'), headers: {'token': token});

    if (user.statusCode == 200 && user.body != '') {
      // Successful request
      return json.encode(user.body);
    }
  } catch (error) {
    print("Hello there!");
    return error;
  }
}

// login as hospital
Future<dynamic> getHospitalToken(String email, String password) async {
  final url = '$d_url/login_hospital';
  // Get shared preferences instance
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(Uri.parse(url), body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 && jsonDecode(response.body) != '') {
      // Successful request
      final responseBody = json.decode(response.body);
      print(responseBody['token']);
      // Store the token in shared preferences
      await prefs.setString('token', responseBody['token']);
      return response.body;
    }
  } catch (error) {
    return error;
  }
}

//finall login hospital
Future<dynamic> gethospital(String token) async {
  try {
    var user = await http
        .get(Uri.parse('$d_url/login_hospital'), headers: {'token': token});

    if (user.statusCode == 200 && user.body != '') {
      // Successful request
      return json.encode(user.body);
    }
  } catch (error) {
    return error;
  }
}

//register user
Future<dynamic> sendUserSignUpRequest(
  String name,
  String email,
  String password,
  String age,
) async {
  final url = '$d_url/add_user';
  // Get shared preferences instance
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(Uri.parse(url), body: {
      'name': name,
      'email': email,
      'password': password,
      'age': age,
    });
    if (response.statusCode == 200 && response.body != '') {
      // Successful request
      final responseBody = json.decode(response.body);
      print(responseBody['token']);
      // Store the token in shared preferences
      await prefs.setString('token', responseBody['token']);
      return responseBody;
    }
  } catch (error) {
    return error;
  }
}

//register hospital
Future<dynamic> sendHospitalSignUpRequest(String name, String email,
    String password, String about, String location) async {
  final url = '$d_url/add_hospital';
  // Get shared preferences instance
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(Uri.parse(url), body: {
      'name': name,
      'email': email,
      'password': password,
      'about': about,
      'location': location,
    });
    if (response.statusCode == 200 && response.body != '') {
      // Successful request
      final responseBody = json.decode(response.body);
      print(responseBody['token']);
      // Store the token in shared preferences
      await prefs.setString('token', responseBody['token']);
      return responseBody;
    }
  } catch (error) {
    return error;
  }
}

Future<dynamic> bookAppointment(
    int hospitalId, String date, String time, String day, String token) async {
  final url = '$d_url/book_appointment';
  try {
    final response = await http.post(Uri.parse(url), body: {
      'hospital_id': hospitalId.toString(),
      'date': date,
      'time': time,
      'day': day,
    }, headers: {
      'token': token
    });
    if (response.statusCode == 200) {
      // Successful request
      // final responseBody = json.decode(response.body);
      // print(responseBody['token']);
      // Store the token in shared preferences
      return true;
    } else {
      return false;
    }
  } catch (error) {
    return error;
  }
}

Future<String> cancelAppointment(int appointmentId, String token) async {
  final url = '$d_url/user/appointment/cancel';
  try {
    final response = await http.patch(Uri.parse(url), body: {
      'id': appointmentId.toString(),
    }, headers: {
      'token': token
    });
    if (response.statusCode == 200) {
      // Successful request
      // final responseBody = json.decode(response.body);
      // print(responseBody['token']);
      // Store the token in shared preferences
      return 'successfully';
    }
    if (response.statusCode == 401) {
      return 'Invalid Token';
    } else {
      return 'Error';
    }
  } catch (error) {
    return '$error';
  }
}

Future<String> completeAppointment(int appointmentId, String token) async {
  final url = '$d_url/user/appointment/complete';
  try {
    final response = await http.patch(Uri.parse(url), body: {
      'id': appointmentId.toString(),
    }, headers: {
      'token': token
    });
    if (response.statusCode == 200) {
      return 'successfull';
    }
    if (response.statusCode == 401) {
      return 'Invalid Token';
    } else {
      return 'Error';
    }
  } catch (error) {
    return '$error';
  }
}


// //get current user
// Future<void> currentUser() async {
//   const url = 'http://10.0.2.2:5000/current_user';
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200 && jsonDecode(response.body) != '') {
//     final responseBody = jsonDecode(response.body);
//     return responseBody;
//   } else {
//     print('Request failed with status: ${response.statusCode}.');
//   }
// }
