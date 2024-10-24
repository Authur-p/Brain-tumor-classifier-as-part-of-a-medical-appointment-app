import 'dart:convert';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/components/api_provider.dart';

import '../utils/config.dart';

class TumorTestPage extends StatefulWidget {
  const TumorTestPage({Key? key}) : super(key: key);

  @override
  State<TumorTestPage> createState() => _TumorTestPageState();
}

class _TumorTestPageState extends State<TumorTestPage> {
  Map<String, dynamic> user = {};
// String d_url = 'https://brain-tumor-classifier-in-medical.onrender.com';
String d_url = 'http://10.0.2.2:5000';
//   String d_url = 'http://165.232.123.217:8000';

  File? file;
  String? message = "";
  ImagePicker image = ImagePicker();
  bool isImageSelected = false;
  bool isScanResultDisplayed = false;

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
          user = json.decode(response.body)['Logged_in_user'];
          print(user);
          // print(user['Logged_in_user']['name']);
        });
      }
      if (response.statusCode == 401) {
        setState(() {
          Navigator.of(context).pushNamed('/');
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
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
                          user['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          child: CircleAvatar(
                            radius: 30,
                            // 5
                            backgroundImage:
                                AssetImage('images/d_profile_u.jpg'),
                          ),
                        )
                      ],
                    ),
                    Config.spaceMedium,

                    //Buttons
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: 280,
                            decoration: BoxDecoration(
                              color: Config.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            // height: 180,
                            // width: 220,
                            // color: Colors.black12,
                            child: file == null
                                ? const Icon(
                                    Icons.medical_services_outlined,
                                    size: 50,
                                  )
                                : Image.file(
                                    file!,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          Config.spaceSmall,

                          //import to gallary button
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Config.primaryColor,
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                getgall();
                              },
                              child: const Text(
                                "Import from gallery",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Config.spaceSmall,

                          //test image button
                          MaterialButton(
                            color: Config.primaryColor,
                            onPressed:
                                isImageSelected ? () => sendImage() : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Check for Tumor in image",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),

                          Config.spaceSmall,

                          //test result
                          if (isScanResultDisplayed)
                            Text(
                              message!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
    );
  }

  getgall() async {
    // ignore: deprecated_member_use
    var img = await image.getImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
      isImageSelected = true;
    });
  }

  sendImage() async {
    if (file == null) {
      print('thisNull');
      return;
    }

    final url = Uri.parse('$d_url/predict_tumor');

    final request = http.MultipartRequest('POST', url);

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      await file!.readAsBytes(),
      filename: file!.path.split('/').last,
    );

    request.files.add(multipartFile);

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      setState(() {
        message = jsonDecode(responseBody)['predictions'];
        print(message);
        isScanResultDisplayed = true;
      });
    } else {
      setState(() {
        message = "Image upload failed with status ${response.statusCode}";
        print(response.statusCode);
        // Navigator.of(context).pushNamed('main');
      });
    }
  }
}
