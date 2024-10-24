import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/config.dart';
import 'api_provider.dart';
import 'button.dart';

class SignUpAs extends StatefulWidget {
  const SignUpAs({super.key});

  @override
  State<SignUpAs> createState() => _SignUpAsState();
}

enum FilterStatus { user, hospital }

class _SignUpAsState extends State<SignUpAs> {
  FilterStatus status = FilterStatus.user; //initial status
  Alignment _alignment = Alignment.centerLeft;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Signup As',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
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
                          for (FilterStatus filterStatus in FilterStatus.values)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (filterStatus == FilterStatus.hospital) {
                                      status = FilterStatus.hospital;
                                      _alignment = Alignment.centerRight;
                                    } else if (filterStatus ==
                                        FilterStatus.user) {
                                      status = FilterStatus.user;
                                      _alignment = Alignment.centerLeft;
                                    }
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    filterStatus.name,
                                    style: const TextStyle(fontSize: 18),
                                  ),
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
                        width: 150,
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

                // Display the signup form based on the selected FilterStatus
                if (status == FilterStatus.hospital)
                  const DoctorSignUpForm()
                else if (status == FilterStatus.user)
                  const UserSignUpForm()
              ]),
        ),
      ),
    );
  }
}

//Widget for doctor signup
class DoctorSignUpForm extends StatefulWidget {
  const DoctorSignUpForm({super.key});

  @override
  State<DoctorSignUpForm> createState() => _DoctorSignUpFormState();
}

class _DoctorSignUpFormState extends State<DoctorSignUpForm> {
  final _formKey_ = GlobalKey<FormState>();
  final _emailController_ = TextEditingController();
  final _passController_ = TextEditingController();
  final _conpassController_ = TextEditingController();
  final _nameController_ = TextEditingController();
  final _locationController_ = TextEditingController();
  final _aboutController_ = TextEditingController();
  bool obsecurePass = true;

  File? _profilePicture;

  Future<void> _pickProfilePicture() async {
    final pickedFile =
        // ignore: deprecated_member_use
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey_,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Profile picture field
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: _profilePicture != null
                    ? FileImage(_profilePicture!)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  onTap: _pickProfilePicture,
                  decoration: const InputDecoration(
                    hintText: 'Select profile picture',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
            ],
          ),
          Config.spaceSmall,

          //name field
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _nameController_,
              keyboardType: TextInputType.name,
              cursorColor: Config.primaryColor,
              decoration: const InputDecoration(
                hintText: 'Hospital name',
                labelText: 'Name',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.local_hospital_outlined),
                prefixIconColor: Config.primaryColor,
              ),
            ),
          ),
          Config.spaceSmall,

          //email field
          TextFormField(
            controller: _emailController_,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,

          //password
          TextFormField(
            controller: _passController_,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black38,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
          ),
          Config.spaceSmall,

          //confirm password
          TextFormField(
            controller: _conpassController_,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Confirm password',
              labelText: 'Confirm password',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black38,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
          ),
          Config.spaceSmall,

          //location field
          TextFormField(
            controller: _locationController_,
            keyboardType: TextInputType.name,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Location',
              labelText: 'Location',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.map),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,

          //About field
          TextFormField(
            controller: _aboutController_,
            keyboardType: TextInputType.multiline,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'About',
              labelText: 'About',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.abc_outlined),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,

          //Signup button
          Button(
              width: double.infinity,
              title: 'Sign Up',
              onPressed: () async {
                //send login request to server
                final token = await sendHospitalSignUpRequest(
                    _nameController_.text,
                    _emailController_.text,
                    _passController_.text,
                    _aboutController_.text,
                    _locationController_.text);
                // // ignore: use_build_context_synchronously
                // final user = token != null ? await gethospital(token) : null;
                if (token != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed('hospital_page');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Login Failed'),
                      content:
                          const Text('Please check your email and password.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              disable: false),
        ],
      ),
    );
  }
}

//Widget for user sign up form
class UserSignUpForm extends StatefulWidget {
  const UserSignUpForm({super.key});

  @override
  State<UserSignUpForm> createState() => _UserSignUpFormState();
}

class _UserSignUpFormState extends State<UserSignUpForm> {
  final _formKey_ = GlobalKey<FormState>();
  final _emailController_ = TextEditingController();
  final _passController_ = TextEditingController();
  final _conpassController_ = TextEditingController();
  final _nameController_ = TextEditingController();
  final _ageController_ = TextEditingController();
  bool obsecurePass = true;

  File? _profilePicture;

  Future<void> _pickProfilePicture() async {
    final pickedFile =
        // ignore: deprecated_member_use
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePicture = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey_,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Profile picture field
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: _profilePicture != null
                    ? FileImage(_profilePicture!)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  onTap: _pickProfilePicture,
                  decoration: const InputDecoration(
                    hintText: 'Select profile picture',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
            ],
          ),
          Config.spaceSmall,

          //name field
          SizedBox(
            width: double.infinity,
            child: TextFormField(
              controller: _nameController_,
              keyboardType: TextInputType.name,
              cursorColor: Config.primaryColor,
              decoration: const InputDecoration(
                hintText: 'Your name',
                labelText: 'Name',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.local_hospital_outlined),
                prefixIconColor: Config.primaryColor,
              ),
            ),
          ),
          Config.spaceSmall,

          //email field
          TextFormField(
            controller: _emailController_,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,

          //password
          TextFormField(
            controller: _passController_,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black38,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
          ),
          Config.spaceSmall,

          //confirm password
          TextFormField(
            controller: _conpassController_,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Confirm password',
              labelText: 'Confirm password',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black38,
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: Config.primaryColor,
                      ),
              ),
            ),
          ),
          Config.spaceSmall,

          //About field
          TextFormField(
            controller: _ageController_,
            keyboardType: TextInputType.number,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Age',
              labelText: 'Age',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.person),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,

          //login button
          Button(
              width: double.infinity,
              title: 'Sign Up',
              onPressed: () async {
                //send login request to server
                final token = await sendUserSignUpRequest(
                    _nameController_.text,
                    _emailController_.text,
                    _passController_.text,
                    _ageController_.text);
                // // ignore: use_build_context_synchronously
                // final user = token != null ? await gethospital(token) : null;
                if (token != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamed('main');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Login Failed'),
                      content:
                          const Text('Please check your email and password.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              disable: false),
        ],
      ),
    );
  }
}
